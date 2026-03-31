from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from ..database import get_db
from ..firebase_auth import verify_firebase_token
from ..models.sp_profile import SPProfileCreate, SPProfileUpdate
from datetime import datetime, timezone

router = APIRouter(prefix="/api/sp-profiles", tags=["Service Provider Profiles"])


def _doc_to_response(doc: dict) -> dict:
    doc["id"] = str(doc.pop("_id"))
    for k in ("created_at", "updated_at"):
        if doc.get(k):
            doc[k] = doc[k].isoformat()
    return doc


@router.post("/")
async def create_sp_profile(data: SPProfileCreate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    existing = await db.sp_profiles.find_one({"uid": user["uid"]})
    if existing:
        raise HTTPException(400, "Profile already exists. Use PUT to update.")
    now = datetime.now(timezone.utc)
    doc = {**data.dict(), "uid": user["uid"], "owner_name": user["name"], "owner_email": user["email"],
           "avg_rating": 0, "total_reviews": 0, "total_bookings": 0, "total_earnings": 0,
           "created_at": now, "updated_at": now}
    result = await db.sp_profiles.insert_one(doc)
    doc["_id"] = result.inserted_id
    return _doc_to_response(doc)


@router.get("/")
async def list_sp_profiles(city: str = "", category: str = "", is_active: bool = True, skip: int = 0, limit: int = 50):
    db = get_db()
    query = {"is_active": is_active}
    if city:
        query["city"] = {"$regex": city, "$options": "i"}
    if category:
        query["service_category"] = {"$regex": category, "$options": "i"}
    cursor = db.sp_profiles.find(query).sort("created_at", -1).skip(skip).limit(limit)
    return [_doc_to_response(d) async for d in cursor]


@router.get("/me")
async def get_my_sp_profile(user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.sp_profiles.find_one({"uid": user["uid"]})
    if not doc:
        raise HTTPException(404, "Service provider profile not found")
    return _doc_to_response(doc)


@router.get("/{profile_id}")
async def get_sp_profile(profile_id: str):
    db = get_db()
    doc = await db.sp_profiles.find_one({"_id": ObjectId(profile_id)})
    if not doc:
        raise HTTPException(404, "Profile not found")
    return _doc_to_response(doc)


@router.put("/{profile_id}")
async def update_sp_profile(profile_id: str, data: SPProfileUpdate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.sp_profiles.find_one({"_id": ObjectId(profile_id)})
    if not doc:
        raise HTTPException(404, "Profile not found")
    if doc["uid"] != user["uid"]:
        raise HTTPException(403, "Not authorized")
    updates = {k: v for k, v in data.dict().items() if v is not None}
    updates["updated_at"] = datetime.now(timezone.utc)
    await db.sp_profiles.update_one({"_id": ObjectId(profile_id)}, {"$set": updates})
    updated = await db.sp_profiles.find_one({"_id": ObjectId(profile_id)})
    return _doc_to_response(updated)


@router.delete("/{profile_id}")
async def delete_sp_profile(profile_id: str, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.sp_profiles.find_one({"_id": ObjectId(profile_id)})
    if not doc:
        raise HTTPException(404, "Profile not found")
    if doc["uid"] != user["uid"]:
        raise HTTPException(403, "Not authorized")
    await db.sp_profiles.delete_one({"_id": ObjectId(profile_id)})
    return {"message": "Profile deleted"}
