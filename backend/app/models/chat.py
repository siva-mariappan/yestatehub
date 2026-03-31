from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class MessageCreate(BaseModel):
    model_config = {"extra": "ignore"}
    conversation_id: str
    text: str = Field(..., min_length=1, max_length=2000)

class ConversationCreate(BaseModel):
    model_config = {"extra": "ignore"}
    property_id: str
    property_title: str
    participant_uid: str  # the other user
    participant_name: str

class MessageResponse(BaseModel):
    model_config = {"extra": "ignore"}
    id: str
    conversation_id: str
    sender_uid: str
    sender_name: str = ""
    text: str
    is_read: bool = False
    created_at: str = ""

class ConversationResponse(BaseModel):
    model_config = {"extra": "ignore"}
    id: str
    property_id: str = ""
    property_title: str = ""
    participants: List[dict] = []
    last_message: str = ""
    last_message_time: str = ""
    unread_count: int = 0
    created_at: str = ""
