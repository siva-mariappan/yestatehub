from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from ..database import get_db
from ..firebase_auth import verify_firebase_token
from ..models.review import ReviewCreate, ReviewUpdate
from datetime import datetime, timezone

router = APIRouter(prefix="/api/reviews", tags=["Reviews"])


def _doc(d: dict) -> dict:
    d["id"] = str(d.pop("_id"))
    for k in ("created_at", "updated_at"):
        if d.get(k) and hasattr(d[k], "isoformat"):
            d[k] = d[k].isoformat()
    return d


@router.post("/")
async def create_review(data: ReviewCreate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    existing = await db.reviews.find_one({
        "reviewer_uid": user["uid"], "target_type": data.target_type, "target_id": data.target_id
    })
    if existing:
        raise HTTPException(400, "You have already reviewed this item")
    now = datetime.now(timezone.utc)
    doc = {**data.dict(), "reviewer_uid": user["uid"], "reviewer_name": user["name"],
           "is_flagged": False, "admin_reply": "", "created_at": now, "updated_at": now}
    result = await db.reviews.insert_one(doc)
    doc["_id"] = result.inserted_id
    return _doc(doc)


@router.get("/")
async def list_reviews(target_type: str = "", target_id: str = "", skip: int = 0, limit: int = 50):
    db = get_db()
    query = {}
    if target_type:
        query["target_type"] = target_type
    if target_id:
        query["target_id"] = target_id
    cursor = db.reviews.find(query).sort("created_at", -1).skip(skip).limit(limit)
    return [_doc(d) async for d in cursor]


@router.get("/my")
async def my_reviews(user: dict = Depends(verify_firebase_token)):
    db = get_db()
    cursor = db.reviews.find({"reviewer_uid": user["uid"]}).sort("created_at", -1)
    return [_doc(d) async for d in cursor]


@router.get("/{review_id}")
async def get_review(review_id: str):
    db = get_db()
    doc = await db.reviews.find_one({"_id": ObjectId(review_id)})
    if not doc:
        raise HTTPException(404, "Review not found")
    return _doc(doc)


@router.put("/{review_id}")
async def update_review(review_id: str, data: ReviewUpdate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.reviews.find_one({"_id": ObjectId(review_id)})
    if not doc:
        raise HTTPException(404, "Review not found")
    if doc["reviewer_uid"] != user["uid"]:
        raise HTTPException(403, "Not authorized")
    updates = {k: v for k, v in data.dict().items() if v is not None}
    updates["updated_at"] = datetime.now(timezone.utc)
    await db.reviews.update_one({"_id": ObjectId(review_id)}, {"$set": updates})
    updated = await db.reviews.find_one({"_id": ObjectId(review_id)})
    return _doc(updated)


@router.delete("/{review_id}")
async def delete_review(review_id: str, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.reviews.find_one({"_id": ObjectId(review_id)})
    if not doc:
        raise HTTPException(404, "Review not found")
    if doc["reviewer_uid"] != user["uid"]:
        raise HTTPException(403, "Not authorized")
    await db.reviews.delete_one({"_id": ObjectId(review_id)})
    return {"message": "Review deleted"}
