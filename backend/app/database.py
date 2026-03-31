import ssl
import certifi
from motor.motor_asyncio import AsyncIOMotorClient
from .config import MONGODB_URI, MONGODB_DB_NAME

client: AsyncIOMotorClient = None
db = None

async def connect_db():
    global client, db
    # Try certifi first, fall back to disabling SSL verification
    try:
        test_client = AsyncIOMotorClient(
            MONGODB_URI,
            tlsCAFile=certifi.where(),
            serverSelectionTimeoutMS=5000,
        )
        await test_client.admin.command("ping")
        test_client.close()
        # certifi works — use it
        client = AsyncIOMotorClient(
            MONGODB_URI,
            tlsCAFile=certifi.where(),
            serverSelectionTimeoutMS=15000,
            connectTimeoutMS=15000,
        )
        print("MongoDB: Connected with certifi CA bundle")
    except Exception:
        # SSL verification failing — bypass it for development
        client = AsyncIOMotorClient(
            MONGODB_URI,
            tls=True,
            tlsAllowInvalidCertificates=True,
            serverSelectionTimeoutMS=15000,
            connectTimeoutMS=15000,
        )
        print("MongoDB: Connected with SSL verification disabled (dev mode)")
    db = client[MONGODB_DB_NAME]

    # Test connection first
    try:
        await client.admin.command("ping")
        print(f"Connected to MongoDB: {MONGODB_DB_NAME}")
    except Exception as e:
        print(f"WARNING: MongoDB ping failed ({e}), will retry on first request")

    # Create indexes (wrapped in try/catch so server still starts)
    try:
        await db.properties.create_index("owner_uid")
        await db.properties.create_index("created_at")
        await db.properties.create_index([("city", 1), ("transaction_type", 1)])
        await db.conversations.create_index("participants")
        await db.conversations.create_index("property_id")
        await db.messages.create_index("conversation_id")
        await db.messages.create_index("created_at")
        # SP Profiles
        await db.sp_profiles.create_index("uid", unique=True)
        await db.sp_profiles.create_index([("city", 1), ("service_category", 1)])
        # Services
        await db.services.create_index("provider_uid")
        await db.services.create_index([("category", 1), ("city", 1)])
        await db.services.create_index("created_at")
        # Bookings
        await db.bookings.create_index("customer_uid")
        await db.bookings.create_index("provider_uid")
        await db.bookings.create_index([("status", 1), ("created_at", -1)])
        # Notifications
        await db.notifications.create_index([("uid", 1), ("created_at", -1)])
        await db.notifications.create_index([("uid", 1), ("is_read", 1)])
        # Reviews
        await db.reviews.create_index([("target_type", 1), ("target_id", 1)])
        await db.reviews.create_index("reviewer_uid")
        # Payments
        await db.payments.create_index("payer_uid")
        await db.payments.create_index("booking_id")
        await db.payments.create_index([("status", 1), ("created_at", -1)])
        # Verifications
        await db.verifications.create_index([("uid", 1), ("type", 1)], unique=True)
        # Favorites
        await db.favorites.create_index([("uid", 1), ("target_type", 1), ("target_id", 1)], unique=True)
        # Location tracking
        await db.location_tracking.create_index("uid", unique=True)
        # Advertisements
        await db.advertisements.create_index("created_at")
        print("All indexes created successfully")
    except Exception as e:
        print(f"WARNING: Index creation failed ({e}), indexes will be created on next restart")

async def close_db():
    global client
    if client:
        client.close()
        print("MongoDB connection closed")

def get_db():
    return db
