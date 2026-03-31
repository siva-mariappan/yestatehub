from pydantic import BaseModel
from typing import Optional


class NotificationCreate(BaseModel):
    title: str = ""
    body: str = ""
    type: str = "general"  # general, property, booking, chat, payment, system
    action_url: str = ""
    image_url: str = ""
    data: dict = {}
