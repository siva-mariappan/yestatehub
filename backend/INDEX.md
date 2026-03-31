# YEstateHub Backend - Complete Index

Welcome to the YEstateHub backend! This document serves as your entry point to the codebase.

## Start Here

1. **First Time?** → Read `QUICKSTART.md` (5 minutes)
2. **Want Full Details?** → Read `README.md` (10 minutes)
3. **Need API Reference?** → Check `ENDPOINTS.md` (comprehensive)
4. **Ready to Deploy?** → Follow `DEPLOYMENT.md`

## Directory Structure

```
backend/
├── main.py                    ← Start the app with: uvicorn main:app --reload
├── requirements.txt           ← Install with: pip install -r requirements.txt
├── .env.example              ← Copy & customize: cp .env.example .env
│
├── Documentation/
│   ├── INDEX.md              ← This file
│   ├── QUICKSTART.md         ← 5-minute setup guide
│   ├── README.md             ← Full documentation
│   ├── ENDPOINTS.md          ← Complete API reference
│   └── DEPLOYMENT.md         ← Production deployment guide
│
└── app/
    ├── __init__.py           ← Package marker
    ├── config.py             ← Load environment variables
    ├── database.py           ← MongoDB connection
    ├── firebase_auth.py      ← Firebase authentication
    │
    ├── models/               ← Pydantic data models
    │   ├── __init__.py
    │   ├── property.py       ← Property schemas
    │   └── chat.py           ← Chat schemas
    │
    └── routes/               ← API endpoints
        ├── __init__.py
        ├── auth.py           ← /api/auth/* endpoints
        ├── property.py       ← /api/properties/* endpoints
        └── chat.py           ← /api/chat/* endpoints
```

## Quick Navigation

### For Setup
| Need | File | Time |
|------|------|------|
| 5-minute setup | `QUICKSTART.md` | 5 min |
| Complete setup | `README.md` | 10 min |
| Install packages | `requirements.txt` | 2 min |
| Configure env | `.env.example` → `.env` | 5 min |

### For Development
| Need | File | Purpose |
|------|------|---------|
| All endpoints | `ENDPOINTS.md` | API reference |
| Entry point | `main.py` | FastAPI app |
| Database | `app/database.py` | MongoDB setup |
| Auth | `app/firebase_auth.py` | Token verification |
| Data models | `app/models/*` | Pydantic schemas |
| Routes | `app/routes/*` | API endpoints |

### For Deployment
| Need | File | Purpose |
|------|------|---------|
| Deployment options | `DEPLOYMENT.md` | 5 deployment methods |
| Docker setup | `DEPLOYMENT.md` | Container deployment |
| Security | `DEPLOYMENT.md` | Security checklist |
| Monitoring | `DEPLOYMENT.md` | Logging & monitoring |

## Key Files Explained

### main.py
- FastAPI application setup
- CORS middleware configuration
- Database connection lifecycle
- Route registration
- Health check & info endpoints

### app/config.py
- Environment variable loading
- Default configuration values
- Centralized settings

### app/database.py
- MongoDB connection management
- Automatic index creation
- Global db variable for routes

### app/firebase_auth.py
- Firebase token verification
- Authorization header parsing
- User info extraction

### app/models/property.py
- PropertyCreate - input validation
- PropertyResponse - output schema
- PropertyUpdate - partial updates
- Enums: PropertyType, TransactionType, etc.

### app/models/chat.py
- MessageCreate - input schema
- ConversationCreate - conversation setup
- MessageResponse, ConversationResponse

### app/routes/auth.py
- POST /api/auth/sync - User creation/sync
- GET /api/auth/me - User profile

### app/routes/property.py
- POST /api/properties/ - Create property
- GET /api/properties/ - List properties
- GET /api/properties/my - User's properties
- GET /api/properties/{id} - Get one
- PUT /api/properties/{id} - Update
- DELETE /api/properties/{id} - Delete

### app/routes/chat.py
- Conversation management
- Message history
- WebSocket real-time updates
- Typing indicators

## Feature Overview

### Authentication
- Firebase ID token verification
- User sync to MongoDB
- Profile management
- Protected endpoints

### Properties
- List, search, and filter properties
- Create, update, delete listings
- View tracking
- Price calculations

### Chat
- Real-time messaging
- Conversation management
- Read receipts
- Typing indicators

## API Endpoints by Category

### Authentication (2 endpoints)
```
POST   /api/auth/sync          - Sync Firebase user
GET    /api/auth/me            - Get user profile
```

### Properties (6 endpoints)
```
POST   /api/properties/        - Create property
GET    /api/properties/        - List properties (public)
GET    /api/properties/my      - User's properties
GET    /api/properties/{id}    - Get single property
PUT    /api/properties/{id}    - Update property
DELETE /api/properties/{id}    - Delete property
```

### Chat (5 endpoints)
```
POST   /api/chat/conversations               - Create/get conversation
GET    /api/chat/conversations               - List conversations
GET    /api/chat/conversations/{id}/messages - Get messages
POST   /api/chat/messages                    - Send message
WS     /api/chat/ws/{user_uid}               - WebSocket
```

### Utilities (3 endpoints)
```
GET    /                       - API info
GET    /health                 - Health check
GET    /docs                   - Swagger UI (auto-generated)
```

## Configuration

### Environment Variables
| Variable | Purpose | Example |
|----------|---------|---------|
| MONGODB_URI | Database connection | mongodb+srv://... |
| MONGODB_DB_NAME | Database name | yestatehub |
| FIREBASE_CREDENTIALS_PATH | Firebase key | ./firebase-service-account.json |
| ALLOWED_ORIGINS | CORS origins | http://localhost:3000 |

### Get Started
```bash
# 1. Install
pip install -r requirements.txt

# 2. Configure
cp .env.example .env
# Edit .env with your credentials

# 3. Run
uvicorn main:app --reload

# 4. Visit
# Swagger UI: http://localhost:8000/docs
# API Root: http://localhost:8000
```

## Common Tasks

### Create a Property
```bash
curl -X POST http://localhost:8000/api/properties/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "2 BHK Apartment",
    "property_type": "apartment",
    "price": 5000000,
    "bedrooms": 2
  }'
```

### List Properties
```bash
curl "http://localhost:8000/api/properties/?city=Delhi&limit=10"
```

### Send a Message
```bash
curl -X POST http://localhost:8000/api/chat/messages \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "conversation_id": "conv_id",
    "text": "Hello!"
  }'
```

## Database Collections

- `users` - User profiles
- `properties` - Property listings
- `conversations` - Chat conversations
- `messages` - Chat messages

## Testing the API

1. Install dependencies
2. Start server: `uvicorn main:app --reload`
3. Open: http://localhost:8000/docs
4. Test endpoints in Swagger UI

## Troubleshooting

**MongoDB Connection Error?**
- Check MONGODB_URI in .env
- Verify IP whitelist on MongoDB Atlas

**Firebase Token Error?**
- Ensure firebase-service-account.json exists
- Check FIREBASE_CREDENTIALS_PATH

**Port Already in Use?**
- Change port: `uvicorn main:app --port 8001`

**CORS Error?**
- Update ALLOWED_ORIGINS in .env

## Performance

- All endpoints are fully async
- Uses Motor for async MongoDB
- Connection pooling built-in
- Indexes on frequently queried fields

## Security

- Firebase token verification
- Owner-only authorization
- Input validation via Pydantic
- CORS middleware
- Environment variable configuration

## Production

- See DEPLOYMENT.md for:
  - Heroku, AWS, Docker, GCP, DigitalOcean
  - Performance optimization
  - Monitoring & logging
  - Backup strategy
  - Security checklist

## Support

- API Docs: `/docs` endpoint
- Source Code: Well-commented
- Issues: Check error responses
- Logs: Server logs show detailed errors

## Next Steps

1. **Setup**: Follow QUICKSTART.md
2. **Explore**: Check ENDPOINTS.md
3. **Test**: Use Swagger UI at /docs
4. **Deploy**: Follow DEPLOYMENT.md

---

Generated: March 29, 2026
YEstateHub Backend API v1.0.0
