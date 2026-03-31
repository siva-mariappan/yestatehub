from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import ALLOWED_ORIGINS
from app.database import connect_db, close_db
from app.routes import (
    property, chat, auth, advertisement,
    sp_profile, service, booking, notification,
    review, payment, verification, favorite, location_tracking
)

app = FastAPI(
    title="YEstateHub API",
    description="Real Estate Platform API — Add Property & Chat with MongoDB Atlas",
    version="1.0.0",
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS + ["*"],  # Allow all in dev
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Startup / Shutdown
@app.on_event("startup")
async def startup():
    await connect_db()

@app.on_event("shutdown")
async def shutdown():
    await close_db()

# Register routes
app.include_router(auth.router)
app.include_router(property.router)
app.include_router(chat.router)
app.include_router(advertisement.router)
app.include_router(sp_profile.router)
app.include_router(service.router)
app.include_router(booking.router)
app.include_router(notification.router)
app.include_router(review.router)
app.include_router(payment.router)
app.include_router(verification.router)
app.include_router(favorite.router)
app.include_router(location_tracking.router)

@app.get("/")
async def root():
    return {
        "app": "YEstateHub API",
        "version": "1.0.0",
        "docs": "/docs",
        "endpoints": {
            "auth": "/api/auth/sync",
            "properties": "/api/properties/",
            "chat_conversations": "/api/chat/conversations",
            "chat_messages": "/api/chat/messages",
            "websocket": "/api/chat/ws/{user_uid}",
            "advertisements": "/api/advertisements/",
            "sp_profiles": "/api/sp-profiles/",
            "services": "/api/services/",
            "bookings": "/api/bookings/",
            "notifications": "/api/notifications/",
            "reviews": "/api/reviews/",
            "payments": "/api/payments/",
            "verifications": "/api/verifications/",
            "favorites": "/api/favorites/",
            "location": "/api/location/",
        },
    }

@app.get("/health")
async def health():
    return {"status": "ok"}
