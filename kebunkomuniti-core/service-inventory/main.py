from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
from dotenv import load_dotenv
from supabase import create_client, Client
import pandas as pd
from sklearn.cluster import DBSCAN

# 1. Load your partners' environment variables
load_dotenv()
url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_KEY")

if not url or not key:
    raise ValueError("Missing SUPABASE_URL or SUPABASE_KEY in .env!")

supabase: Client = create_client(url, key)

app = FastAPI(title="KebunKomuniti Inventory & Spatial Service")

# 2. Data structure for incoming plant data
class InventoryItem(BaseModel):
    item_name: str
    weight_kg: float
    lat: float
    lng: float

@app.get("/")
def health_check():
    return {"status": "Inventory Microservice is online!"}

@app.post("/add-item")
async def add_item(item: InventoryItem):
    try:
        point = f"POINT({item.lng} {item.lat})"   
        
        # We are adding lat and lng here so the Algo can read them easily later!
        data = {
            "item_name": item.item_name,
            "weight_kg": item.weight_kg,
            "lat": item.lat,
            "lng": item.lng,
            "location": point
        }
        
        response = supabase.table("inventory").insert(data).execute()
        return {"success": True, "message": "Item added to community pool!"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/clusters/{vegetable}")
async def get_clusters(vegetable: str):
    """Runs DBSCAN to find groups of the same vegetable within 3km."""
    try:
        # 1. Get all items of this type from Supabase
        res = supabase.table("inventory").select("*").eq("item_name", vegetable).execute()
        df = pd.DataFrame(res.data)

        if df.empty:
            return {"clusters": []}

        # 2. Convert geography string back to Lat/Lng for math
        # Note: In a hackathon, we can simplify 3km to ~0.027 degrees
        clustering = DBSCAN(eps=0.027, min_samples=1).fit(df[['lat', 'lng']])
        df['cluster'] = clustering.labels_

        # 3. Group by cluster and calculate totals
        summary = df.groupby('cluster').agg({
            'weight_kg': 'sum',
            'lat': 'mean',
            'lng': 'mean'
        }).reset_index()

        return {"clusters": summary.to_dict('records')}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))