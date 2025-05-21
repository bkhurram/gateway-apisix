# APISIX Gateway with Auth Header Middleware

This project demonstrates a simple API gateway setup using Apache APISIX with a custom authentication header validation middleware.

## Project Structure

```
gateway-apisix/
├── conf/
│   ├── conf.yaml           # APISIX configuration
│   ├── apisix.yaml         # APISIX routes configuration
│   └── dashboard_conf.yaml # APISIX Dashboard configuration
├── plugins/
│   ├── auth-header.lua     # Custom auth header plugin
│   └── key-auth.lua        # Key authentication plugin
├── mock-api/               # Simple Express.js API for testing
│   ├── package.json
│   └── server.js
└── docker-compose.yml
```

## Getting Started

1. Start the services:

```bash
docker-compose up
```

2. Test the endpoints:

   Public endpoint (no auth required):
   ```bash
   curl http://localhost:9080/public/info
   ```

   Secure endpoint (auth required):
   ```bash
   # This will fail with 401 Unauthorized
   curl http://localhost:9080/api/secure

   # This will succeed
   curl http://localhost:9080/api/secure \
     -H "X-API-Key: your-api-key" \
     -H "Authorization: Bearer your-token"
   ```

## How It Works

- The gateway runs on port 9080 and provides two routes:
  - `/api/*`: Requires authentication headers
  - `/public/*`: No authentication required

- The custom `auth-header` plugin validates that required headers are present in requests to protected routes.

- Both routes proxy to the mock API running on port 8080.

## APISIX Dashboard

The APISIX Dashboard provides a web UI for managing APISIX configuration:

- Accessible at http://localhost:9000
- Default login credentials:
  - Username: admin
  - Password: admin

**Features of the Dashboard:**
- View and manage routes, services, and consumers
- Configure plugins visually
- Monitor APISIX status
- Manage API endpoints without editing configuration files