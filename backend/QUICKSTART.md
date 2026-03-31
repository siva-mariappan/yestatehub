# YEstateHub Backend - Quick Start Guide

## Installation (5 minutes)

```bash
# 1. Navigate to backend directory
cd /sessions/relaxed-beautiful-albattani/mnt/YestateHub/backend/

# 2. Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Setup environment variables
cp .env.example .env
# Edit .env with your credentials:
# - MongoDB Atlas URI
# - Firebase service account JSON path
```

## Configuration

Edit `.env`:
```env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/yestatehub?retryWrites=true&w=majority
MONGODB_DB_NAME=yestatehub
FIREBASE_CREDENTIALS_PATH=./firebase-service-account.json
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

## Running the Server

```bash
# Development (with auto-reload)
uvicorn main:app --reload

# Production
uvicorn main:app --host 0.0.0.0 --port 8000

# With specific workers
uvicorn main:app --workers 4
```

Server runs at: **http://localhost:8000**

## API Documentation

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

## Testing

### 1. Health Check
```bash
curl http://localhost:8000/health
```

### 2. List Properties (No Auth Required)
```bash
curl "http://localhost:8000/api/properties/?city=Delhi&limit=5"
```

### 3. Create Property (Auth Required)
```bash
curl -X POST http://localhost:8000/api/properties/ \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "2 BHK Apartment",
    "property_type": "apartment",
    "price": 5000000,
    "bedrooms": 2
  }'
```

## File Structure

```
backend/
├── main.py                    # FastAPI app
├── requirements.txt           # Dependencies
├── .env.example              # Config template
├── app/
│   ├── config.py             # Settings
│   ├── database.py           # MongoDB setup
│   ├── firebase_auth.py      # Firebase auth
│   ├── models/
│   │   ├── property.py       # Property schemas
│   │   └── chat.py           # Chat schemas
│   └── routes/
│       ├── auth.py           # Auth endpoints
│       ├── property.py       # Property endpoints
│       └── chat.py           # Chat + WebSocket
└── README.md                  # Full documentation
```

## Core Features

### Properties
- **Create**: POST `/api/properties/` (auth required)
- **List**: GET `/api/properties/?city=Delhi`
- **Get**: GET `/api/properties/{id}`
- **Update**: PUT `/api/properties/{id}` (owner only)
- **Delete**: DELETE `/api/properties/{id}` (owner only)
- **My Properties**: GET `/api/properties/my` (auth required)

### Chat
- **Create Conversation**: POST `/api/chat/conversations` (auth required)
- **List Conversations**: GET `/api/chat/conversations` (auth required)
- **Get Messages**: GET `/api/chat/conversations/{id}/messages` (auth required)
- **Send Message**: POST `/api/chat/messages` (auth required)
- **Real-time**: WebSocket `/api/chat/ws/{user_uid}`

### Auth
- **Sync User**: POST `/api/auth/sync` (auth required)
- **Get Profile**: GET `/api/auth/me` (auth required)

## Database Setup

MongoDB Atlas is automatically initialized with indexes on:
- `properties.owner_uid`
- `properties.created_at`
- `properties.city` + `properties.transaction_type`
- `conversations.participants`
- `conversations.property_id`
- `messages.conversation_id`
- `messages.created_at`

## Environment Variables

| Variable | Required | Example |
|----------|----------|---------|
| MONGODB_URI | Yes | `mongodb+srv://...` |
| MONGODB_DB_NAME | No | `yestatehub` |
| FIREBASE_CREDENTIALS_PATH | No | `./firebase-service-account.json` |
| ALLOWED_ORIGINS | No | `http://localhost:3000` |

## Debugging

### Enable Debug Logging
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

### Check MongoDB Connection
```bash
# Inside Python shell
python3
>>> from app.database import connect_db
>>> import asyncio
>>> asyncio.run(connect_db())
```

### Test Firebase Token Verification
```bash
# Get a Firebase token from your frontend
# Then test:
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/auth/me
```

## Common Issues

### MongoDB Connection Failed
- Check MONGODB_URI in .env
- Ensure IP whitelist on MongoDB Atlas
- Verify username/password

### Firebase Token Error
- Ensure firebase-service-account.json exists
- Check FIREBASE_CREDENTIALS_PATH in .env
- Verify token hasn't expired

### CORS Errors
- Update ALLOWED_ORIGINS in .env
- Check frontend URL matches ALLOWED_ORIGINS

### Port Already in Use
```bash
# Use different port
uvicorn main:app --port 8001
```

## Deployment Checklist

- [ ] Install production requirements
- [ ] Set secure environment variables
- [ ] Configure MongoDB Atlas IP whitelist
- [ ] Set ALLOWED_ORIGINS to production URLs
- [ ] Use uvicorn with multiple workers
- [ ] Enable HTTPS
- [ ] Set up logging
- [ ] Create backup strategy
- [ ] Monitor database usage
- [ ] Setup error tracking (Sentry, etc.)

## Support

For detailed API documentation, see: `ENDPOINTS.md`
For full setup guide, see: `README.md`
For architecture details, see: `FILE_MANIFEST.txt`
