from fastapi import FastAPI, UploadFile, File, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
import google.generativeai as genai
import os
from dotenv import load_dotenv
import json #to read JSON from gemini 
from supabase import create_client, Client
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

# Load the API key from the .env file
load_dotenv()
API_KEY = os.getenv("GEMINI_API_KEY")

# Configure the Gemini API
genai.configure(api_key=API_KEY)
#Setup Supabase
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if not API_KEY:
    raise ValueError("No GEMINI_API_KEY found in environment variables!")

app = FastAPI(title="KebunKomuniti AI Service")

#Rate Limiter Setup
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# We use Gemini 2.5 Flash because it is incredibly fast and multimodal (takes images + text)
model = genai.GenerativeModel('gemini-2.5-flash')

# Allow the frontend to talk to this backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

#Connect if we have real key
supabase: Client | None = None
try:
    if SUPABASE_URL and SUPABASE_KEY and "waiting" not in SUPABASE_URL.lower():
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Supabase connection successful!")
    else:
        print("ℹ️ Supabase connection skipped (using placeholders).")
except Exception as e:
    print(f"❌ Warning: Supabase connection failed (Invalid Key): {e}")
    print("ℹ️ AI Service will continue running WITHOUT database saving.")

@app.get("/")
def read_root():
    return {"status": "AI Microservice is running securely!"}

# --- Marketplace Assistant Prompt ---
ASSISTANT_PROMPT = """
You are the KebunKomuniti Marketplace Assistant. 
Analyze the image of the garden produce and provide a JSON response.
1. Identify the item name.
2. Estimate the weight in kilograms based on the quantity shown.
3. Suggest a fair local community price in RM (Ringgit Malaysia).

Return ONLY this JSON format:
{
  "item_name": "string",
  "estimated_weight_kg": float,
  "suggested_price_rm": float,
  "confidence": "string"
}
"""

@app.post("/api/ai/assistant")
@limiter.limit("5/minute")
async def marketplace_assistant(request: Request, file: UploadFile = File(...)):
    mime_type = file.content_type or "image/jpeg"
    img_bytes = await file.read()
    
    try:
        response = model.generate_content([
            ASSISTANT_PROMPT,
            {"mime_type": mime_type, "data": img_bytes}
        ])
        
        # Clean and parse JSON
        clean_text = response.text.replace("```json\n", "").replace("```", "").strip()
        return {"success": True, "data": json.loads(clean_text)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/ai/diagnose")
@limiter.limit("5/minute") # Only allow 5 requests per minute per IP
async def diagnose_plant(request: Request , file: UploadFile = File(...)):
    """
    Receives an image of a plant, sends it to Gemini, and returns a diagnosis.
    """
    # 1. Be forgiving with the frontend's file type!
    mime_type = file.content_type
    if not mime_type or not mime_type.startswith("image/"):
        print("Warning: Frontend forgot the image tag. Forcing image/jpeg...")
        mime_type = "image/jpeg"

    try:
        # 2. Read the image bytes into memory
        img_bytes = await file.read()
        
        # 3. Format the image exactly how the Gemini API wants it
        image_part = {
            "mime_type": mime_type, # <-- USE THE NEW VARIABLE HERE!
            "data": img_bytes
        }

        # 4. The Prompt Engineering (The Localized Malaysian Upgrade)
        prompt = """
        You are an expert agricultural AI assistant for the 'KebunKomuniti' Malaysian urban farming app.
        Your primary users are gardening in Malaysia's tropical, high-humidity climate. 
        Pay special attention to common local pests such as Aphids, Mealybugs (Koya), Whiteflies, and Spider Mites, as well as fungal issues like Powdery Mildew.
        
        CRITICAL STEP 1: Analyze the image. Does it actually contain a plant, leaf, crop, vegetable, or garden?
        If the image does NOT contain a plant (e.g., it is a person, a keyboard, a dog, a blank screen, or a coffee cup), you must safely reject it.
        
        CRITICAL STEP 2: You MUST respond STRICTLY with a valid JSON object. Do not include any conversational text. Do not use markdown formatting.
        
        Use exactly this structure:
        {
            "is_plant": true or false,
            "plant_name": "Common name in English/Malay (or 'N/A' if not a plant)",
            "is_healthy": true or false (must be false if not a plant),
            "disease_name": "Name of the issue, 'None' if healthy, or 'Not a plant detected'",
            "confidence": "A percentage from 0 to 100 on how sure you are",
            "diy_remedy": "A practical, zero-cost home solution (e.g., dish soap, neem oil spray). 'N/A' if invalid.",
            "commercial_remedy": "What specific product they should buy from a Malaysian nursery. 'N/A' if invalid."
        }
        """

        # 5. Send both the prompt and the image to Gemini
        response = model.generate_content([prompt, image_part])

        #Turn gemini text into a real python dictionary
        try:
            #clear text in case gemini accidentally added markdown formatting
            clean_text = response.text.replace("```json\n", "").replace("```", "").strip()
            diagnosis_data = json.loads(clean_text)
        except json.JSONDecodeError:
            raise HTTPException(status_code=500, detail="AI didn't return valid JSON.")
        
        #Save to database (If its a plant AND we have keys)
        if diagnosis_data.get("is_plant") == True and supabase:
            try:
                #Assume a table called 'diagnoses'
                insert_result = supabase.table("diagnoses").insert({
                    "plant_name": diagnosis_data.get("plant_name"),
                    "is_healthy": diagnosis_data.get("is_healthy"),
                    "disease_name": diagnosis_data.get("disease_name"),
                    "remedy_advice": diagnosis_data.get("remedy_advice")
                }).execute()
                print(f"✅ Supabase Save Success! Inserted ID: {insert_result.data}")
            except Exception as e:
                print(f"❌ SUPABASE ERROR: {e}")

        # 6. Return the final data to the mobile app
        return {
            "success": True,
            "filename": file.filename,
            "diagnosis": diagnosis_data
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

