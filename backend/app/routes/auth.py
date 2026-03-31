from fastapi import APIRouter, Depends
from ..database import get_db
from ..firebase_auth import verify_firebase_token
from datetime import datetime, timezone

router = APIRouter(prefix="/api/auth", tags=["Auth"])

@router.post("/sync")
async def sync_user(user: dict = Depends(verify_firebase_token)):
    """Sync Firebase user to MongoDB after login. Creates or updates user doc."""
    db = get_db()
    now = datetime.now(timezone.utc)

    # Use upsert to avoid DuplicateKeyError on email unique index
    result = await db.users.update_one(
        {"uid": user["uid"]},
        {
            "$set": {
                "email": user["email"],
                "name": user["name"],
                "picture": user["picture"],
                "last_login": now,
            },
            "$setOnInsert": {
                "uid": user["uid"],
                "role": "user",
                "phone": "",
                "created_at": now,
            },
        },
        upsert=True,
    )

    is_new = result.upserted_id is not None
    return {
        "message": "User created" if is_new else "User synced",
        "uid": user["uid"],
        "is_new": is_new,
    }

@router.get("/me")
async def get_me(user: dict = Depends(verify_firebase_token)):
    """Get current user profile from MongoDB."""
    db = get_db()
    doc = await db.users.find_one({"uid": user["uid"]})
    if doc:
        doc["id"] = str(doc.pop("_id"))
        doc["created_at"] = doc.get("created_at", "").isoformat() if doc.get("created_at") else ""
        doc["last_login"] = doc.get("last_login", "").isoformat() if doc.get("last_login") else ""
        return doc
    return {"uid": user["uid"], "email": user["email"], "name": user["name"]}
