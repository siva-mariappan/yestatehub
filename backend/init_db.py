"""
MongoDB Atlas — Initialize all YEstateHub collections with schemas & sample data.

Collections created:
  1. users           — User/Admin/ServiceProvider profiles
  2. properties      — Property listings
  3. conversations   — Chat conversation threads
  4. messages        — Individual chat messages
  5. advertisements  — Ads managed by admin

Run:  python init_db.py
"""
import asyncio
from datetime import datetime, timezone, timedelta
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv
import os

load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI", "mongodb://localhost:27017")
DB_NAME = os.getenv("MONGODB_DB_NAME", "yestatehub")


async def init():
    print(f"Connecting to MongoDB Atlas...")
    client = AsyncIOMotorClient(MONGODB_URI)
    db = client[DB_NAME]

    # Ping to verify connection
    await db.command("ping")
    print(f"Connected to database: {DB_NAME}\n")

    now = datetime.now(timezone.utc)

    # ═══════════════════════════════════════════════════════════════
    # 1. USERS COLLECTION
    # ═══════════════════════════════════════════════════════════════
    print("Creating 'users' collection...")
    await db.users.drop()
    await db.users.create_index("uid", unique=True)
    await db.users.create_index("email", unique=True)
    await db.users.create_index("role")

    users = [
        {
            "uid": "admin_001",
            "email": "yestatehub@gmail.com",
            "name": "YEstateHub Admin",
            "picture": "",
            "phone": "+91 9876543210",
            "role": "admin",
            "is_active": True,
            "is_verified": True,
            "address": "Hyderabad, Telangana",
            "created_at": now - timedelta(days=365),
            "last_login": now,
        },
        {
            "uid": "user_001",
            "email": "rahul.sharma@gmail.com",
            "name": "Rahul Sharma",
            "picture": "",
            "phone": "+91 9876500001",
            "role": "user",
            "is_active": True,
            "is_verified": True,
            "address": "Gachibowli, Hyderabad",
            "created_at": now - timedelta(days=180),
            "last_login": now - timedelta(hours=2),
        },
        {
            "uid": "user_002",
            "email": "priya.verma@gmail.com",
            "name": "Priya Verma",
            "picture": "",
            "phone": "+91 9876500002",
            "role": "user",
            "is_active": True,
            "is_verified": True,
            "address": "Kondapur, Hyderabad",
            "created_at": now - timedelta(days=120),
            "last_login": now - timedelta(hours=5),
        },
        {
            "uid": "user_003",
            "email": "amit.reddy@gmail.com",
            "name": "Amit Reddy",
            "picture": "",
            "phone": "+91 9876500003",
            "role": "user",
            "is_active": True,
            "is_verified": False,
            "address": "Kokapet, Hyderabad",
            "created_at": now - timedelta(days=90),
            "last_login": now - timedelta(days=1),
        },
        {
            "uid": "user_004",
            "email": "sneha.iyer@gmail.com",
            "name": "Sneha Iyer",
            "picture": "",
            "phone": "+91 9876500004",
            "role": "user",
            "is_active": True,
            "is_verified": True,
            "address": "Miyapur, Hyderabad",
            "created_at": now - timedelta(days=60),
            "last_login": now - timedelta(days=3),
        },
        {
            "uid": "sp_001",
            "email": "cleanpro@gmail.com",
            "name": "CleanPro Services",
            "picture": "",
            "phone": "+91 9876500010",
            "role": "service_provider",
            "service_type": "Cleaning",
            "is_active": True,
            "is_verified": True,
            "rating": 4.8,
            "total_jobs": 245,
            "address": "Madhapur, Hyderabad",
            "created_at": now - timedelta(days=200),
            "last_login": now - timedelta(hours=1),
        },
        {
            "uid": "sp_002",
            "email": "paintmaster@gmail.com",
            "name": "PaintMaster Pro",
            "picture": "",
            "phone": "+91 9876500011",
            "role": "service_provider",
            "service_type": "Painting",
            "is_active": True,
            "is_verified": True,
            "rating": 4.5,
            "total_jobs": 128,
            "address": "Kukatpally, Hyderabad",
            "created_at": now - timedelta(days=150),
            "last_login": now - timedelta(hours=8),
        },
        {
            "uid": "sp_003",
            "email": "fixitall@gmail.com",
            "name": "FixItAll Repairs",
            "picture": "",
            "phone": "+91 9876500012",
            "role": "service_provider",
            "service_type": "Repair",
            "is_active": True,
            "is_verified": False,
            "rating": 4.2,
            "total_jobs": 67,
            "address": "Ameerpet, Hyderabad",
            "created_at": now - timedelta(days=45),
            "last_login": now - timedelta(days=2),
        },
    ]
    await db.users.insert_many(users)
    print(f"  Inserted {len(users)} users (1 admin, 4 users, 3 service providers)")

    # ═══════════════════════════════════════════════════════════════
    # 2. PROPERTIES COLLECTION
    # ═══════════════════════════════════════════════════════════════
    print("Creating 'properties' collection...")
    await db.properties.drop()
    await db.properties.create_index("owner_uid")
    await db.properties.create_index("created_at")
    await db.properties.create_index([("city", 1), ("transaction_type", 1)])
    await db.properties.create_index([("property_type", 1)])
    await db.properties.create_index([("price", 1)])
    await db.properties.create_index("status")

    properties = [
        {
            "title": "Luxury 3 BHK Apartment in Gachibowli",
            "description": "Spacious 3 BHK apartment with modern amenities, 24/7 security, swimming pool, and gymnasium. Close to IT corridor.",
            "purpose": "Sell",
            "property_type": "apartment",
            "transaction_type": "buy",
            "furnishing": "semi_furnished",
            "listed_by": "owner",
            "bedrooms": 3,
            "bathrooms": 2,
            "area_sqft": 1650,
            "floor": 8,
            "total_floors": 14,
            "facing": "East",
            "age_of_building": 2,
            "possession_status": "Ready to Move",
            "amenities": ["Swimming Pool", "Gymnasium", "Parking", "24/7 Security", "Power Backup", "Lift"],
            "nearby_amenities": {"School": "1.2 km", "Hospital": "2.5 km", "Metro": "0.8 km"},
            "state": "Telangana",
            "district": "Hyderabad",
            "city": "Hyderabad",
            "locality": "Gachibowli",
            "pincode": "500032",
            "address": "Plot 45, Gachibowli Main Road, Near DLF Cyber City",
            "price": 12500000,
            "price_per_sqft": 7575.76,
            "negotiable": True,
            "images": [
                "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800",
                "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800",
            ],
            "video_url": "",
            "contact_name": "Rahul Sharma",
            "contact_phone": "+91 9876500001",
            "contact_email": "rahul.sharma@gmail.com",
            "owner_uid": "user_001",
            "owner_name": "Rahul Sharma",
            "owner_email": "rahul.sharma@gmail.com",
            "is_verified": True,
            "is_rera_approved": True,
            "rera_id": "TS/RERA/001/2025",
            "no_brokerage": True,
            "views": 342,
            "enquiries": 28,
            "status": "active",
            "created_at": now - timedelta(days=15),
            "updated_at": now - timedelta(days=2),
        },
        {
            "title": "Modern 2 BHK Flat for Rent in Kondapur",
            "description": "Well-maintained 2 BHK flat with modular kitchen, wardrobes, and balcony. Walking distance to Botanical Garden.",
            "purpose": "Rent",
            "property_type": "apartment",
            "transaction_type": "rent",
            "furnishing": "furnished",
            "listed_by": "owner",
            "bedrooms": 2,
            "bathrooms": 2,
            "area_sqft": 1200,
            "floor": 4,
            "total_floors": 10,
            "facing": "North",
            "age_of_building": 5,
            "possession_status": "Ready to Move",
            "amenities": ["Parking", "Power Backup", "Lift", "Wardrobes", "Modular Kitchen"],
            "nearby_amenities": {"Mall": "1 km", "School": "0.5 km"},
            "state": "Telangana",
            "district": "Hyderabad",
            "city": "Hyderabad",
            "locality": "Kondapur",
            "pincode": "500084",
            "address": "Flat 402, Sri Sai Residency, Kondapur",
            "price": 28000,
            "price_per_sqft": 23.33,
            "negotiable": False,
            "images": [
                "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800",
            ],
            "video_url": "",
            "contact_name": "Priya Verma",
            "contact_phone": "+91 9876500002",
            "contact_email": "priya.verma@gmail.com",
            "owner_uid": "user_002",
            "owner_name": "Priya Verma",
            "owner_email": "priya.verma@gmail.com",
            "is_verified": True,
            "is_rera_approved": False,
            "rera_id": "",
            "no_brokerage": True,
            "views": 215,
            "enquiries": 15,
            "status": "active",
            "created_at": now - timedelta(days=10),
            "updated_at": now - timedelta(days=1),
        },
        {
            "title": "Premium Villa in Kokapet with Garden",
            "description": "Independent 4 BHK villa with private garden, rooftop terrace, modular kitchen, and premium interiors.",
            "purpose": "Sell",
            "property_type": "villa",
            "transaction_type": "buy",
            "furnishing": "furnished",
            "listed_by": "builder",
            "bedrooms": 4,
            "bathrooms": 4,
            "area_sqft": 3200,
            "floor": 0,
            "total_floors": 2,
            "facing": "South-East",
            "age_of_building": 0,
            "possession_status": "Under Construction",
            "amenities": ["Garden", "Rooftop Terrace", "Parking", "CCTV", "Club House", "Children Play Area"],
            "nearby_amenities": {"Hospital": "3 km", "Airport": "15 km"},
            "state": "Telangana",
            "district": "Hyderabad",
            "city": "Hyderabad",
            "locality": "Kokapet",
            "pincode": "500075",
            "address": "Villa 12, Green Valley Enclave, Kokapet",
            "price": 45000000,
            "price_per_sqft": 14062.50,
            "negotiable": True,
            "images": [
                "https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800",
                "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800",
            ],
            "video_url": "",
            "contact_name": "Amit Reddy",
            "contact_phone": "+91 9876500003",
            "contact_email": "amit.reddy@gmail.com",
            "owner_uid": "user_003",
            "owner_name": "Amit Reddy",
            "owner_email": "amit.reddy@gmail.com",
            "is_verified": False,
            "is_rera_approved": True,
            "rera_id": "TS/RERA/045/2025",
            "no_brokerage": False,
            "views": 589,
            "enquiries": 42,
            "status": "active",
            "created_at": now - timedelta(days=7),
            "updated_at": now - timedelta(hours=12),
        },
        {
            "title": "Affordable PG in Madhapur for Working Professionals",
            "description": "Fully furnished PG with meals, Wi-Fi, housekeeping, and AC rooms. Walking distance to Hitec City.",
            "purpose": "PG",
            "property_type": "pg",
            "transaction_type": "pg",
            "furnishing": "furnished",
            "listed_by": "owner",
            "bedrooms": 1,
            "bathrooms": 1,
            "area_sqft": 200,
            "floor": 2,
            "total_floors": 3,
            "facing": "West",
            "age_of_building": 8,
            "possession_status": "Ready to Move",
            "amenities": ["Wi-Fi", "AC", "Meals", "Housekeeping", "Laundry", "TV"],
            "nearby_amenities": {"Metro": "0.3 km", "Mall": "0.8 km"},
            "state": "Telangana",
            "district": "Hyderabad",
            "city": "Hyderabad",
            "locality": "Madhapur",
            "pincode": "500081",
            "address": "Flat 201, Sai Nagar Colony, Madhapur",
            "price": 8500,
            "price_per_sqft": 42.50,
            "negotiable": False,
            "images": [
                "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800",
            ],
            "video_url": "",
            "contact_name": "Sneha Iyer",
            "contact_phone": "+91 9876500004",
            "contact_email": "sneha.iyer@gmail.com",
            "owner_uid": "user_004",
            "owner_name": "Sneha Iyer",
            "owner_email": "sneha.iyer@gmail.com",
            "is_verified": True,
            "is_rera_approved": False,
            "rera_id": "",
            "no_brokerage": True,
            "views": 156,
            "enquiries": 22,
            "status": "active",
            "created_at": now - timedelta(days=3),
            "updated_at": now - timedelta(hours=6),
        },
        {
            "title": "Commercial Office Space in Banjara Hills",
            "description": "Prime commercial office space with conference room, pantry, and dedicated parking. Ideal for IT startups.",
            "purpose": "Sell",
            "property_type": "apartment",
            "transaction_type": "commercial",
            "furnishing": "semi_furnished",
            "listed_by": "dealer",
            "bedrooms": 0,
            "bathrooms": 2,
            "area_sqft": 2500,
            "floor": 5,
            "total_floors": 8,
            "facing": "North-East",
            "age_of_building": 3,
            "possession_status": "Ready to Move",
            "amenities": ["Conference Room", "Parking", "Lift", "Power Backup", "Fire Safety", "CCTV"],
            "nearby_amenities": {"Restaurant": "0.2 km", "Bank": "0.5 km"},
            "state": "Telangana",
            "district": "Hyderabad",
            "city": "Hyderabad",
            "locality": "Banjara Hills",
            "pincode": "500034",
            "address": "5th Floor, Banjara Business Centre, Road No. 12",
            "price": 35000000,
            "price_per_sqft": 14000,
            "negotiable": True,
            "images": [
                "https://images.unsplash.com/photo-1497366216548-37526070297c?w=800",
            ],
            "video_url": "",
            "contact_name": "Vikram Das",
            "contact_phone": "+91 9876500005",
            "contact_email": "vikram.das@gmail.com",
            "owner_uid": "user_001",
            "owner_name": "Rahul Sharma",
            "owner_email": "rahul.sharma@gmail.com",
            "is_verified": True,
            "is_rera_approved": True,
            "rera_id": "TS/RERA/078/2025",
            "no_brokerage": False,
            "views": 410,
            "enquiries": 35,
            "status": "active",
            "created_at": now - timedelta(days=20),
            "updated_at": now - timedelta(days=5),
        },
    ]
    await db.properties.insert_many(properties)
    print(f"  Inserted {len(properties)} properties (buy, rent, pg, commercial)")

    # ═══════════════════════════════════════════════════════════════
    # 3. CONVERSATIONS COLLECTION
    # ═══════════════════════════════════════════════════════════════
    print("Creating 'conversations' collection...")
    await db.conversations.drop()
    await db.conversations.create_index("participants.uid")
    await db.conversations.create_index("property_id")
    await db.conversations.create_index("last_message_time")

    # Get property IDs for linking
    prop_ids = []
    async for p in db.properties.find({}, {"_id": 1, "title": 1}):
        prop_ids.append(p)

    conversations = [
        {
            "property_id": str(prop_ids[0]["_id"]),
            "property_title": "Luxury 3 BHK Apartment in Gachibowli",
            "participants": [
                {"uid": "user_001", "name": "Rahul Sharma", "email": "rahul.sharma@gmail.com"},
                {"uid": "user_002", "name": "Priya Verma", "email": "priya.verma@gmail.com"},
            ],
            "last_message": "Is the price negotiable? I am very interested.",
            "last_message_time": now - timedelta(minutes=2),
            "created_at": now - timedelta(days=5),
        },
        {
            "property_id": str(prop_ids[1]["_id"]),
            "property_title": "Modern 2 BHK Flat for Rent in Kondapur",
            "participants": [
                {"uid": "user_002", "name": "Priya Verma", "email": "priya.verma@gmail.com"},
                {"uid": "user_003", "name": "Amit Reddy", "email": "amit.reddy@gmail.com"},
            ],
            "last_message": "Can I visit tomorrow around 4 PM?",
            "last_message_time": now - timedelta(hours=1),
            "created_at": now - timedelta(days=3),
        },
        {
            "property_id": str(prop_ids[2]["_id"]),
            "property_title": "Premium Villa in Kokapet with Garden",
            "participants": [
                {"uid": "user_003", "name": "Amit Reddy", "email": "amit.reddy@gmail.com"},
                {"uid": "user_001", "name": "Rahul Sharma", "email": "rahul.sharma@gmail.com"},
            ],
            "last_message": "What is the carpet area exactly?",
            "last_message_time": now - timedelta(hours=3),
            "created_at": now - timedelta(days=2),
        },
    ]
    result_convs = await db.conversations.insert_many(conversations)
    conv_ids = result_convs.inserted_ids
    print(f"  Inserted {len(conversations)} conversations")

    # ═══════════════════════════════════════════════════════════════
    # 4. MESSAGES COLLECTION
    # ═══════════════════════════════════════════════════════════════
    print("Creating 'messages' collection...")
    await db.messages.drop()
    await db.messages.create_index("conversation_id")
    await db.messages.create_index("created_at")
    await db.messages.create_index([("conversation_id", 1), ("is_read", 1)])

    messages = [
        # Conversation 1: Rahul <-> Priya about Gachibowli 3BHK
        {
            "conversation_id": str(conv_ids[0]),
            "sender_uid": "user_002",
            "sender_name": "Priya Verma",
            "text": "Hi, I saw your listing for the 3 BHK in Gachibowli. Is it still available?",
            "is_read": True,
            "created_at": now - timedelta(days=5, hours=2),
        },
        {
            "conversation_id": str(conv_ids[0]),
            "sender_uid": "user_001",
            "sender_name": "Rahul Sharma",
            "text": "Yes, it is still available! Would you like to schedule a visit?",
            "is_read": True,
            "created_at": now - timedelta(days=5, hours=1, minutes=50),
        },
        {
            "conversation_id": str(conv_ids[0]),
            "sender_uid": "user_002",
            "sender_name": "Priya Verma",
            "text": "That would be great. What times work this week?",
            "is_read": True,
            "created_at": now - timedelta(days=5, hours=1, minutes=40),
        },
        {
            "conversation_id": str(conv_ids[0]),
            "sender_uid": "user_001",
            "sender_name": "Rahul Sharma",
            "text": "We have slots available on Thursday 4-6 PM and Saturday 10 AM - 1 PM.",
            "is_read": True,
            "created_at": now - timedelta(days=4),
        },
        {
            "conversation_id": str(conv_ids[0]),
            "sender_uid": "user_002",
            "sender_name": "Priya Verma",
            "text": "Is the price negotiable? I am very interested.",
            "is_read": False,
            "created_at": now - timedelta(minutes=2),
        },
        # Conversation 2: Priya <-> Amit about Kondapur 2BHK
        {
            "conversation_id": str(conv_ids[1]),
            "sender_uid": "user_003",
            "sender_name": "Amit Reddy",
            "text": "Hi, I am looking for a 2 BHK on rent. Is your Kondapur flat available?",
            "is_read": True,
            "created_at": now - timedelta(days=3),
        },
        {
            "conversation_id": str(conv_ids[1]),
            "sender_uid": "user_002",
            "sender_name": "Priya Verma",
            "text": "Yes it is! The rent is 28,000 per month, fully furnished.",
            "is_read": True,
            "created_at": now - timedelta(days=2, hours=20),
        },
        {
            "conversation_id": str(conv_ids[1]),
            "sender_uid": "user_003",
            "sender_name": "Amit Reddy",
            "text": "Can I visit tomorrow around 4 PM?",
            "is_read": False,
            "created_at": now - timedelta(hours=1),
        },
        # Conversation 3: Amit <-> Rahul about Kokapet Villa
        {
            "conversation_id": str(conv_ids[2]),
            "sender_uid": "user_001",
            "sender_name": "Rahul Sharma",
            "text": "I noticed your villa listing in Kokapet. Very impressive!",
            "is_read": True,
            "created_at": now - timedelta(days=2),
        },
        {
            "conversation_id": str(conv_ids[2]),
            "sender_uid": "user_003",
            "sender_name": "Amit Reddy",
            "text": "Thank you! It is a premium property with all modern amenities.",
            "is_read": True,
            "created_at": now - timedelta(days=1, hours=20),
        },
        {
            "conversation_id": str(conv_ids[2]),
            "sender_uid": "user_001",
            "sender_name": "Rahul Sharma",
            "text": "What is the carpet area exactly?",
            "is_read": False,
            "created_at": now - timedelta(hours=3),
        },
    ]
    await db.messages.insert_many(messages)
    print(f"  Inserted {len(messages)} messages across {len(conversations)} conversations")

    # ═══════════════════════════════════════════════════════════════
    # 5. ADVERTISEMENTS COLLECTION
    # ═══════════════════════════════════════════════════════════════
    print("Creating 'advertisements' collection...")
    await db.advertisements.drop()
    await db.advertisements.create_index("status")
    await db.advertisements.create_index("start_date")
    await db.advertisements.create_index("end_date")
    await db.advertisements.create_index("placement")

    advertisements = [
        {
            "title": "Premium Properties in Gachibowli",
            "subtitle": "Starting from 85L. RERA Approved. Book site visit today!",
            "image_url": "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800",
            "cta_text": "Explore Now",
            "cta_link": "/search?locality=Gachibowli",
            "placement": "home_carousel",
            "advertiser_name": "Prestige Developers",
            "advertiser_email": "ads@prestige.com",
            "budget": 50000,
            "impressions": 12450,
            "clicks": 342,
            "status": "active",
            "priority": 1,
            "bg_color": "#1E3A5F",
            "text_color": "#FFFFFF",
            "icon": "home",
            "start_date": now - timedelta(days=30),
            "end_date": now + timedelta(days=30),
            "created_by": "admin_001",
            "created_at": now - timedelta(days=30),
            "updated_at": now,
        },
        {
            "title": "Home Loan at 8.5% Interest",
            "subtitle": "Quick approval. Zero processing fee. Apply now!",
            "image_url": "https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800",
            "cta_text": "Apply Now",
            "cta_link": "/services/home-loan",
            "placement": "home_carousel",
            "advertiser_name": "HDFC Bank",
            "advertiser_email": "homeloans@hdfc.com",
            "budget": 75000,
            "impressions": 18920,
            "clicks": 567,
            "status": "active",
            "priority": 2,
            "bg_color": "#10B981",
            "text_color": "#FFFFFF",
            "icon": "account_balance",
            "start_date": now - timedelta(days=15),
            "end_date": now + timedelta(days=45),
            "created_by": "admin_001",
            "created_at": now - timedelta(days=15),
            "updated_at": now,
        },
        {
            "title": "Interior Design Services",
            "subtitle": "Transform your home. Free consultation. 500+ projects delivered.",
            "image_url": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=800",
            "cta_text": "Get Quote",
            "cta_link": "/services/interior",
            "placement": "home_carousel",
            "advertiser_name": "DesignCraft Studios",
            "advertiser_email": "hello@designcraft.in",
            "budget": 30000,
            "impressions": 8540,
            "clicks": 198,
            "status": "active",
            "priority": 3,
            "bg_color": "#7C3AED",
            "text_color": "#FFFFFF",
            "icon": "brush",
            "start_date": now - timedelta(days=10),
            "end_date": now + timedelta(days=20),
            "created_by": "admin_001",
            "created_at": now - timedelta(days=10),
            "updated_at": now,
        },
        {
            "title": "Vastu Consultation",
            "subtitle": "Expert Vastu advice for your new home. Book online.",
            "image_url": "",
            "cta_text": "Book Now",
            "cta_link": "/services/vastu",
            "placement": "search_banner",
            "advertiser_name": "VastuGuru",
            "advertiser_email": "info@vastuguru.com",
            "budget": 15000,
            "impressions": 3200,
            "clicks": 89,
            "status": "paused",
            "priority": 4,
            "bg_color": "#F59E0B",
            "text_color": "#FFFFFF",
            "icon": "auto_awesome",
            "start_date": now - timedelta(days=20),
            "end_date": now + timedelta(days=10),
            "created_by": "admin_001",
            "created_at": now - timedelta(days=20),
            "updated_at": now - timedelta(days=5),
        },
        {
            "title": "Year-End Property Sale",
            "subtitle": "Flat 10% off on select properties. Limited time offer!",
            "image_url": "",
            "cta_text": "View Deals",
            "cta_link": "/search?offer=year-end",
            "placement": "home_carousel",
            "advertiser_name": "YEstateHub",
            "advertiser_email": "yestatehub@gmail.com",
            "budget": 0,
            "impressions": 25000,
            "clicks": 1200,
            "status": "expired",
            "priority": 1,
            "bg_color": "#EF4444",
            "text_color": "#FFFFFF",
            "icon": "local_offer",
            "start_date": now - timedelta(days=60),
            "end_date": now - timedelta(days=5),
            "created_by": "admin_001",
            "created_at": now - timedelta(days=60),
            "updated_at": now - timedelta(days=5),
        },
    ]
    await db.advertisements.insert_many(advertisements)
    print(f"  Inserted {len(advertisements)} advertisements (3 active, 1 paused, 1 expired)")

    # ═══════════════════════════════════════════════════════════════
    # SUMMARY
    # ═══════════════════════════════════════════════════════════════
    print("\n" + "=" * 60)
    print("  DATABASE INITIALIZATION COMPLETE")
    print("=" * 60)
    colls = await db.list_collection_names()
    print(f"\n  Database: {DB_NAME}")
    print(f"  Collections: {', '.join(sorted(colls))}")
    for coll_name in sorted(colls):
        count = await db[coll_name].count_documents({})
        print(f"    {coll_name}: {count} documents")
    print(f"\n  Admin login: yestatehub@gmail.com")
    print("=" * 60)

    client.close()


if __name__ == "__main__":
    asyncio.run(init())
