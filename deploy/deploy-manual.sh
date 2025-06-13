#!/bin/bash

# Manual deployment script for ProPods CRM to GCP

set -e

# Configuration
PROJECT_ID="${GCP_PROJECT_ID:-your-project-id}"
REGION="${GCP_REGION:-us-central1}"
SERVICE_NAME="${SERVICE_NAME:-propods-crm}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "Deploying ProPods CRM to GCP..."
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Service: $SERVICE_NAME"

# Build Docker image
echo "Building Docker image..."
docker build -t gcr.io/$PROJECT_ID/$SERVICE_NAME:$IMAGE_TAG \
  --build-arg REACT_APP_SERVER_BASE_URL=https://crm.4ow4.com \
  --build-arg APP_VERSION=$IMAGE_TAG \
  .

# Push to Google Container Registry
echo "Pushing image to GCR..."
docker push gcr.io/$PROJECT_ID/$SERVICE_NAME:$IMAGE_TAG

# Deploy to Cloud Run
echo "Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image gcr.io/$PROJECT_ID/$SERVICE_NAME:$IMAGE_TAG \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --set-env-vars="NODE_ENV=production,SERVER_URL=https://crm.4ow4.com,STORAGE_TYPE=gcs" \
  --set-secrets="PG_DATABASE_URL=pg-database-url:latest,REDIS_URL=redis-url:latest,APP_SECRET=app-secret:latest,EMAIL_SMTP_PASSWORD=email-smtp-password:latest" \
  --memory 2Gi \
  --cpu 2 \
  --min-instances 1 \
  --max-instances 10 \
  --add-cloudsql-instances $PROJECT_ID:$REGION:${SERVICE_NAME}-db \
  --project $PROJECT_ID

# Deploy worker service
echo "Deploying worker service..."
gcloud run deploy ${SERVICE_NAME}-worker \
  --image gcr.io/$PROJECT_ID/$SERVICE_NAME:$IMAGE_TAG \
  --platform managed \
  --region $REGION \
  --no-allow-unauthenticated \
  --args yarn,worker:prod \
  --set-env-vars="NODE_ENV=production,SERVER_URL=https://crm.4ow4.com,STORAGE_TYPE=gcs,DISABLE_DB_MIGRATIONS=true" \
  --set-secrets="PG_DATABASE_URL=pg-database-url:latest,REDIS_URL=redis-url:latest,APP_SECRET=app-secret:latest,EMAIL_SMTP_PASSWORD=email-smtp-password:latest" \
  --memory 2Gi \
  --cpu 2 \
  --min-instances 1 \
  --max-instances 5 \
  --add-cloudsql-instances $PROJECT_ID:$REGION:${SERVICE_NAME}-db \
  --project $PROJECT_ID

# Get service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --platform managed --region $REGION --format 'value(status.url)' --project $PROJECT_ID)
echo "Service deployed at: $SERVICE_URL"

echo ""
echo "Deployment complete!"
echo "Don't forget to:"
echo "1. Configure your domain (crm.4ow4.com) to point to: $SERVICE_URL"
echo "2. Set up Cloud Run domain mapping:"
echo "   gcloud run domain-mappings create --service $SERVICE_NAME --domain crm.4ow4.com --region $REGION --project $PROJECT_ID"