#!/bin/bash
# Quick deploy script for Twenty CRM

set -e

echo "Twenty CRM Quick Deploy"
echo "======================"

# Check if running as root
if [[ $EUID -ne 0 ]]; then 
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    apt-get update
    apt-get install -y docker.io docker-compose
fi

# Create directory
mkdir -p /opt/twenty-crm
cd /opt/twenty-crm

# Copy files
cp ../gcp/docker-compose.yml .
echo "Please create .env file with your configuration"
echo "See .env.example for required variables"

# Start services
docker-compose up -d

echo "Twenty CRM deployed!"
echo "Run these commands to initialize:"
echo "  docker-compose exec server yarn database:init:prod"
echo "  docker-compose exec server yarn database:migrate:prod"
