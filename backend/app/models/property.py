from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class PropertyCreate(BaseModel):
    model_config = {"extra": "ignore"}

    title: str = Field("", max_length=200)
    description: str = ""
    purpose: str = "Sell"
    property_type: str = "apartment"
    transaction_type: str = "buy"
    furnishing: str = "unfurnished"
    listed_by: str = "owner"
    bedrooms: int = 0
    bathrooms: int = 0
    area_sqft: float = 0
    floor: int = 0
    total_floors: int = 0
    facing: str = ""
    age_of_building: int = 0
    possession_status: str = "Ready to Move"
    amenities: List[str] = []
    nearby_amenities: dict = {}
    # Location
    state: str = ""
    district: str = ""
    city: str = ""
    locality: str = ""
    pincode: str = ""
    address: str = ""
    # Pricing
    price: float = 0
    price_per_sqft: Optional[float] = None
    negotiable: bool = False
    # Media
    images: List[str] = []
    video_url: str = ""
    # Contact
    contact_name: str = ""
    contact_phone: str = ""
    contact_email: str = ""

class PropertyResponse(BaseModel):
    model_config = {"extra": "ignore"}

    id: str
    title: str = ""
    description: str = ""
    purpose: str = "Sell"
    property_type: str = "apartment"
    transaction_type: str = "buy"
    furnishing: str = "unfurnished"
    listed_by: str = "owner"
    bedrooms: int = 0
    bathrooms: int = 0
    area_sqft: float = 0
    floor: int = 0
    total_floors: int = 0
    facing: str = ""
    age_of_building: int = 0
    possession_status: str = "Ready to Move"
    amenities: List[str] = []
    nearby_amenities: dict = {}
    state: str = ""
    district: str = ""
    city: str = ""
    locality: str = ""
    pincode: str = ""
    address: str = ""
    price: float = 0
    price_per_sqft: Optional[float] = None
    negotiable: bool = False
    images: List[str] = []
    video_url: str = ""
    contact_name: str = ""
    contact_phone: str = ""
    contact_email: str = ""
    owner_uid: str = ""
    owner_name: str = ""
    owner_email: str = ""
    is_verified: bool = False
    is_rera_approved: bool = False
    no_brokerage: bool = False
    views: int = 0
    enquiries: int = 0
    created_at: str = ""
    updated_at: str = ""

class PropertyUpdate(BaseModel):
    model_config = {"extra": "ignore"}

    title: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    negotiable: Optional[bool] = None
    images: Optional[List[str]] = None
    amenities: Optional[List[str]] = None
    furnishing: Optional[str] = None
    possession_status: Optional[str] = None
    property_type: Optional[str] = None
    transaction_type: Optional[str] = None
    listed_by: Optional[str] = None
    bedrooms: Optional[int] = None
    bathrooms: Optional[int] = None
    area_sqft: Optional[float] = None
    floor: Optional[int] = None
    total_floors: Optional[int] = None
    facing: Optional[str] = None
    age_of_building: Optional[int] = None
    state: Optional[str] = None
    district: Optional[str] = None
    city: Optional[str] = None
    locality: Optional[str] = None
    pincode: Optional[str] = None
    address: Optional[str] = None
    video_url: Optional[str] = None
    contact_name: Optional[str] = None
    contact_phone: Optional[str] = None
    contact_email: Optional[str] = None
