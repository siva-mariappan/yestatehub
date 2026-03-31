from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from ..database import get_db
from ..firebase_auth import verify_firebase_token
from ..models.service import ServiceCreate, ServiceUpdate
from datetime import datetime, timezone

router = APIRouter(prefix="/api/services", tags=["Services"])


def _doc(d: dict) -> dict:
    d["id"] = str(d.pop("_id"))
    for k in ("created_at", "updated_at"):
        if d.get(k):
            d[k] = d[k].isoformat()
    return d


@router.post("/")
async def create_service(data: ServiceCreate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    now = datetime.now(timezone.utc)
    doc = {**data.dict(), "provider_uid": user["uid"], "provider_name": user["name"],
           "avg_rating": 0, "total_bookings": 0, "created_at": now, "updated_at": now}
    result = await db.services.insert_one(doc)
    doc["_id"] = result.inserted_id
    return _doc(doc)


@router.get("/")
async def list_services(category: str = "", city: str = "", skip: int = 0, limit: int = 50):
    db = get_db()
    query = {"is_active": True}
    if category:
        query["category"] = {"$regex": category, "$options": "i"}
    if city:
        query["city"] = {"$regex": city, "$options": "i"}
    cursor = db.services.find(query).sort("created_at", -1).skip(skip).limit(limit)
    return [_doc(d) async for d in cursor]


@router.get("/my")
async def my_services(user: dict = Depends(verify_firebase_token)):
    db = get_db()
    cursor = db.services.find({"provider_uid": user["uid"]}).sort("created_at", -1)
    return [_doc(d) async for d in cursor]


@router.get("/{service_id}")
async def get_service(service_id: str):
    db = get_db()
    doc = await db.services.find_one({"_id": ObjectId(service_id)})
    if not doc:
        raise HTTPException(404, "Service not found")
    return _doc(doc)


@router.put("/{service_id}")
async def update_service(service_id: str, data: ServiceUpdate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.services.find_one({"_id": ObjectId(service_id)})
    if not doc:
        raise HTTPException(404, "Service not found")
    if doc["provider_uid"] != user["uid"]:
        raise HTTPException(403, "Not authorized")
    updates = {k: v for k, v in data.dict().items() if v is not None}
    updates["updated_at"] = datetime.now(timezone.utc)
    await db.services.update_one({"_id": ObjectId(service_id)}, {"$set": updates})
    updated = await db.services.find_one({"_id": ObjectId(service_id)})
    return _doc(updated)


@router.delete("/{service_id}")
async def delete_service(service_id: str, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.services.find_one({"_id": ObjectId(service_id)})
    if not doc:
        raise HTTPException(404, "Service not found")
    if doc["provider_uid"] != user["uid"]:
        raise HTTPException(403, "Not authorized")
    await db.services.delete_one({"_id": ObjectId(service_id)})
    return {"message": "Service deleted"}
