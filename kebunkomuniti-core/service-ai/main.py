from fastapi import FastAPI, UploadFile, File, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
import google.generativeai as genai
import os
from dotenv import load_dotenv
import json
import re
from supabase import create_client, Client
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

load_dotenv()
API_KEY = os.getenv("GEMINI_API_KEY")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

genai.configure(api_key=API_KEY)
model = genai.GenerativeModel('gemini-2.5-flash')

app = FastAPI(title="KebunKomuniti AI Service")
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

supabase: Client | None = None
try:
    if SUPABASE_URL and SUPABASE_KEY and "waiting" not in SUPABASE_URL.lower():
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Supabase connected!")
except Exception as e:
    print(f"❌ Supabase Error: {e}")

# --- ROBUST JSON CLEANER ---
def clean_json_response(text: str):
    """Removes markdown backticks and extra spaces so JSON parsing never fails."""
    # Use regex to find everything between { and }
    match = re.search(r'(\{.*\})', text, re.DOTALL)
    if match:
        return match.group(1)
    return text.replace("```json", "").replace("```", "").strip()

@app.get("/")
def read_root():
    return {"status": "AI Service Active"}

@app.post("/api/ai/diagnose")
@limiter.limit("10/minute")
async def diagnose_plant(request: Request, file: UploadFile = File(...)):
    mime_type = file.content_type or "image/jpeg"
    try:
        img_bytes = await file.read()
        
        prompt = """
        You are an expert agricultural AI assistant for the 'KebunKomuniti' Malaysian urban farming app.
        Respond STRICTLY with this JSON structure:
        {
            "is_plant": true/false,
            "plant_name": "string",
            "is_healthy": true/false,
            "disease_name": "string",
            "confidence": "string with %",
            "diy_remedy": "string",
            "commercial_remedy": "string"
        }
        """

        response = model.generate_content([prompt, {"mime_type": mime_type, "data": img_bytes}])
        
        # 1. Clean and Parse
        raw_text = response.text
        print(f"🤖 RAW AI RESPONSE: {raw_text}") # See this in Docker logs!
        
        clean_text = clean_json_response(raw_text)
        diagnosis_data = json.loads(clean_text)

        # 2. Save to Supabase (Safe Mode)
        if diagnosis_data.get("is_plant") and supabase:
            try:
                supabase.table("diagnoses").insert({
                    "plant_name": diagnosis_data.get("plant_name"),
                    "is_healthy": diagnosis_data.get("is_healthy"),
                    "disease_name": diagnosis_data.get("disease_name"),
                    "diy_remedy": diagnosis_data.get("diy_remedy"),
                    "commercial_remedy": diagnosis_data.get("commercial_remedy")
                }).execute()
            except Exception as e:
                print(f"⚠️ DB Save Ignored: {e}")

        return {"success": True, "diagnosis": diagnosis_data}

    except Exception as e:
        print(f"💥 CRITICAL ERROR: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/ai/assistant")
async def marketplace_assistant(request: Request, file: UploadFile = File(...)):
    mime_type = file.content_type or "image/jpeg"
    try:
        img_bytes = await file.read()
        prompt = "Analyze produce. Return JSON: item_name, estimated_weight_kg, suggested_price_rm, confidence."
        response = model.generate_content([prompt, {"mime_type": mime_type, "data": img_bytes}])
        clean_text = clean_json_response(response.text)
        return {"success": True, "data": json.loads(clean_text)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
