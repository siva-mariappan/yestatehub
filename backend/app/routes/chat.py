from fastapi import APIRouter, Depends, HTTPException, Query, WebSocket, WebSocketDisconnect
from typing import List
from datetime import datetime, timezone
from bson import ObjectId
from ..database import get_db
from ..firebase_auth import verify_firebase_token
from ..models.chat import MessageCreate, ConversationCreate, MessageResponse, ConversationResponse
import json

router = APIRouter(prefix="/api/chat", tags=["Chat"])


def _safe_isoformat(val):
    """Safely convert a datetime or string to ISO format string."""
    if val is None:
        return ""
    if hasattr(val, "isoformat"):
        return val.isoformat()
    return str(val)


# ─── WebSocket Connection Manager ───────────────────────────────
class ConnectionManager:
    def __init__(self):
        self.active_connections: dict[str, WebSocket] = {}

    async def connect(self, user_uid: str, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[user_uid] = websocket
        print(f"[WS] User {user_uid} connected. Active: {list(self.active_connections.keys())}")

    def disconnect(self, user_uid: str):
        self.active_connections.pop(user_uid, None)
        print(f"[WS] User {user_uid} disconnected. Active: {list(self.active_connections.keys())}")

    async def send_to_user(self, user_uid: str, data: dict):
        ws = self.active_connections.get(user_uid)
        if ws:
            try:
                await ws.send_json(data)
                print(f"[WS] Sent message to {user_uid}")
            except Exception as e:
                print(f"[WS] Failed to send to {user_uid}: {e}")
                self.active_connections.pop(user_uid, None)
        else:
            print(f"[WS] User {user_uid} not connected, message queued in DB only")

manager = ConnectionManager()

# ─── REST Endpoints ─────────────────────────────────────────────

@router.post("/conversations")
async def create_conversation(
    data: ConversationCreate,
    user: dict = Depends(verify_firebase_token),
):
    """Create or get existing conversation for a property between two users."""
    db = get_db()

    # Check if conversation already exists
    existing = await db.conversations.find_one({
        "property_id": data.property_id,
        "participants.uid": {"$all": [user["uid"], data.participant_uid]},
    })

    if existing:
        existing["id"] = str(existing.pop("_id"))
        existing["last_message_time"] = _safe_isoformat(existing.get("last_message_time"))
        existing["created_at"] = _safe_isoformat(existing.get("created_at"))
        # Count unread for current user
        unread = await db.messages.count_documents({
            "conversation_id": existing["id"],
            "sender_uid": {"$ne": user["uid"]},
            "is_read": False,
        })
        existing["unread_count"] = unread
        return existing

    now = datetime.now(timezone.utc)
    conv_doc = {
        "property_id": data.property_id,
        "property_title": data.property_title,
        "participants": [
            {"uid": user["uid"], "name": user["name"], "email": user.get("email", "")},
            {"uid": data.participant_uid, "name": data.participant_name, "email": ""},
        ],
        "last_message": "",
        "last_message_time": now,
        "created_at": now,
    }

    result = await db.conversations.insert_one(conv_doc)
    conv_doc["id"] = str(result.inserted_id)
    conv_doc.pop("_id", None)
    conv_doc["last_message_time"] = now.isoformat()
    conv_doc["created_at"] = now.isoformat()
    conv_doc["unread_count"] = 0

    return conv_doc


@router.get("/conversations")
async def list_conversations(
    user: dict = Depends(verify_firebase_token),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
):
    """List all conversations for the logged-in user."""
    db = get_db()

    cursor = db.conversations.find(
        {"participants.uid": user["uid"]}
    ).sort("last_message_time", -1).skip(skip).limit(limit)

    conversations = []
    seen_keys = set()  # deduplicate by (property_id, participant set)
    async for doc in cursor:
        try:
            conv_id = str(doc["_id"])

            # Build a dedup key from property_id + sorted participant uids
            p_uids = sorted(p["uid"] for p in doc.get("participants", []))
            dedup_key = (doc.get("property_id", ""), tuple(p_uids))
            if dedup_key in seen_keys:
                # Duplicate conversation — skip it
                continue
            seen_keys.add(dedup_key)

            doc["id"] = conv_id
            doc.pop("_id", None)
            doc["last_message_time"] = _safe_isoformat(doc.get("last_message_time"))
            doc["created_at"] = _safe_isoformat(doc.get("created_at"))

            # Count unread messages
            unread = await db.messages.count_documents({
                "conversation_id": conv_id,
                "sender_uid": {"$ne": user["uid"]},
                "is_read": False,
            })
            doc["unread_count"] = unread
            conversations.append(doc)
        except Exception as e:
            print(f"Skipping conversation {doc.get('_id')}: {e}")

    return conversations


@router.get("/conversations/{conversation_id}/messages")
async def get_messages(
    conversation_id: str,
    user: dict = Depends(verify_firebase_token),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
):
    """Get messages in a conversation."""
    db = get_db()

    # Verify user is participant
    try:
        conv = await db.conversations.find_one({"_id": ObjectId(conversation_id)})
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid conversation ID")

    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")

    participant_uids = [p["uid"] for p in conv.get("participants", [])]
    if user["uid"] not in participant_uids:
        raise HTTPException(status_code=403, detail="Not a participant")

    # Mark messages as read
    await db.messages.update_many(
        {
            "conversation_id": conversation_id,
            "sender_uid": {"$ne": user["uid"]},
            "is_read": False,
        },
        {"$set": {"is_read": True}},
    )

    cursor = db.messages.find(
        {"conversation_id": conversation_id}
    ).sort("created_at", 1).skip(skip).limit(limit)

    messages = []
    async for doc in cursor:
        try:
            doc["id"] = str(doc.pop("_id"))
            doc["created_at"] = _safe_isoformat(doc.get("created_at"))
            messages.append(doc)
        except Exception as e:
            print(f"Skipping message: {e}")

    return messages


@router.post("/messages")
async def send_message(
    data: MessageCreate,
    user: dict = Depends(verify_firebase_token),
):
    """Send a message in a conversation."""
    db = get_db()

    # Verify conversation exists and user is participant
    try:
        conv = await db.conversations.find_one({"_id": ObjectId(data.conversation_id)})
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid conversation ID")

    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")

    participant_uids = [p["uid"] for p in conv.get("participants", [])]
    if user["uid"] not in participant_uids:
        raise HTTPException(status_code=403, detail="Not a participant")

    now = datetime.now(timezone.utc)
    msg_doc = {
        "conversation_id": data.conversation_id,
        "sender_uid": user["uid"],
        "sender_name": user.get("name", "User"),
        "text": data.text,
        "is_read": False,
        "created_at": now,
    }

    result = await db.messages.insert_one(msg_doc)
    msg_doc["id"] = str(result.inserted_id)
    msg_doc["created_at"] = now.isoformat()
    msg_doc.pop("_id", None)

    # Update conversation's last message
    await db.conversations.update_one(
        {"_id": ObjectId(data.conversation_id)},
        {"$set": {"last_message": data.text, "last_message_time": now}},
    )

    # Notify ALL participants via WebSocket (including sender, so their other tabs update)
    for p_uid in participant_uids:
        if p_uid != user["uid"]:
            await manager.send_to_user(p_uid, {
                "type": "new_message",
                "conversation_id": data.conversation_id,
                "message": msg_doc,
            })

    return msg_doc


# ─── WebSocket Endpoint ─────────────────────────────────────────

@router.websocket("/ws/{user_uid}")
async def websocket_endpoint(websocket: WebSocket, user_uid: str):
    """WebSocket for real-time chat notifications."""
    await manager.connect(user_uid, websocket)
    try:
        while True:
            data = await websocket.receive_text()
            try:
                msg = json.loads(data)
                if msg.get("type") == "typing":
                    conv_id = msg.get("conversation_id")
                    if conv_id:
                        db = get_db()
                        conv = await db.conversations.find_one({"_id": ObjectId(conv_id)})
                        if conv:
                            for p in conv.get("participants", []):
                                if p["uid"] != user_uid:
                                    await manager.send_to_user(p["uid"], {
                                        "type": "typing",
                                        "conversation_id": conv_id,
                                        "user_uid": user_uid,
                                    })
            except json.JSONDecodeError:
                pass
    except WebSocketDisconnect:
        manager.disconnect(user_uid)
    except Exception as e:
        print(f"[WS] Error for {user_uid}: {e}")
        manager.disconnect(user_uid)
