from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from ..database import get_db
from ..firebase_auth import verify_firebase_token
from ..models.location_tracking import LocationUpdate
from datetime import datetime, timezone

router = APIRouter(prefix="/api/location", tags=["Location Tracking"])


def _doc(d: dict) -> dict:
    d["id"] = str(d.pop("_id"))
    for k in ("timestamp",):
        if d.get(k) and hasattr(d[k], "isoformat"):
            d[k] = d[k].isoformat()
    return d


@router.post("/update")
async def update_location(data: LocationUpdate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    now = datetime.now(timezone.utc)
    doc = {**data.dict(), "uid": user["uid"], "timestamp": now}
    await db.location_tracking.update_one(
        {"uid": user["uid"]},
        {"$set": doc},
        upsert=True
    )
    return {"message": "Location updated"}


@router.get("/me")
async def get_my_location(user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.location_tracking.find_one({"uid": user["uid"]})
    if not doc:
        raise HTTPException(404, "No location data found")
    return _doc(doc)


@router.get("/provider/{provider_uid}")
async def get_provider_location(provider_uid: str, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.location_tracking.find_one({"uid": provider_uid})
    if not doc:
        raise HTTPException(404, "Provider location not found")
    return _doc(doc)


@router.get("/nearby")
async def get_nearby_providers(latitude: float, longitude: float, radius_km: float = 10, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    # Simple bounding box filter (approximate)
    lat_diff = radius_km / 111.0
    lon_diff = radius_km / (111.0 * abs(max(0.01, abs(latitude))) if latitude != 0 else 111.0)
    query = {
        "latitude": {"$gte": latitude - lat_diff, "$lte": latitude + lat_diff},
        "longitude": {"$gte": longitude - lon_diff, "$lte": longitude + lon_diff},
        "uid": {"$ne": user["uid"]}
    }
    cursor = db.location_tracking.find(query)
    return [_doc(d) async for d in cursor]
