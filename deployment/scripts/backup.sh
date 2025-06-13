#!/bin/bash
# Backup Twenty CRM

BACKUP_DIR="/opt/backups/twenty-crm-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

cd /opt/twenty-crm
docker-compose exec db pg_dump -U postgres default > "$BACKUP_DIR/database.sql"
cp docker-compose.yml "$BACKUP_DIR/"
cp .env "$BACKUP_DIR/"

echo "Backup created: $BACKUP_DIR"
