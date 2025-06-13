#!/bin/bash

# GCP Setup Script for ProPods CRM
# This script sets up the necessary GCP resources for deploying the CRM

set -e

# Configuration
PROJECT_ID="${GCP_PROJECT_ID:-your-project-id}"
REGION="${GCP_REGION:-us-central1}"
SERVICE_NAME="${SERVICE_NAME:-propods-crm}"
DOMAIN="crm.4ow4.com"

echo "Setting up GCP resources for ProPods CRM..."
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"

# Enable required APIs
echo "Enabling required APIs..."
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  secretmanager.googleapis.com \
  compute.googleapis.com \
  sqladmin.googleapis.com \
  redis.googleapis.com \
  --project=$PROJECT_ID

# Create Artifact Registry repository
echo "Creating Artifact Registry repository..."
gcloud artifacts repositories create $SERVICE_NAME \
  --repository-format=docker \
  --location=$REGION \
  --project=$PROJECT_ID || echo "Repository already exists"

# Create Cloud SQL instance
echo "Creating Cloud SQL instance..."
gcloud sql instances create ${SERVICE_NAME}-db \
  --database-version=POSTGRES_15 \
  --tier=db-g1-small \
  --region=$REGION \
  --project=$PROJECT_ID || echo "SQL instance already exists"

# Create database
echo "Creating database..."
gcloud sql databases create default \
  --instance=${SERVICE_NAME}-db \
  --project=$PROJECT_ID || echo "Database already exists"

# Create database user
echo "Creating database user..."
gcloud sql users create crm_user \
  --instance=${SERVICE_NAME}-db \
  --password=temp_password_change_me \
  --project=$PROJECT_ID || echo "User already exists"

# Create Redis instance
echo "Creating Redis instance..."
gcloud redis instances create ${SERVICE_NAME}-redis \
  --size=1 \
  --region=$REGION \
  --redis-version=redis_7_0 \
  --project=$PROJECT_ID || echo "Redis instance already exists"

# Create secrets
echo "Creating secrets..."
echo "Please update these secrets with actual values:"

# Create app secret
gcloud secrets create app-secret \
  --data-file=- \
  --project=$PROJECT_ID <<< "your_secure_random_string_at_least_32_characters_long" || echo "Secret already exists"

# Create database URL secret (update with actual connection string)
gcloud secrets create pg-database-url \
  --data-file=- \
  --project=$PROJECT_ID <<< "postgresql://crm_user:your_password@/default?host=/cloudsql/$PROJECT_ID:$REGION:${SERVICE_NAME}-db" || echo "Secret already exists"

# Create Redis URL secret (update with actual connection string)
gcloud secrets create redis-url \
  --data-file=- \
  --project=$PROJECT_ID <<< "redis://10.0.0.1:6379" || echo "Secret already exists"

# Create email SMTP password secret
gcloud secrets create email-smtp-password \
  --data-file=- \
  --project=$PROJECT_ID <<< "your_smtp_password" || echo "Secret already exists"

# Grant permissions to Cloud Run service account
echo "Granting permissions..."
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

# Grant access to secrets
gcloud secrets add-iam-policy-binding app-secret \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/secretmanager.secretAccessor" \
  --project=$PROJECT_ID

gcloud secrets add-iam-policy-binding pg-database-url \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/secretmanager.secretAccessor" \
  --project=$PROJECT_ID

gcloud secrets add-iam-policy-binding redis-url \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/secretmanager.secretAccessor" \
  --project=$PROJECT_ID

gcloud secrets add-iam-policy-binding email-smtp-password \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/secretmanager.secretAccessor" \
  --project=$PROJECT_ID

# Grant Cloud SQL access
gcloud sql instances add-iam-policy-binding ${SERVICE_NAME}-db \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/cloudsql.client" \
  --project=$PROJECT_ID

echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update the secrets with actual values:"
echo "   - gcloud secrets versions add app-secret --data-file=- --project=$PROJECT_ID"
echo "   - gcloud secrets versions add pg-database-url --data-file=- --project=$PROJECT_ID"
echo "   - gcloud secrets versions add redis-url --data-file=- --project=$PROJECT_ID"
echo "   - gcloud secrets versions add email-smtp-password --data-file=- --project=$PROJECT_ID"
echo ""
echo "2. Configure your domain (crm.4ow4.com) to point to Cloud Run"
echo "3. Update the GitHub secrets:"
echo "   - GCP_PROJECT_ID: $PROJECT_ID"
echo "   - GCP_SA_KEY: Service account key JSON"
echo ""
echo "4. Push to main branch to trigger deployment"