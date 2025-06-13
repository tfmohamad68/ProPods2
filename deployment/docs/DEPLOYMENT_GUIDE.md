# Complete Deployment Guide for Twenty CRM on GCP

## Prerequisites

- Google Cloud Platform account
- Domain name with DNS control
- Basic knowledge of Docker and Linux

## Step 1: Create GCP VM

```bash
# Create the VM
gcloud compute instances create twenty-crm-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB \
  --boot-disk-type=pd-standard \
  --tags=http-server,https-server

# Create firewall rules
gcloud compute firewall-rules create allow-http \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:80 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=http-server

gcloud compute firewall-rules create allow-https \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:443 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=https-server
```

## Step 2: Initial VM Setup

SSH into the VM:
```bash
gcloud compute ssh twenty-crm-vm --zone=us-central1-a
```

Install Docker:
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker $USER
# Log out and back in for group changes
```

## Step 3: Deploy Twenty CRM

```bash
# Create directory
sudo mkdir -p /opt/twenty-crm
cd /opt/twenty-crm

# Copy docker-compose.yml from this repo
sudo wget https://raw.githubusercontent.com/tfmohamad68/ProPods2/main/deployment/gcp/docker-compose.yml

# Create .env file
sudo nano .env
# Copy contents from .env.example and update values

# Start services
sudo docker-compose up -d

# Initialize database (CRITICAL!)
sudo docker-compose exec server yarn database:init:prod
sudo docker-compose exec server yarn database:migrate:prod
```

## Step 4: Setup Nginx

```bash
# Install Nginx
sudo apt-get install -y nginx

# Create configuration
sudo nano /etc/nginx/sites-available/twenty-crm
# Copy contents from deployment/nginx/twenty-crm.conf

# Enable site
sudo ln -s /etc/nginx/sites-available/twenty-crm /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

## Step 5: SSL Certificate

```bash
# Install Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d your-domain.com
```

## Step 6: Configure DNS

Add an A record pointing to your VM's external IP.

## Troubleshooting

### "No workspace found" error
Run migrations again:
```bash
cd /opt/twenty-crm
sudo docker-compose exec server yarn database:migrate:prod
```

### "Relation core.user not found"
Database not initialized. Run:
```bash
sudo docker-compose exec server yarn database:init:prod
```

### Environment variable errors
Make sure ALL variables in .env.example are set in your .env file.

## Monitoring

- Health check: `curl http://localhost:3000/healthz`
- Logs: `sudo docker-compose logs -f server`
- Database: `sudo docker-compose exec db psql -U postgres default`
