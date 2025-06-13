# GCP Deployment Configuration

This directory contains the working production configuration for Twenty CRM on Google Cloud Platform.

## Files

- `docker-compose.production.yml` - The working Docker Compose configuration
- `.env.example` - Example environment variables (copy to `.env` and update values)

## Deployment Steps

1. Copy these files to your VM at `/opt/twenty-crm/`
2. Create `.env` file with your actual values
3. Run: `docker compose up -d`
4. Initialize database: `docker compose exec server yarn database:init:prod`
5. Run migrations: `docker compose exec server yarn database:migrate:prod`

## Current Production Setup

- VM: propods-crm-vm (34.132.198.201)
- Twenty Version: v0.32.0
- Domain: crm.4ow4.com
- SSL: Let's Encrypt via Nginx

## Backup Location

Backups are stored at: `/opt/backups/twenty-crm-*`
