from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from ..database import get_db
from ..firebase_auth import verify_firebase_token
from ..models.verification import VerificationCreate, VerificationUpdate
from datetime import datetime, timezone

router = APIRouter(prefix="/api/verifications", tags=["Verifications"])


def _doc(d: dict) -> dict:
    d["id"] = str(d.pop("_id"))
    for k in ("created_at", "updated_at", "verified_at"):
        if d.get(k) and hasattr(d[k], "isoformat"):
            d[k] = d[k].isoformat()
    return d


@router.post("/")
async def create_verification(data: VerificationCreate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    existing = await db.verifications.find_one({"uid": user["uid"], "type": data.type})
    if existing:
        raise HTTPException(400, f"Verification for {data.type} already submitted. Use PUT to update.")
    now = datetime.now(timezone.utc)
    doc = {**data.dict(), "uid": user["uid"], "user_name": user["name"],
           "status": "pending", "admin_notes": "", "verified_by": "",
           "created_at": now, "updated_at": now}
    result = await db.verifications.insert_one(doc)
    doc["_id"] = result.inserted_id
    return _doc(doc)


@router.get("/")
async def list_verifications(status: str = "", skip: int = 0, limit: int = 50, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    query = {"uid": user["uid"]}
    if status:
        query["status"] = status
    cursor = db.verifications.find(query).sort("created_at", -1).skip(skip).limit(limit)
    return [_doc(d) async for d in cursor]


@router.get("/admin/all")
async def admin_list_verifications(status: str = "", skip: int = 0, limit: int = 50, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    query = {}
    if status:
        query["status"] = status
    cursor = db.verifications.find(query).sort("created_at", -1).skip(skip).limit(limit)
    return [_doc(d) async for d in cursor]


@router.get("/{verification_id}")
async def get_verification(verification_id: str, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.verifications.find_one({"_id": ObjectId(verification_id)})
    if not doc:
        raise HTTPException(404, "Verification not found")
    return _doc(doc)


@router.put("/{verification_id}")
async def update_verification(verification_id: str, data: VerificationUpdate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.verifications.find_one({"_id": ObjectId(verification_id)})
    if not doc:
        raise HTTPException(404, "Verification not found")
    updates = {k: v for k, v in data.dict().items() if v is not None}
    updates["updated_at"] = datetime.now(timezone.utc)
    if updates.get("status") == "approved":
        updates["verified_at"] = datetime.now(timezone.utc)
    await db.verifications.update_one({"_id": ObjectId(verification_id)}, {"$set": updates})
    updated = await db.verifications.find_one({"_id": ObjectId(verification_id)})
    return _doc(updated)
