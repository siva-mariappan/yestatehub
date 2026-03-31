from pydantic import BaseModel, Field
from typing import Optional


class PaymentCreate(BaseModel):
    booking_id: str = ""
    amount: float = Field(..., gt=0)
    currency: str = "INR"
    payment_method: str = "upi"  # upi, card, netbanking, wallet, cod
    description: str = ""


class PaymentUpdate(BaseModel):
    status: Optional[str] = None  # pending, processing, completed, failed, refunded
    transaction_id: Optional[str] = None
    gateway_response: Optional[dict] = None
    refund_amount: Optional[float] = None
    refund_reason: Optional[str] = None
