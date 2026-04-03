from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pandas as pd
import numpy as np
from sklearn.cluster import DBSCAN
from supabase import create_client, Client
import os
from dotenv import load_dotenv

# Load Supabase Keys
load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    print("Warning: Supabase credentials missing!")

supabase: Client | None = None
if SUPABASE_URL and SUPABASE_KEY:
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

app = FastAPI(title="KebunKomuniti Inventory & Spatial Service")

class LocationRequest(BaseModel):
    latitude: float
    longitude: float
    radius_km: float = 3.0

@app.get("/")
def read_root():
    return {"status": "Inventory Spatial Service is running!"}

@app.post("/api/data/surplus")
def get_clustered_surplus(request: LocationRequest):
    if not supabase:
        raise HTTPException(status_code=500, detail="Database connection failed.")

    try:
        # 1. Call the PostGIS Geo-Fencing function Shaa built in Supabase
        # This automatically filters out anything beyond the walkable radius
        response = supabase.rpc(
            "get_nearby_produce", 
            {
                "user_lat": request.latitude, 
                "user_lon": request.longitude, 
                "radius_meters": request.radius_km * 1000
            }
        ).execute()
        
        raw_data = response.data
        if not raw_data:
            return {"clusters": [], "message": "No surplus found in this radius."}

        # 2. Extract coordinates (Assuming Supabase returns lat/lon from the geography point)
        # Note: If Supabase returns WKB, you'd parse it here. For simplicity, assuming JSON format:
        parsed_data = []
        for item in raw_data:
            # Extract coordinates from the GeoJSON representation of PostGIS POINT
            coords = item['location']['coordinates'] 
            parsed_data.append({
                "item_name": item["item_name"],
                "quantity_kg": float(item["quantity_kg"]),
                "longitude": coords[0],
                "latitude": coords[1]
            })

        # 3. The DBSCAN Clustering Logic
        df = pd.DataFrame(parsed_data)
        coords = np.radians(df[['latitude', 'longitude']])
        
        earth_radius = 6371.0
        epsilon = request.radius_km / earth_radius
        
        db = DBSCAN(eps=epsilon, min_samples=1, algorithm='ball_tree', metric='haversine').fit(coords)
        df['cluster'] = db.labels_
        
        # 4. Aggregate the individual neighborhood items into Bulk Hubs
        aggregated = df.groupby('cluster').agg({
            'item_name': lambda x: ' + '.join(set(x)),
            'quantity_kg': 'sum',
            'latitude': 'mean',
            'longitude': 'mean'
        }).reset_index()
        
        return {
            "success": True,
            "total_hubs_found": len(aggregated),
            "clusters": aggregated.to_dict(orient='records')
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
