from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pandas as pd
import numpy as np
from sklearn.cluster import DBSCAN
from supabase import create_client, Client
import os
from dotenv import load_dotenv
from typing import List, Optional

# Load Supabase Keys
load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

supabase: Client | None = None
if SUPABASE_URL and SUPABASE_KEY:
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

app = FastAPI(title="KebunKomuniti Inventory & Spatial Service")

# --- Models ---
class LocationRequest(BaseModel):
    latitude: float
    longitude: float
    radius_km: float = 3.0

class OrderRequest(BaseModel):
    listing_id: int
    buyer_name: str
    delivery_method: str # "Pickup" or "Delivery"

class SurplusItem(BaseModel):
    item_name: str
    quantity_kg: float
    latitude: float
    longitude: float

# --- Endpoints ---

@app.get("/")
def read_root():
    return {"status": "Inventory Spatial Service is running!"}

@app.get("/api/data/history/{user_name}")
async def get_order_history(user_name: str):
    if not supabase: return {"success": False, "orders": []}
    try:
        response = supabase.table("orders").select("*, surplus(*)").or_(f"buyer_name.eq.{user_name},seller_name.eq.{user_name}").execute()
        return {"success": True, "orders": response.data}
    except:
        return {"success": False, "orders": []}

@app.post("/api/data/order")
async def create_order(order: OrderRequest):
    if not supabase: raise HTTPException(status_code=500, detail="Database connection failed.")
    try:
        data = {
            "listing_id": order.listing_id,
            "buyer_name": order.buyer_name,
            "status": "Pending",
            "delivery_method": order.delivery_method
        }
        supabase.table("orders").insert(data).execute()
        return {"success": True, "message": "Order placed successfully!"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/data/add")
def add_surplus_item(item: SurplusItem):
    if not supabase: raise HTTPException(status_code=500, detail="Database connection failed.")
    try:
        data = {
            "item_name": item.item_name,
            "quantity_kg": item.quantity_kg,
            "location": f"POINT({item.longitude} {item.latitude})"
        }
        supabase.table("surplus").insert(data).execute()
        return {"success": True, "message": "Item listed successfully!"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/data/surplus")
def get_clustered_surplus(request: LocationRequest):
    if not supabase: raise HTTPException(status_code=500, detail="Database connection failed.")
    try:
        # 1. PostGIS Geo-Fencing
        response = supabase.rpc("get_nearby_produce", {"user_lat": request.latitude, "user_lon": request.longitude, "radius_meters": request.radius_km * 1000}).execute()
        raw_data = response.data
        if not raw_data: return {"clusters": [], "message": "No surplus found."}

        # 2. Parse Coordinates
        parsed_data = []
        for item in raw_data:
            coords = item['location']['coordinates'] 
            parsed_data.append({"id": item["id"], "item_name": item["item_name"], "quantity_kg": float(item["quantity_kg"]), "longitude": coords[0], "latitude": coords[1]})

        # 3. DBSCAN Clustering
        df = pd.DataFrame(parsed_data)
        coords_rad = np.radians(df[['latitude', 'longitude']])
        db = DBSCAN(eps=request.radius_km/6371.0, min_samples=1, algorithm='ball_tree', metric='haversine').fit(coords_rad)
        df['cluster'] = db.labels_
        
        # 4. Aggregate
        aggregated = df.groupby('cluster').agg({'id': 'first', 'item_name': lambda x: ' + '.join(set(x)), 'quantity_kg': 'sum', 'latitude': 'mean', 'longitude': 'mean'}).reset_index()
        return {"success": True, "clusters": aggregated.to_dict(orient='records')}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
