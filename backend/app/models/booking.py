from pydantic import BaseModel, Field
from typing import Optional, List


class BookingCreate(BaseModel):
    service_id: str = Field(..., min_length=1)
    provider_uid: str = Field(..., min_length=1)
    service_title: str = ""
    scheduled_date: str = ""  # ISO format
    scheduled_time: str = ""
    address: str = ""
    city: str = ""
    pincode: str = ""
    notes: str = ""
    price: float = 0


class BookingUpdate(BaseModel):
    status: Optional[str] = None  # pending, confirmed, in_progress, completed, cancelled
    scheduled_date: Optional[str] = None
    scheduled_time: Optional[str] = None
    address: Optional[str] = None
    notes: Optional[str] = None
    price: Optional[float] = None
    provider_notes: Optional[str] = None
    rating: Optional[float] = None
    review_text: Optional[str] = None
    completion_date: Optional[str] = None
    cancellation_reason: Optional[str] = None
