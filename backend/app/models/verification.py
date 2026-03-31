from pydantic import BaseModel, Field
from typing import Optional


class VerificationCreate(BaseModel):
    type: str = Field(..., pattern="^(aadhaar|pan|gst|rera|business)$")
    document_number: str = ""
    document_url: str = ""
    selfie_url: str = ""
    notes: str = ""


class VerificationUpdate(BaseModel):
    status: Optional[str] = None  # pending, in_review, approved, rejected
    admin_notes: Optional[str] = None
    verified_by: Optional[str] = None
