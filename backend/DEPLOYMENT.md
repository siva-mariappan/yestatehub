# YEstateHub Backend - Deployment Guide

## Pre-deployment Checklist

### Local Testing
- [ ] Run `pip install -r requirements.txt`
- [ ] Create `.env` file with all required variables
- [ ] Test server: `uvicorn main:app --reload`
- [ ] Verify all endpoints in Swagger UI: `http://localhost:8000/docs`
- [ ] Test authentication with valid Firebase token
- [ ] Test property creation/listing
- [ ] Test chat endpoints

### MongoDB Atlas Setup
- [ ] Create MongoDB Atlas cluster
- [ ] Create database user with strong password
- [ ] Whitelist IP addresses (or use 0.0.0.0/0 for development)
- [ ] Get connection string: `mongodb+srv://user:pass@cluster.mongodb.net/yestatehub`
- [ ] Verify connection with test query

### Firebase Setup
- [ ] Create Firebase project (if not already done)
- [ ] Enable Authentication
- [ ] Generate service account JSON key
- [ ] Download and place in backend directory
- [ ] Test token verification locally

## Environment Variables for Production

Create `.env` file with:
```env
# MongoDB Atlas
MONGODB_URI=mongodb+srv://[username]:[password]@[cluster].mongodb.net/yestatehub?retryWrites=true&w=majority
MONGODB_DB_NAME=yestatehub

# Firebase
FIREBASE_CREDENTIALS_PATH=./firebase-service-account.json

# CORS - Set your actual frontend URL
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

## Deployment Options

### Option 1: Heroku
```bash
# Install Heroku CLI
# Create Heroku account and app

# Create Procfile
echo "web: uvicorn main:app --host 0.0.0.0 --port \$PORT" > Procfile

# Create runtime.txt
echo "python-3.11.0" > runtime.txt

# Deploy
heroku login
heroku create your-app-name
heroku config:set MONGODB_URI="your_uri"
heroku config:set FIREBASE_CREDENTIALS_PATH="./firebase-service-account.json"
git push heroku main
```

### Option 2: AWS EC2
```bash
# SSH into instance
ssh -i key.pem ubuntu@your-instance-ip

# Install dependencies
sudo apt update
sudo apt install python3-pip python3-venv

# Clone your repository
git clone your-repo-url
cd backend

# Setup
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create .env file
nano .env

# Install and configure Nginx
sudo apt install nginx
# Create proxy config for localhost:8000

# Run with Gunicorn
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:8000 main:app
```

### Option 3: Docker

Create `Dockerfile`:
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      - MONGODB_URI=${MONGODB_URI}
      - FIREBASE_CREDENTIALS_PATH=./firebase-service-account.json
    volumes:
      - ./firebase-service-account.json:/app/firebase-service-account.json
```

Deploy:
```bash
docker build -t yestatehub-backend .
docker run -p 8000:8000 \
  -e MONGODB_URI="your_uri" \
  yestatehub-backend
```

### Option 4: Google Cloud Run
```bash
# Create app.yaml
cat > app.yaml << 'YAML'
runtime: python311
entrypoint: gunicorn -w 4 -b 0.0.0.0:8080 main:app

env_variables:
  MONGODB_URI: "your_uri"
YAML

# Deploy
gcloud app deploy
```

### Option 5: DigitalOcean App Platform
1. Connect GitHub repository
2. Set environment variables in console
3. Configure startup command: `uvicorn main:app --host 0.0.0.0 --port 8080`
4. Deploy from GitHub

## Performance Optimization

### Database Optimization
```python
# In database.py - Ensure indexes exist
await db.properties.create_index("owner_uid")
await db.properties.create_index("created_at")
await db.properties.create_index([("city", 1), ("transaction_type", 1)])

# Add compound indexes for common queries
await db.conversations.create_index([("participants.uid", 1), ("created_at", -1)])
```

### API Optimization
```python
# Use pagination
# Implement caching for frequently accessed properties
# Use connection pooling (Motor handles this automatically)

# Add query limits
limit: int = Query(100, ge=1, le=500)
```

### Server Configuration
```bash
# Use Gunicorn with multiple workers
gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app

# Adjust worker count based on CPU cores
# workers = (2 * cpu_count()) + 1
```

## Monitoring & Logging

### Application Logging
```python
# Add to main.py
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.on_event("startup")
async def startup():
    logger.info("Starting YEstateHub API")
    await connect_db()
    logger.info("Database connected")
```

### Database Monitoring
- Monitor MongoDB Atlas for:
  - Connection count
  - CPU usage
  - Memory usage
  - Network I/O
  - Query performance

### Error Tracking
```python
# Add Sentry integration
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn="your-sentry-dsn",
    integrations=[FastApiIntegration()]
)
```

## Security Checklist

- [ ] Use HTTPS/TLS in production
- [ ] Keep dependencies updated: `pip list --outdated`
- [ ] Use strong MongoDB credentials
- [ ] Whitelist specific IPs on MongoDB Atlas
- [ ] Implement rate limiting on endpoints
- [ ] Validate all user inputs
- [ ] Use environment variables for secrets
- [ ] Enable CORS only for known origins
- [ ] Implement request/response size limits
- [ ] Add authentication to all sensitive endpoints

## Backup Strategy

### MongoDB Atlas
- Enable automatic backups (daily)
- Test restore procedure
- Keep 30-day backup retention
- Set up point-in-time recovery

### Code Repository
- Use git with protected main branch
- Require pull requests for changes
- Enable branch protection rules

## Rollback Plan

If deployment fails:
```bash
# Roll back to previous version
git revert HEAD
git push

# Or update environment to previous working version
heroku releases
heroku rollback

# Or recreate from Docker image
docker run -p 8000:8000 yestatehub-backend:previous-version
```

## Performance Benchmarks

Target metrics:
- API response time: < 200ms (p95)
- Database query time: < 50ms (p95)
- 99.9% uptime
- Max concurrent connections: 1000+

## Scaling Considerations

### Vertical Scaling (More Resources)
- Increase server RAM and CPU
- Increase MongoDB instance size
- Not recommended for chat features (sticky sessions needed)

### Horizontal Scaling (Multiple Instances)
```bash
# Load balance across multiple app instances
# Use sticky sessions for WebSocket connections
# Deploy with Kubernetes or Docker Swarm
```

## Maintenance Windows

Schedule maintenance during low-traffic periods:
- Database updates: 2:00 AM - 4:00 AM
- Application updates: 3:00 AM - 5:00 AM
- Backup verification: Monthly
- Security patches: As needed

## Support & Troubleshooting

### Common Production Issues

**High Database Latency**
- Check MongoDB Atlas metrics
- Verify IP whitelist
- Optimize slow queries
- Consider connection pooling tuning

**WebSocket Disconnections**
- Check server logs for errors
- Verify firewall allows WebSocket traffic
- Implement reconnection logic on client
- Monitor connection pool usage

**Memory Leaks**
- Monitor application memory over time
- Check for unclosed database connections
- Review async task cleanup
- Use memory profiler: `pip install memory-profiler`

**Rate Limiting Issues**
- Implement token bucket algorithm
- Set reasonable rate limits per endpoint
- Cache frequently accessed data
- Consider CDN for static files

## Post-Deployment

1. Monitor for 24 hours
2. Check error logs and metrics
3. Verify all endpoints working
4. Load test with expected traffic
5. Document any issues and resolutions
6. Update team on deployment status
7. Set up alert notifications
8. Schedule post-deployment review

