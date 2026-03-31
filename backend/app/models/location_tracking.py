from pydantic import BaseModel, Field
from typing import Optional


class LocationUpdate(BaseModel):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    accuracy: float = 0
    heading: float = 0
    speed: float = 0
    context: str = "general"  # general, booking_active, delivery
    booking_id: Optional[str] = None
