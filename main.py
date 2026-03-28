from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import google.generativeai as genai
import os
from dotenv import load_dotenv

# Load the API key from the .env file
load_dotenv()
API_KEY = os.getenv("GEMINI_API_KEY")

if not API_KEY:
    raise ValueError("No GEMINI_API_KEY found in environment variables!")

# Configure the Gemini API
genai.configure(api_key=API_KEY)

# We use Gemini 1.5 Flash because it is incredibly fast and multimodal (takes images + text)
model = genai.GenerativeModel('gemini-2.5-flash')

app = FastAPI(title="KebunKomuniti AI Service")

# Allow the frontend to talk to this backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"status": "AI Microservice is running securely!"}

@app.post("/api/ai/diagnose")
async def diagnose_plant(file: UploadFile = File(...)):
    """
    Receives an image of a plant, sends it to Gemini, and returns a diagnosis.
    """
    # 1. Validate the file type
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File provided is not an image.")

    try:
        # 2. Read the image bytes into memory
        img_bytes = await file.read()
        
        # 3. Format the image exactly how the Gemini API wants it
        image_part = {
            "mime_type": file.content_type,
            "data": img_bytes
        }

        # 4. The Prompt Engineering (This is where you control the AI's personality)
        prompt = """
        You are a friendly, expert botanist helping a beginner urban farmer in Malaysia. 
        Look at this image. 
        1. Identify the plant if possible.
        2. Diagnose its health. If it looks sick, explain what the problem likely is (e.g., nitrogen deficiency, pests, overwatering).
        3. Provide a very short, simple, organic remedy they can do at home.
        Keep the entire response under 3 sentences and be encouraging!
        """

        # 5. Send both the prompt and the image to Gemini
        response = model.generate_content([prompt, image_part])

        # 6. Return the JSON to the mobile app
        return {
            "success": True,
            "filename": file.filename,
            "diagnosis": response.text
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))