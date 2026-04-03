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
if SUPABASE_URL and SUPABASE_KEY and SUPABASE_URL != "waiting_for_teammate":
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

@app.get("/")
def read_root():
    return {"status": "AI Microservice is running securely!"}

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

        # 4. The Prompt Engineering (Day 2: The Armor Upgrade)
        prompt = """
        You are an expert agricultural AI assistant for the 'KebunKomuniti' Malaysian urban farming app.
        
        CRITICAL STEP 1: Analyze the image. Does it actually contain a plant, leaf, crop, vegetable, or garden?
        If the image does NOT contain a plant (e.g., it is a person, a keyboard, a dog, a blank screen, or a coffee cup), you must safely reject it.
        
        CRITICAL STEP 2: You MUST respond STRICTLY with a valid JSON object. Do not include any conversational text. Do not use markdown formatting like ```json.
        
        Use exactly this structure:
        {
            "is_plant": true or false,
            "plant_name": "Common name in English/Malay (or 'N/A' if not a plant)",
            "is_healthy": true or false (must be false if not a plant),
            "disease_name": "Name of the issue, 'None' if healthy, or 'Not a plant detected' if invalid image",
            "confidence": "A percentage from 0 to 100 on how sure you are",
            "remedy_advice": "Short household remedy, or 'Please upload a clear picture of a leaf or plant.' if invalid image"
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
                supabase.table("diagnoses").insert({
                    "plant_name": diagnosis_data.get("plant_name"),
                    "is_healthy": diagnosis_data.get("is_healthy"),
                    "disease_name": diagnosis_data.get("disease_name"),
                    "remedy_advice": diagnosis_data.get("remedy_advice")
                }).execute()
                print("Successfully saved to Supabase!")
            except Exception as e:
                print(f"Warning: Couldn't save to database : {e}")

        # 6. Return the final data to the mobile app
        return {
            "success": True,
            "filename": file.filename,
            "diagnosis": diagnosis_data
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

