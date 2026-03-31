# YEstateHub Backend API

A complete FastAPI + MongoDB Atlas backend for a real estate platform with property listings and real-time chat features.

## Project Structure

```
backend/
├── main.py                          # FastAPI app entry point
├── requirements.txt                 # Python dependencies
├── .env.example                     # Environment variables template
├── app/
│   ├── __init__.py
│   ├── config.py                    # Configuration from environment
│   ├── database.py                  # MongoDB connection & indexes
│   ├── firebase_auth.py             # Firebase token verification
│   ├── models/
│   │   ├── __init__.py
│   │   ├── property.py              # Property schemas (Pydantic)
│   │   └── chat.py                  # Chat schemas (Pydantic)
│   └── routes/
│       ├── __init__.py
│       ├── auth.py                  # Authentication endpoints
│       ├── property.py              # Property CRUD endpoints
│       └── chat.py                  # Chat & WebSocket endpoints
```

## Features

### 1. Authentication (`/api/auth`)
- `POST /api/auth/sync` - Sync Firebase user to MongoDB
- `GET /api/auth/me` - Get current user profile

### 2. Properties (`/api/properties`)
- `POST /` - Create new property listing (auth required)
- `GET /` - List properties with filters (public)
- `GET /my` - Get user's properties (auth required)
- `GET /{property_id}` - Get single property (public)
- `PUT /{property_id}` - Update property (owner only)
- `DELETE /{property_id}` - Delete property (owner only)

### 3. Chat (`/api/chat`)
- `POST /conversations` - Create/get conversation (auth required)
- `GET /conversations` - List user's conversations (auth required)
- `GET /conversations/{id}/messages` - Get messages (auth required)
- `POST /messages` - Send message (auth required)
- `WebSocket /ws/{user_uid}` - Real-time notifications

## Setup

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Configure Environment
```bash
cp .env.example .env
```

Edit `.env` with your credentials:
- `MONGODB_URI` - MongoDB Atlas connection string
- `MONGODB_DB_NAME` - Database name (default: yestatehub)
- `FIREBASE_CREDENTIALS_PATH` - Path to Firebase service account JSON
- `ALLOWED_ORIGINS` - CORS allowed origins

### 3. Firebase Setup
Place your `firebase-service-account.json` in the backend directory or update the path in `.env`.

### 4. Run Server
```bash
uvicorn main:app --reload
```

Server runs on `http://localhost:8000`
- API docs: `http://localhost:8000/docs`
- Health check: `http://localhost:8000/health`

## Environment Variables

```env
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/yestatehub?retryWrites=true&w=majority
MONGODB_DB_NAME=yestatehub
FIREBASE_CREDENTIALS_PATH=./firebase-service-account.json
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

## Database Schema

### Collections

**properties**
- owner_uid, created_at, city, transaction_type indexes
- Fields: title, description, property_type, bedrooms, price, location, images, etc.

**conversations**
- participants, property_id indexes
- Fields: property_id, participants, last_message, created_at

**messages**
- conversation_id, created_at indexes
- Fields: conversation_id, sender_uid, text, is_read, created_at

**users**
- uid unique index
- Fields: uid, email, name, picture, role, phone, created_at, last_login

## Authentication

All protected endpoints require Firebase ID token in Authorization header:
```
Authorization: Bearer <firebase_id_token>
```

## Error Handling

- `400` - Invalid request
- `401` - Invalid/missing token
- `403` - Forbidden (not authorized)
- `404` - Not found
- `500` - Server error

## WebSocket Example

```javascript
const ws = new WebSocket('ws://localhost:8000/api/chat/ws/user_id');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  if (data.type === 'new_message') {
    console.log('New message:', data.message);
  }
};

// Send typing indicator
ws.send(JSON.stringify({
  type: 'typing',
  conversation_id: 'conv_id'
}));
```

## Development

- All endpoints are fully async using Motor (async MongoDB driver)
- Pydantic models for request/response validation
- Firebase Admin SDK for token verification
- CORS enabled for frontend origins
