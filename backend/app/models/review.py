from pydantic import BaseModel, Field
from typing import Optional


class ReviewCreate(BaseModel):
    target_type: str = Field(..., pattern="^(property|service|provider)$")
    target_id: str = Field(..., min_length=1)
    rating: float = Field(..., ge=1, le=5)
    title: str = ""
    comment: str = ""
    images: list = []


class ReviewUpdate(BaseModel):
    rating: Optional[float] = None
    title: Optional[str] = None
    comment: Optional[str] = None
    images: Optional[list] = None
    is_flagged: Optional[bool] = None
    admin_reply: Optional[str] = None
