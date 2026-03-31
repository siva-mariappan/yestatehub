# YEstateHub API Endpoints Reference

## Base URL
```
http://localhost:8000
```

## Authentication

All endpoints marked with **[AUTH]** require a Firebase ID token in the Authorization header:
```
Authorization: Bearer <firebase_id_token>
```

---

## Auth Endpoints

### Sync User to Database
**POST** `/api/auth/sync` **[AUTH]**

Syncs Firebase user to MongoDB. Creates new user on first login, updates on subsequent logins.

**Request Headers:**
```
Authorization: Bearer <token>
```

**Response (201):**
```json
{
  "message": "User created",
  "uid": "user123",
  "is_new": true
}
```

---

### Get Current User Profile
**GET** `/api/auth/me` **[AUTH]**

Retrieves the current user's profile from MongoDB.

**Response (200):**
```json
{
  "id": "507f1f77bcf86cd799439011",
  "uid": "user123",
  "email": "user@example.com",
  "name": "John Doe",
  "picture": "https://...",
  "role": "user",
  "phone": "+919876543210",
  "created_at": "2026-03-29T10:30:00",
  "last_login": "2026-03-29T14:20:00"
}
```

---

## Property Endpoints

### Create Property
**POST** `/api/properties/` **[AUTH]**

Creates a new property listing.

**Request Body:**
```json
{
  "title": "2 BHK Apartment in Delhi",
  "description": "Spacious 2BHK with modern amenities",
  "purpose": "Sell",
  "property_type": "apartment",
  "transaction_type": "buy",
  "furnishing": "semi_furnished",
  "listed_by": "owner",
  "bedrooms": 2,
  "bathrooms": 2,
  "area_sqft": 1200,
  "floor": 3,
  "total_floors": 5,
  "facing": "North",
  "age_of_building": 5,
  "possession_status": "Ready to Move",
  "amenities": ["Parking", "Gym", "Pool"],
  "nearby_amenities": {"schools": 2, "hospitals": 1},
  "state": "Delhi",
  "district": "South Delhi",
  "city": "Delhi",
  "locality": "Sector 12",
  "pincode": "110089",
  "address": "123 Park Street",
  "price": 5000000,
  "negotiable": true,
  "images": ["https://...image1.jpg", "https://...image2.jpg"],
  "video_url": "https://youtube.com/...",
  "contact_name": "John Doe",
  "contact_phone": "+919876543210",
  "contact_email": "john@example.com"
}
```

**Response (200):**
```json
{
  "id": "507f1f77bcf86cd799439011",
  "title": "2 BHK Apartment in Delhi",
  "owner_uid": "user123",
  "owner_name": "John Doe",
  "owner_email": "john@example.com",
  "price": 5000000,
  "city": "Delhi",
  "property_type": "apartment",
  "bedrooms": 2,
  "views": 0,
  "created_at": "2026-03-29T10:30:00",
  "... other fields ..."
}
```

---

### List Properties (Public)
**GET** `/api/properties/`

Lists all properties with optional filters. Does NOT require authentication.

**Query Parameters:**
- `city` (string) - Filter by city name
- `transaction_type` (string) - buy, rent, pg, commercial
- `property_type` (string) - apartment, villa, plot, etc.
- `min_price` (float) - Minimum price
- `max_price` (float) - Maximum price
- `bedrooms` (integer) - Number of bedrooms
- `skip` (integer, default: 0) - Pagination offset
- `limit` (integer, default: 20, max: 100) - Results per page

**Example:**
```
GET /api/properties/?city=Delhi&property_type=apartment&min_price=3000000&bedrooms=2&skip=0&limit=10
```

**Response (200):**
```json
[
  {
    "id": "507f1f77bcf86cd799439011",
    "title": "2 BHK Apartment",
    "city": "Delhi",
    "price": 5000000,
    "bedrooms": 2,
    "views": 45,
    "created_at": "2026-03-29T10:30:00",
    "... other fields ..."
  }
]
```

---

### Get User's Properties
**GET** `/api/properties/my` **[AUTH]**

Retrieves all properties listed by the current user.

**Query Parameters:**
- `skip` (integer, default: 0)
- `limit` (integer, default: 50, max: 100)

**Response (200):**
```json
[
  {
    "id": "507f1f77bcf86cd799439011",
    "title": "2 BHK Apartment",
    "owner_uid": "user123",
    "... other fields ..."
  }
]
```

---

### Get Single Property
**GET** `/api/properties/{property_id}`

Retrieves a single property by ID. Also increments view count.

**Response (200):**
```json
{
  "id": "507f1f77bcf86cd799439011",
  "title": "2 BHK Apartment",
  "views": 46,
  "... all property fields ..."
}
```

**Error Responses:**
- `400` - Invalid property ID format
- `404` - Property not found

---

### Update Property
**PUT** `/api/properties/{property_id}` **[AUTH]**

Updates a property. Only the property owner can update.

**Request Body (all fields optional):**
```json
{
  "title": "Updated Title",
  "description": "Updated description",
  "price": 4500000,
  "negotiable": false,
  "images": ["https://...new_image.jpg"],
  "amenities": ["Parking", "Gym", "Garden"],
  "furnishing": "furnished",
  "possession_status": "Ready to Move"
}
```

**Response (200):**
```json
{
  "id": "507f1f77bcf86cd799439011",
  "title": "Updated Title",
  "updated_at": "2026-03-29T15:45:00",
  "... all fields ..."
}
```

**Error Responses:**
- `403` - Not authorized (not the property owner)
- `404` - Property not found

---

### Delete Property
**DELETE** `/api/properties/{property_id}` **[AUTH]**

Deletes a property. Only the property owner can delete.

**Response (200):**
```json
{
  "message": "Property deleted successfully"
}
```

**Error Responses:**
- `403` - Not authorized
- `404` - Property not found

---

## Chat Endpoints

### Create/Get Conversation
**POST** `/api/chat/conversations` **[AUTH]**

Creates a new conversation or returns existing one between two users for a property.

**Request Body:**
```json
{
  "property_id": "507f1f77bcf86cd799439011",
  "property_title": "2 BHK Apartment in Delhi",
  "participant_uid": "user456",
  "participant_name": "Jane Smith"
}
```

**Response (200):**
```json
{
  "id": "507f1f77bcf86cd799439012",
  "property_id": "507f1f77bcf86cd799439011",
  "property_title": "2 BHK Apartment in Delhi",
  "participants": [
    {
      "uid": "user123",
      "name": "John Doe",
      "email": "john@example.com"
    },
    {
      "uid": "user456",
      "name": "Jane Smith",
      "email": ""
    }
  ],
  "last_message": "When can we visit?",
  "last_message_time": "2026-03-29T14:00:00",
  "unread_count": 2,
  "created_at": "2026-03-29T10:30:00"
}
```

---

### List User Conversations
**GET** `/api/chat/conversations` **[AUTH]**

Lists all conversations for the current user.

**Query Parameters:**
- `skip` (integer, default: 0)
- `limit` (integer, default: 50, max: 100)

**Response (200):**
```json
[
  {
    "id": "507f1f77bcf86cd799439012",
    "property_id": "507f1f77bcf86cd799439011",
    "property_title": "2 BHK Apartment in Delhi",
    "participants": [...],
    "last_message": "When can we visit?",
    "last_message_time": "2026-03-29T14:00:00",
    "unread_count": 2,
    "created_at": "2026-03-29T10:30:00"
  }
]
```

---

### Get Conversation Messages
**GET** `/api/chat/conversations/{conversation_id}/messages` **[AUTH]**

Retrieves all messages in a conversation. Automatically marks messages as read.

**Query Parameters:**
- `skip` (integer, default: 0)
- `limit` (integer, default: 100, max: 500)

**Response (200):**
```json
[
  {
    "id": "507f1f77bcf86cd799439013",
    "conversation_id": "507f1f77bcf86cd799439012",
    "sender_uid": "user123",
    "sender_name": "John Doe",
    "text": "Hello, I'm interested in this property",
    "is_read": true,
    "created_at": "2026-03-29T13:00:00"
  },
  {
    "id": "507f1f77bcf86cd799439014",
    "conversation_id": "507f1f77bcf86cd799439012",
    "sender_uid": "user456",
    "sender_name": "Jane Smith",
    "text": "Great! When can we schedule a visit?",
    "is_read": true,
    "created_at": "2026-03-29T13:30:00"
  }
]
```

**Error Responses:**
- `403` - Not a participant in this conversation
- `404` - Conversation not found

---

### Send Message
**POST** `/api/chat/messages` **[AUTH]**

Sends a message in a conversation.

**Request Body:**
```json
{
  "conversation_id": "507f1f77bcf86cd799439012",
  "text": "Can we schedule a visit tomorrow?"
}
```

**Response (200):**
```json
{
  "id": "507f1f77bcf86cd799439015",
  "conversation_id": "507f1f77bcf86cd799439012",
  "sender_uid": "user123",
  "sender_name": "John Doe",
  "text": "Can we schedule a visit tomorrow?",
  "is_read": false,
  "created_at": "2026-03-29T14:00:00"
}
```

**Error Responses:**
- `403` - Not a participant
- `404` - Conversation not found

---

### WebSocket: Real-time Chat Notifications
**WS** `/api/chat/ws/{user_uid}`

Establishes a WebSocket connection for real-time chat notifications.

**Connection:**
```javascript
const ws = new WebSocket('ws://localhost:8000/api/chat/ws/user123');

ws.onopen = () => {
  console.log('Connected');
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log(data);
};
```

**Incoming Messages:**
```json
{
  "type": "new_message",
  "conversation_id": "507f1f77bcf86cd799439012",
  "message": {
    "id": "507f1f77bcf86cd799439015",
    "conversation_id": "507f1f77bcf86cd799439012",
    "sender_uid": "user456",
    "sender_name": "Jane Smith",
    "text": "Yes, tomorrow at 3 PM works for me",
    "is_read": false,
    "created_at": "2026-03-29T14:05:00"
  }
}
```

**Typing Indicator (Send):**
```javascript
ws.send(JSON.stringify({
  type: 'typing',
  conversation_id: 'conversation_id'
}));
```

**Typing Indicator (Receive):**
```json
{
  "type": "typing",
  "conversation_id": "507f1f77bcf86cd799439012",
  "user_uid": "user456"
}
```

---

## Health & Diagnostics

### Health Check
**GET** `/health`

Simple health check endpoint.

**Response (200):**
```json
{
  "status": "ok"
}
```

---

### Root/API Info
**GET** `/`

Returns API information and endpoint list.

**Response (200):**
```json
{
  "app": "YEstateHub API",
  "version": "1.0.0",
  "docs": "/docs",
  "endpoints": {
    "auth": "/api/auth/sync",
    "properties": "/api/properties/",
    "chat_conversations": "/api/chat/conversations",
    "chat_messages": "/api/chat/messages",
    "websocket": "/api/chat/ws/{user_uid}"
  }
}
```

---

## Common Error Responses

### 400 Bad Request
```json
{
  "detail": "Invalid property ID"
}
```

### 401 Unauthorized
```json
{
  "detail": "Invalid authentication: {error_details}"
}
```

### 403 Forbidden
```json
{
  "detail": "Not authorized"
}
```

### 404 Not Found
```json
{
  "detail": "Property not found"
}
```

### 422 Validation Error
```json
{
  "detail": [
    {
      "loc": ["body", "price"],
      "msg": "ensure this value is greater than 0",
      "type": "value_error.number.not_gt"
    }
  ]
}
```

---

## Status Codes

| Code | Meaning |
|------|---------|
| 200  | OK - Request successful |
| 201  | Created - Resource created |
| 400  | Bad Request - Invalid input |
| 401  | Unauthorized - Missing/invalid token |
| 403  | Forbidden - Not authorized for resource |
| 404  | Not Found - Resource doesn't exist |
| 422  | Validation Error - Invalid request data |
| 500  | Server Error |

