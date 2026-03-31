from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional, List
from datetime import datetime, timezone
from bson import ObjectId
from ..database import get_db
from ..firebase_auth import verify_firebase_token
from ..models.advertisement import AdvertisementCreate, AdvertisementUpdate, AdvertisementResponse

router = APIRouter(prefix="/api/advertisements", tags=["Advertisements"])

ADMIN_EMAIL = "yestatehub@gmail.com"


def _doc_to_response(doc: dict) -> dict:
    doc["id"] = str(doc.pop("_id"))
    for field in ["created_at", "updated_at", "start_date", "end_date"]:
        val = doc.get(field)
        if val and hasattr(val, "isoformat"):
            doc[field] = val.isoformat()
        elif val is None:
            doc[field] = ""
    return doc


async def _require_admin(user: dict = Depends(verify_firebase_token)):
    """Only admin can manage ads."""
    if user.get("email", "").lower() != ADMIN_EMAIL:
        raise HTTPException(status_code=403, detail="Admin access required")
    return user


# ─── Public endpoint: get active ads for display ────────────────

@router.get("/active", response_model=List[AdvertisementResponse])
async def get_active_ads(
    placement: Optional[str] = Query(None, description="Filter by placement (home_carousel, search_banner, etc.)"),
):
    """Get active advertisements for frontend display (public, no auth)."""
    db = get_db()
    now = datetime.now(timezone.utc)

    # Match ads that are active; end_date filter is lenient —
    # include ads with no end_date or end_date in the future.
    query = {"status": "active"}
    if placement:
        query["placement"] = placement

    cursor = db.advertisements.find(query).sort("priority", 1).limit(20)
    ads = []
    async for doc in cursor:
        # Skip expired ads (but allow ads with no end_date)
        end_date = doc.get("end_date")
        if end_date and isinstance(end_date, datetime):
            # Normalize both to UTC-aware for comparison
            if end_date.tzinfo is None:
                end_date = end_date.replace(tzinfo=timezone.utc)
            if end_date < now:
                continue
        # Track impression
        await db.advertisements.update_one(
            {"_id": doc["_id"]},
            {"$inc": {"impressions": 1}},
        )
        doc["impressions"] = doc.get("impressions", 0) + 1
        try:
            ads.append(_doc_to_response(doc))
        except Exception as e:
            # Skip ads that fail response conversion rather than crashing
            print(f"Skipping ad {doc.get('_id')}: {e}")
    return ads


@router.post("/{ad_id}/click")
async def track_click(ad_id: str):
    """Track an ad click (public)."""
    db = get_db()
    try:
        result = await db.advertisements.update_one(
            {"_id": ObjectId(ad_id)},
            {"$inc": {"clicks": 1}},
        )
        if result.modified_count == 0:
            raise HTTPException(status_code=404, detail="Ad not found")
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid ad ID")
    return {"message": "Click tracked"}


# ─── Admin endpoints: CRUD ──────────────────────────────────────

@router.get("/", response_model=List[AdvertisementResponse])
async def list_all_ads(
    user: dict = Depends(_require_admin),
    status: Optional[str] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
):
    """List all ads (admin only)."""
    db = get_db()
    query = {}
    if status:
        query["status"] = status
    cursor = db.advertisements.find(query).sort("created_at", -1).skip(skip).limit(limit)
    ads = []
    async for doc in cursor:
        ads.append(_doc_to_response(doc))
    return ads


@router.post("/", response_model=AdvertisementResponse)
async def create_ad(
    data: AdvertisementCreate,
    user: dict = Depends(_require_admin),
):
    """Create a new advertisement (admin only)."""
    db = get_db()
    now = datetime.now(timezone.utc)

    doc = data.model_dump()
    # Parse dates
    for date_field in ["start_date", "end_date"]:
        if doc[date_field]:
            try:
                doc[date_field] = datetime.fromisoformat(doc[date_field])
            except ValueError:
                doc[date_field] = now
        else:
            doc[date_field] = now if date_field == "start_date" else now

    doc.update({
        "impressions": 0,
        "clicks": 0,
        "created_by": user["uid"],
        "created_at": now,
        "updated_at": now,
    })

    result = await db.advertisements.insert_one(doc)
    doc["_id"] = result.inserted_id
    return _doc_to_response(doc)


@router.get("/{ad_id}", response_model=AdvertisementResponse)
async def get_ad(ad_id: str, user: dict = Depends(_require_admin)):
    """Get single ad detail (admin only)."""
    db = get_db()
    try:
        doc = await db.advertisements.find_one({"_id": ObjectId(ad_id)})
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid ad ID")
    if not doc:
        raise HTTPException(status_code=404, detail="Ad not found")
    return _doc_to_response(doc)


@router.put("/{ad_id}", response_model=AdvertisementResponse)
async def update_ad(
    ad_id: str,
    data: AdvertisementUpdate,
    user: dict = Depends(_require_admin),
):
    """Update an advertisement (admin only)."""
    db = get_db()
    try:
        doc = await db.advertisements.find_one({"_id": ObjectId(ad_id)})
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid ad ID")
    if not doc:
        raise HTTPException(status_code=404, detail="Ad not found")

    update_fields = {k: v for k, v in data.model_dump().items() if v is not None}
    update_fields["updated_at"] = datetime.now(timezone.utc)

    # Parse dates if provided
    for date_field in ["start_date", "end_date"]:
        if date_field in update_fields and isinstance(update_fields[date_field], str):
            try:
                update_fields[date_field] = datetime.fromisoformat(update_fields[date_field])
            except ValueError:
                pass

    await db.advertisements.update_one(
        {"_id": ObjectId(ad_id)},
        {"$set": update_fields},
    )
    updated = await db.advertisements.find_one({"_id": ObjectId(ad_id)})
    return _doc_to_response(updated)


@router.delete("/{ad_id}")
async def delete_ad(ad_id: str, user: dict = Depends(_require_admin)):
    """Delete an advertisement (admin only)."""
    db = get_db()
    try:
        result = await db.advertisements.delete_one({"_id": ObjectId(ad_id)})
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid ad ID")
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Ad not found")
    return {"message": "Advertisement deleted"}
