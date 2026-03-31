"""
Firebase Auth token verification using PyJWT + Google public keys.
No firebase_admin dependency needed — works on Python 3.14+.
"""
import jwt
import httpx
import time
from fastapi import HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

FIREBASE_PROJECT_ID = "yestatehub-jsv2026project"
GOOGLE_CERTS_URL = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

# Cache Google public keys
_cached_keys: dict = {}
_cache_expiry: float = 0

security = HTTPBearer(auto_error=False)


def _get_google_public_keys() -> dict:
    """Fetch and cache Google's public signing keys."""
    global _cached_keys, _cache_expiry
    now = time.time()
    if _cached_keys and now < _cache_expiry:
        return _cached_keys
    try:
        resp = httpx.get(GOOGLE_CERTS_URL, timeout=10)
        _cached_keys = resp.json()
        # Cache for 1 hour
        _cache_expiry = now + 3600
    except Exception:
        pass
    return _cached_keys


def _decode_token_unverified(token: str) -> dict:
    """Decode JWT without verification — fallback for dev/offline mode."""
    try:
        payload = jwt.decode(token, options={"verify_signature": False})
        return payload
    except Exception:
        return {}


async def verify_firebase_token(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    """
    Verify Firebase ID token.

    1. Tries full verification with Google public keys
    2. Falls back to unverified decode for development
    3. Falls back to dev user if no token provided
    """
    # No token provided — use dev user for easy testing
    if credentials is None:
        return {
            "uid": "dev_user_001",
            "email": "dev@yestatehub.com",
            "name": "Dev User",
            "picture": "",
        }

    token = credentials.credentials

    # Try full verification first
    try:
        public_keys = _get_google_public_keys()
        if public_keys:
            # Get the key ID from token header
            header = jwt.get_unverified_header(token)
            kid = header.get("kid", "")
            cert_pem = public_keys.get(kid)

            if cert_pem:
                decoded = jwt.decode(
                    token,
                    cert_pem,
                    algorithms=["RS256"],
                    audience=FIREBASE_PROJECT_ID,
                    issuer=f"https://securetoken.google.com/{FIREBASE_PROJECT_ID}",
                )
                return {
                    "uid": decoded.get("user_id") or decoded.get("sub", ""),
                    "email": decoded.get("email", ""),
                    "name": decoded.get("name", ""),
                    "picture": decoded.get("picture", ""),
                }
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.InvalidTokenError:
        pass  # Fall through to unverified decode
    except Exception:
        pass

    # Fallback: decode without verification (development mode)
    payload = _decode_token_unverified(token)
    if payload:
        return {
            "uid": payload.get("user_id") or payload.get("sub", "unknown"),
            "email": payload.get("email", ""),
            "name": payload.get("name", ""),
            "picture": payload.get("picture", ""),
        }

    raise HTTPException(status_code=401, detail="Invalid authentication token")


# For development/testing without real Firebase
async def get_dev_user() -> dict:
    """Dev-only: returns a mock user."""
    return {
        "uid": "dev_user_001",
        "email": "dev@yestatehub.com",
        "name": "Dev User",
        "picture": "",
    }
