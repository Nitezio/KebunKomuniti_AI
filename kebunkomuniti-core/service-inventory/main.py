from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"status": "Inventory Placeholder is Running!"}
