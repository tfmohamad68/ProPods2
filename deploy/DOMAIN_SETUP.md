# Domain Configuration for crm.4ow4.com

## Overview
This guide explains how to configure your domain (crm.4ow4.com) to point to your Cloud Run service.

## Prerequisites
- Domain registered and DNS management access
- GCP project with Cloud Run service deployed
- `gcloud` CLI installed and authenticated

## Steps

### 1. Get Your Cloud Run Service URL
```bash
gcloud run services describe propods-crm \
  --platform managed \
  --region us-central1 \
  --format 'value(status.url)' \
  --project YOUR_PROJECT_ID
```

### 2. Create Domain Mapping in Cloud Run
```bash
gcloud run domain-mappings create \
  --service propods-crm \
  --domain crm.4ow4.com \
  --region us-central1 \
  --project YOUR_PROJECT_ID
```

### 3. Configure DNS Records

After creating the domain mapping, you'll receive DNS records to add. Typically:

#### For root domain (4ow4.com):
- Type: A
- Name: @ or blank
- Value: (provided by Cloud Run)

#### For subdomain (crm.4ow4.com):
- Type: CNAME
- Name: crm
- Value: ghs.googlehosted.com

Or specific A/AAAA records as provided by Cloud Run.

### 4. Verify Domain Ownership

If required, add the TXT record for domain verification:
```
Type: TXT
Name: @ or as specified
Value: google-site-verification=XXXXX
```

### 5. SSL Certificate

Cloud Run automatically provisions and manages SSL certificates. This process can take up to 24 hours.

## Alternative: Using Cloud Load Balancer

For more control over routing and SSL:

1. Reserve a static IP:
```bash
gcloud compute addresses create crm-4ow4-ip \
  --global \
  --project YOUR_PROJECT_ID
```

2. Create a managed SSL certificate:
```bash
gcloud compute ssl-certificates create crm-4ow4-cert \
  --domains=crm.4ow4.com \
  --global \
  --project YOUR_PROJECT_ID
```

3. Set up load balancer with Cloud Run backend

## Troubleshooting

### DNS Propagation
- DNS changes can take up to 48 hours to propagate
- Use `dig crm.4ow4.com` or `nslookup crm.4ow4.com` to verify

### SSL Certificate Issues
- Check certificate status:
```bash
gcloud run domain-mappings describe \
  --domain crm.4ow4.com \
  --region us-central1 \
  --project YOUR_PROJECT_ID
```

### Common Issues
- Ensure domain is not using proxy (like Cloudflare proxy)
- Verify DNS records are exact matches
- Check Cloud Run service is accessible directly