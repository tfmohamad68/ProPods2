# Troubleshooting Guide

Based on actual deployment experience at crm.4ow4.com

## Common Issues and Solutions

### 1. Workspace Schema Not Found

**Error**: "Workspace Schema not found for workspace..."

**Solution**: 
Twenty needs proper database initialization. The workspace schema isn't created automatically.

```bash
# Run these commands in order:
docker-compose exec server yarn database:init:prod
docker-compose exec server yarn database:migrate:prod
docker-compose restart server
```

### 2. Environment Variable Validation Failed

**Error**: "property FRONT_BASE_URL has failed the following constraints: isUrl"

**Solution**:
Twenty v0.32.0 requires these additional variables:
- FRONT_BASE_URL (must be a valid URL)
- ACCESS_TOKEN_SECRET
- REFRESH_TOKEN_SECRET  
- LOGIN_TOKEN_SECRET

### 3. Container Unhealthy / 502 Bad Gateway

**Causes**:
- Missing environment variables
- Database not initialized
- Port conflicts

**Solution**:
Check logs first:
```bash
docker-compose logs server --tail 50
```

### 4. Redirect Loop with Cloudflare

**Solution**:
In Cloudflare:
1. Set SSL/TLS to "Full"
2. Turn OFF "Always Use HTTPS"
3. Or set DNS to "DNS only" (gray cloud)

### 5. "No metadata for workspaceMember"

**Solution**:
This happens when Twenty's metadata tables aren't populated. Usually fixed by proper migration:
```bash
docker-compose exec server yarn database:init:prod
docker-compose exec server yarn database:migrate:prod
```

## Version Notes

- **v0.32.0**: Stable, recommended
- **latest**: May have initialization issues
- **v0.31.0**: Requires additional env variables

## Getting Help

1. Check server logs: `docker-compose logs server`
2. Check database: `docker-compose exec db psql -U postgres default -c "\dt"`
3. Health endpoint: `curl http://localhost:3000/healthz`
