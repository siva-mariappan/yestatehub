from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from ..database import get_db
from ..firebase_auth import verify_firebase_token
from ..models.booking import BookingCreate, BookingUpdate
from datetime import datetime, timezone

router = APIRouter(prefix="/api/bookings", tags=["Bookings"])


def _doc(d: dict) -> dict:
    d["id"] = str(d.pop("_id"))
    for k in ("created_at", "updated_at", "completion_date"):
        if d.get(k) and hasattr(d[k], "isoformat"):
            d[k] = d[k].isoformat()
    return d


@router.post("/")
async def create_booking(data: BookingCreate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    now = datetime.now(timezone.utc)
    doc = {**data.dict(), "customer_uid": user["uid"], "customer_name": user["name"],
           "customer_email": user["email"], "status": "pending", "provider_notes": "",
           "rating": 0, "review_text": "", "cancellation_reason": "",
           "created_at": now, "updated_at": now}
    result = await db.bookings.insert_one(doc)
    doc["_id"] = result.inserted_id
    return _doc(doc)


@router.get("/")
async def list_bookings(status: str = "", skip: int = 0, limit: int = 50, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    query = {"$or": [{"customer_uid": user["uid"]}, {"provider_uid": user["uid"]}]}
    if status:
        query["status"] = status
    cursor = db.bookings.find(query).sort("created_at", -1).skip(skip).limit(limit)
    return [_doc(d) async for d in cursor]


@router.get("/{booking_id}")
async def get_booking(booking_id: str, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.bookings.find_one({"_id": ObjectId(booking_id)})
    if not doc:
        raise HTTPException(404, "Booking not found")
    if doc["customer_uid"] != user["uid"] and doc["provider_uid"] != user["uid"]:
        raise HTTPException(403, "Not authorized")
    return _doc(doc)


@router.put("/{booking_id}")
async def update_booking(booking_id: str, data: BookingUpdate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.bookings.find_one({"_id": ObjectId(booking_id)})
    if not doc:
        raise HTTPException(404, "Booking not found")
    if doc["customer_uid"] != user["uid"] and doc["provider_uid"] != user["uid"]:
        raise HTTPException(403, "Not authorized")
    updates = {k: v for k, v in data.dict().items() if v is not None}
    updates["updated_at"] = datetime.now(timezone.utc)
    await db.bookings.update_one({"_id": ObjectId(booking_id)}, {"$set": updates})
    updated = await db.bookings.find_one({"_id": ObjectId(booking_id)})
    return _doc(updated)


@router.delete("/{booking_id}")
async def cancel_booking(booking_id: str, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.bookings.find_one({"_id": ObjectId(booking_id)})
    if not doc:
        raise HTTPException(404, "Booking not found")
    if doc["customer_uid"] != user["uid"]:
        raise HTTPException(403, "Only customer can cancel")
    await db.bookings.update_one({"_id": ObjectId(booking_id)}, {"$set": {"status": "cancelled", "updated_at": datetime.now(timezone.utc)}})
    return {"message": "Booking cancelled"}
