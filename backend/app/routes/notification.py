from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from ..database import get_db
from ..firebase_auth import verify_firebase_token
from ..models.notification import NotificationCreate
from datetime import datetime, timezone

router = APIRouter(prefix="/api/notifications", tags=["Notifications"])


def _doc(d: dict) -> dict:
    d["id"] = str(d.pop("_id"))
    for k in ("created_at",):
        if d.get(k) and hasattr(d[k], "isoformat"):
            d[k] = d[k].isoformat()
    return d


@router.post("/")
async def create_notification(data: NotificationCreate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    now = datetime.now(timezone.utc)
    doc = {**data.dict(), "uid": user["uid"], "is_read": False, "created_at": now}
    result = await db.notifications.insert_one(doc)
    doc["_id"] = result.inserted_id
    return _doc(doc)


@router.get("/")
async def list_notifications(skip: int = 0, limit: int = 50, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    cursor = db.notifications.find({"uid": user["uid"]}).sort("created_at", -1).skip(skip).limit(limit)
    return [_doc(d) async for d in cursor]


@router.get("/unread-count")
async def unread_count(user: dict = Depends(verify_firebase_token)):
    db = get_db()
    count = await db.notifications.count_documents({"uid": user["uid"], "is_read": False})
    return {"count": count}


@router.put("/{notification_id}/read")
async def mark_read(notification_id: str, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    result = await db.notifications.update_one(
        {"_id": ObjectId(notification_id), "uid": user["uid"]},
        {"$set": {"is_read": True}}
    )
    if result.matched_count == 0:
        raise HTTPException(404, "Notification not found")
    return {"message": "Marked as read"}


@router.put("/read-all")
async def mark_all_read(user: dict = Depends(verify_firebase_token)):
    db = get_db()
    await db.notifications.update_many(
        {"uid": user["uid"], "is_read": False},
        {"$set": {"is_read": True}}
    )
    return {"message": "All notifications marked as read"}


@router.delete("/{notification_id}")
async def delete_notification(notification_id: str, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    result = await db.notifications.delete_one({"_id": ObjectId(notification_id), "uid": user["uid"]})
    if result.deleted_count == 0:
        raise HTTPException(404, "Notification not found")
    return {"message": "Notification deleted"}
