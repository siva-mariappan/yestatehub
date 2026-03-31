from pydantic import BaseModel, Field
from typing import Optional, List


class SPProfileCreate(BaseModel):
    business_name: str = Field(..., min_length=2, max_length=200)
    service_category: str = ""  # e.g. "Packers & Movers", "Home Cleaning"
    description: str = ""
    phone: str = ""
    alt_phone: str = ""
    email: str = ""
    address: str = ""
    city: str = ""
    state: str = ""
    pincode: str = ""
    logo_url: str = ""
    cover_image_url: str = ""
    experience_years: int = 0
    certifications: List[str] = []
    service_areas: List[str] = []
    working_hours: str = "9 AM - 6 PM"
    is_verified: bool = False
    is_active: bool = True


class SPProfileUpdate(BaseModel):
    business_name: Optional[str] = None
    service_category: Optional[str] = None
    description: Optional[str] = None
    phone: Optional[str] = None
    alt_phone: Optional[str] = None
    email: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    pincode: Optional[str] = None
    logo_url: Optional[str] = None
    cover_image_url: Optional[str] = None
    experience_years: Optional[int] = None
    certifications: Optional[List[str]] = None
    service_areas: Optional[List[str]] = None
    working_hours: Optional[str] = None
    is_verified: Optional[bool] = None
    is_active: Optional[bool] = None
