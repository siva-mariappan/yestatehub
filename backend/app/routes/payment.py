from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from ..database import get_db
from ..firebase_auth import verify_firebase_token
from ..models.payment import PaymentCreate, PaymentUpdate
from datetime import datetime, timezone

router = APIRouter(prefix="/api/payments", tags=["Payments"])


def _doc(d: dict) -> dict:
    d["id"] = str(d.pop("_id"))
    for k in ("created_at", "updated_at", "completed_at"):
        if d.get(k) and hasattr(d[k], "isoformat"):
            d[k] = d[k].isoformat()
    return d


@router.post("/")
async def create_payment(data: PaymentCreate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    now = datetime.now(timezone.utc)
    doc = {**data.dict(), "payer_uid": user["uid"], "payer_name": user["name"],
           "status": "pending", "transaction_id": "", "gateway_response": {},
           "refund_amount": 0, "refund_reason": "", "created_at": now, "updated_at": now}
    result = await db.payments.insert_one(doc)
    doc["_id"] = result.inserted_id
    return _doc(doc)


@router.get("/")
async def list_payments(status: str = "", skip: int = 0, limit: int = 50, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    query = {"payer_uid": user["uid"]}
    if status:
        query["status"] = status
    cursor = db.payments.find(query).sort("created_at", -1).skip(skip).limit(limit)
    return [_doc(d) async for d in cursor]


@router.get("/{payment_id}")
async def get_payment(payment_id: str, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.payments.find_one({"_id": ObjectId(payment_id)})
    if not doc:
        raise HTTPException(404, "Payment not found")
    if doc["payer_uid"] != user["uid"]:
        raise HTTPException(403, "Not authorized")
    return _doc(doc)


@router.put("/{payment_id}")
async def update_payment(payment_id: str, data: PaymentUpdate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.payments.find_one({"_id": ObjectId(payment_id)})
    if not doc:
        raise HTTPException(404, "Payment not found")
    updates = {k: v for k, v in data.dict().items() if v is not None}
    updates["updated_at"] = datetime.now(timezone.utc)
    if updates.get("status") == "completed":
        updates["completed_at"] = datetime.now(timezone.utc)
    await db.payments.update_one({"_id": ObjectId(payment_id)}, {"$set": updates})
    updated = await db.payments.find_one({"_id": ObjectId(payment_id)})
    return _doc(updated)
