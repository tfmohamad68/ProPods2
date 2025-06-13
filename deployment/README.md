# Twenty CRM Deployment on GCP

This directory contains the complete working configuration for Twenty CRM deployed on Google Cloud Platform.

## Current Production Setup

- **URL**: https://crm.4ow4.com
- **Twenty Version**: v0.32.0
- **VM**: propods-crm-vm (34.132.198.201)
- **Status**: ✅ LIVE and WORKING

## Directory Structure

```
deployment/
├── gcp/
│   ├── docker-compose.yml      # Working Docker Compose configuration
│   └── .env.example            # Environment variables template
├── nginx/
│   └── twenty-crm.conf         # Nginx reverse proxy configuration
└── scripts/
    └── startup-script.sh       # VM startup script
```

## Deployment Instructions

### 1. Create VM
```bash
gcloud compute instances create propods-crm-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB \
  --tags=http-server,https-server
```

### 2. Install Docker
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
```

### 3. Deploy Twenty
```bash
# Create directory
sudo mkdir -p /opt/twenty-crm
cd /opt/twenty-crm

# Copy docker-compose.yml
sudo cp /path/to/deployment/gcp/docker-compose.yml .

# Create .env file (copy .env.example and fill in values)
sudo nano .env

# Start services
sudo docker-compose up -d

# Initialize database
sudo docker-compose exec server yarn database:init:prod
sudo docker-compose exec server yarn database:migrate:prod
```

### 4. Setup Nginx
```bash
# Install Nginx
sudo apt-get install -y nginx

# Copy configuration
sudo cp deployment/nginx/twenty-crm.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/twenty-crm /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

### 5. SSL Certificate
```bash
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d crm.4ow4.com
```

## Important Notes

1. **Database Initialization**: Twenty requires running migrations after first deployment
2. **Environment Variables**: All secrets must be set in .env file
3. **Version**: Using v0.32.0 as it's stable (latest had issues)
4. **Persistence**: Data is stored in Docker volumes

## Backup Strategy

Backups are stored at `/opt/backups/twenty-crm-*` on the VM.

To create a backup:
```bash
cd /opt/twenty-crm
docker-compose exec db pg_dump -U postgres default > backup.sql
```

## Monitoring

- Health check: https://crm.4ow4.com/healthz
- Logs: `docker-compose logs -f server`
