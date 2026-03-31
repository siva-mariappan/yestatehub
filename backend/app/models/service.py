from pydantic import BaseModel, Field
from typing import Optional, List


class ServiceCreate(BaseModel):
    title: str = Field(..., min_length=3, max_length=200)
    description: str = ""
    category: str = ""  # e.g. "Home Cleaning", "Packers & Movers"
    sub_category: str = ""
    price: float = 0
    price_type: str = "fixed"  # fixed, hourly, per_sqft, negotiable
    duration_minutes: int = 60
    images: List[str] = []
    tags: List[str] = []
    is_active: bool = True


class ServiceUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    sub_category: Optional[str] = None
    price: Optional[float] = None
    price_type: Optional[str] = None
    duration_minutes: Optional[int] = None
    images: Optional[List[str]] = None
    tags: Optional[List[str]] = None
    is_active: Optional[bool] = None
