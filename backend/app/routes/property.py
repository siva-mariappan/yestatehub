from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional, List
from datetime import datetime, timezone
from bson import ObjectId
from ..database import get_db
from ..firebase_auth import verify_firebase_token
from ..models.property import PropertyCreate, PropertyResponse, PropertyUpdate

router = APIRouter(prefix="/api/properties", tags=["Properties"])

def _doc_to_response(doc: dict) -> dict:
    """Convert MongoDB document to response dict."""
    doc["id"] = str(doc.pop("_id"))
    # Safely convert datetime fields to ISO strings
    for field in ["created_at", "updated_at"]:
        val = doc.get(field)
        if val and hasattr(val, "isoformat"):
            doc[field] = val.isoformat()
        elif val is None:
            doc[field] = ""
        else:
            doc[field] = str(val)
    return doc

@router.post("/", response_model=PropertyResponse)
async def create_property(
    property_data: PropertyCreate,
    user: dict = Depends(verify_firebase_token),
):
    """Add a new property listing."""
    db = get_db()
    now = datetime.now(timezone.utc)

    doc = property_data.model_dump()
    doc.update({
        "owner_uid": user["uid"],
        "owner_name": user["name"],
        "owner_email": user["email"],
        "is_verified": False,
        "is_rera_approved": False,
        "no_brokerage": doc.get("listed_by") == "owner",
        "views": 0,
        "enquiries": 0,
        "created_at": now,
        "updated_at": now,
    })

    # Calculate price per sqft
    if doc["area_sqft"] > 0 and not doc.get("price_per_sqft"):
        doc["price_per_sqft"] = round(doc["price"] / doc["area_sqft"], 2)

    result = await db.properties.insert_one(doc)
    doc["_id"] = result.inserted_id

    return _doc_to_response(doc)

@router.get("/", response_model=List[PropertyResponse])
async def list_properties(
    city: Optional[str] = None,
    transaction_type: Optional[str] = None,
    property_type: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    bedrooms: Optional[int] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
):
    """List properties with filters (public — no auth required)."""
    db = get_db()
    query = {}

    if city:
        query["city"] = {"$regex": city, "$options": "i"}
    if transaction_type:
        query["transaction_type"] = transaction_type
    if property_type:
        query["property_type"] = property_type
    if min_price is not None:
        query.setdefault("price", {})["$gte"] = min_price
    if max_price is not None:
        query.setdefault("price", {})["$lte"] = max_price
    if bedrooms is not None:
        query["bedrooms"] = bedrooms

    cursor = db.properties.find(query).sort("created_at", -1).skip(skip).limit(limit)
    properties = []
    async for doc in cursor:
        try:
            properties.append(_doc_to_response(doc))
        except Exception as e:
            print(f"Skipping property {doc.get('_id')}: {e}")

    return properties

@router.get("/my", response_model=List[PropertyResponse])
async def my_properties(
    user: dict = Depends(verify_firebase_token),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
):
    """Get logged-in user's properties."""
    db = get_db()
    cursor = db.properties.find({"owner_uid": user["uid"]}).sort("created_at", -1).skip(skip).limit(limit)
    properties = []
    async for doc in cursor:
        properties.append(_doc_to_response(doc))
    return properties

@router.get("/{property_id}", response_model=PropertyResponse)
async def get_property(property_id: str):
    """Get single property by ID (public)."""
    db = get_db()
    try:
        doc = await db.properties.find_one({"_id": ObjectId(property_id)})
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid property ID")

    if not doc:
        raise HTTPException(status_code=404, detail="Property not found")

    # Increment views
    await db.properties.update_one(
        {"_id": ObjectId(property_id)},
        {"$inc": {"views": 1}},
    )
    doc["views"] = doc.get("views", 0) + 1

    return _doc_to_response(doc)

@router.put("/{property_id}", response_model=PropertyResponse)
async def update_property(
    property_id: str,
    update_data: PropertyUpdate,
    user: dict = Depends(verify_firebase_token),
):
    """Update a property (owner only)."""
    db = get_db()
    try:
        doc = await db.properties.find_one({"_id": ObjectId(property_id)})
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid property ID")

    if not doc:
        raise HTTPException(status_code=404, detail="Property not found")
    if doc["owner_uid"] != user["uid"]:
        raise HTTPException(status_code=403, detail="Not authorized")

    update_fields = {k: v for k, v in update_data.model_dump().items() if v is not None}
    update_fields["updated_at"] = datetime.now(timezone.utc)

    await db.properties.update_one(
        {"_id": ObjectId(property_id)},
        {"$set": update_fields},
    )

    updated = await db.properties.find_one({"_id": ObjectId(property_id)})
    return _doc_to_response(updated)

@router.delete("/{property_id}")
async def delete_property(
    property_id: str,
    user: dict = Depends(verify_firebase_token),
):
    """Delete a property (owner only)."""
    db = get_db()
    try:
        doc = await db.properties.find_one({"_id": ObjectId(property_id)})
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid property ID")

    if not doc:
        raise HTTPException(status_code=404, detail="Property not found")
    if doc["owner_uid"] != user["uid"]:
        raise HTTPException(status_code=403, detail="Not authorized")

    await db.properties.delete_one({"_id": ObjectId(property_id)})
    return {"message": "Property deleted successfully"}
