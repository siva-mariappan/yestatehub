from fastapi import APIRouter, Depends, HTTPException
from bson import ObjectId
from ..database import get_db
from ..firebase_auth import verify_firebase_token
from ..models.favorite import FavoriteCreate
from datetime import datetime, timezone

router = APIRouter(prefix="/api/favorites", tags=["Favorites"])


def _doc(d: dict) -> dict:
    d["id"] = str(d.pop("_id"))
    for k in ("created_at",):
        if d.get(k) and hasattr(d[k], "isoformat"):
            d[k] = d[k].isoformat()
    return d


@router.post("/")
async def add_favorite(data: FavoriteCreate, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    existing = await db.favorites.find_one({
        "uid": user["uid"], "target_type": data.target_type, "target_id": data.target_id
    })
    if existing:
        raise HTTPException(400, "Already in favorites")
    now = datetime.now(timezone.utc)
    doc = {**data.dict(), "uid": user["uid"], "created_at": now}
    result = await db.favorites.insert_one(doc)
    doc["_id"] = result.inserted_id
    return _doc(doc)


@router.get("/")
async def list_favorites(target_type: str = "", user: dict = Depends(verify_firebase_token)):
    db = get_db()
    query = {"uid": user["uid"]}
    if target_type:
        query["target_type"] = target_type
    cursor = db.favorites.find(query).sort("created_at", -1)
    return [_doc(d) async for d in cursor]


@router.get("/check")
async def check_favorite(target_type: str, target_id: str, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    doc = await db.favorites.find_one({
        "uid": user["uid"], "target_type": target_type, "target_id": target_id
    })
    return {"is_favorite": doc is not None}


@router.delete("/{favorite_id}")
async def remove_favorite(favorite_id: str, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    result = await db.favorites.delete_one({"_id": ObjectId(favorite_id), "uid": user["uid"]})
    if result.deleted_count == 0:
        raise HTTPException(404, "Favorite not found")
    return {"message": "Removed from favorites"}


@router.delete("/by-target/{target_type}/{target_id}")
async def remove_favorite_by_target(target_type: str, target_id: str, user: dict = Depends(verify_firebase_token)):
    db = get_db()
    result = await db.favorites.delete_one({
        "uid": user["uid"], "target_type": target_type, "target_id": target_id
    })
    if result.deleted_count == 0:
        raise HTTPException(404, "Favorite not found")
    return {"message": "Removed from favorites"}
