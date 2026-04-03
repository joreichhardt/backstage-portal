# 🚀 GCP Platform Engineering Portal with Backstage

This repository showcases a modern Internal Developer Portal (IDP) built with **Backstage**, designed to automate infrastructure provisioning on **Google Cloud Platform (GCP)**.

## 🌟 Key Features

- **Self-Service Infrastructure (Push-Button):** 10+ ready-to-use Scaffolder templates for:
  - **Computing:** GKE Clusters, Compute Instances (VMs).
  - **Storage & Databases:** Cloud Storage Buckets, Cloud SQL (PostgreSQL/MySQL).
  - **Networking:** VPC Peering, Cloud DNS, Domain Registration, API Gateway.
  - **Security:** Secret Manager, IAM Role Assignment, Cert Manager (SSL/Let's Encrypt).
- **Keyless Security (Workload Identity Federation):** Uses OIDC for GitHub Actions, eliminating the need for sensitive JSON keys in repositories.
- **Modern Backend System:** Built on the latest Backstage architecture for better modularity and performance.
- **Fully Containerized:** Multi-stage Dockerfile for reproducible builds and deployments.

## 🏗️ Architecture

1. **Frontend:** Backstage (React/TS) provides a seamless UI for developers.
2. **Scaffolder:** Automates the generation of **Terraform** code and GitHub Action workflows.
3. **CI/CD:** GitHub Actions triggers Terraform deployments directly into GCP.
4. **Auth:** Integrated with **GitHub OAuth** for secure developer login.

---

## ☁️ GCP Setup & Permissions

This portal uses **Workload Identity Federation (WIF)** to allow GitHub Actions to securely deploy resources to GCP without using long-lived JSON keys.

### 1. Enable Required APIs
Ensure the necessary APIs are enabled in your GCP project:
```bash
gcloud services enable \
    iam.googleapis.com \
    iamcredentials.googleapis.com \
    cloudresourcemanager.googleapis.com \
    sts.googleapis.com
```

### 2. Create a Service Account
Create a dedicated service account that Terraform will use to manage resources:
```bash
gcloud iam service-accounts create backstage-terraform \
    --display-name="Backstage Terraform Service Account"
```

### 2. Assign Required Roles
Assign the `Editor` role (for demo purposes) or specific roles (Compute Admin, Kubernetes Engine Admin, etc.) to the service account:
```bash
gcloud projects add-iam-policy-binding [PROJECT_ID] \
    --member="serviceAccount:backstage-terraform@[PROJECT_ID].iam.gserviceaccount.com" \
    --role="roles/editor"
```

### 3. Configure Workload Identity Federation (WIF)
Set up the trust relationship between GitHub and GCP:

```bash
# 1. Create the Workload Identity Pool
gcloud iam workload-identity-pools create backstage-pool \
    --location="global" \
    --display-name="Backstage Pool"

# 2. Create the OIDC Provider for GitHub
gcloud iam workload-identity-pools providers create-oidc github-provider \
    --location="global" \
    --workload-identity-pool="backstage-pool" \
    --display-name="GitHub Provider" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
    --issuer-uri="https://token.actions.githubusercontent.com"

# 3. Allow GitHub Actions to impersonate the Service Account
gcloud iam service-accounts add-iam-policy-binding backstage-terraform@[PROJECT_ID].iam.gserviceaccount.com \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/[PROJECT_NUMBER]/locations/global/workloadIdentityPools/backstage-pool/attribute.repository/[GITHUB_ORG]/[REPO_NAME]"
```

---

## 🛠️ Setup & Local Development

### 1. Prerequisites
- **Node.js 20+** (v22/v24 recommended)
- **Yarn 4**
- **Docker**
- **GCP Project** with a Workload Identity Pool and a Service Account.

### 2. Configuration (`.env`)
Create a `.env` file in the root directory and provide the following variables:

```bash
# Backstage Domain (use 'localhost' for local dev)
APP_DOMAIN=localhost

# GitHub OAuth (create an OAuth App in GitHub settings)
GITHUB_CLIENT_ID=ov23...
GITHUB_CLIENT_SECRET=8ce2...

# GitHub Integration (Personal Access Token with 'repo' and 'workflow' scopes)
GITHUB_TOKEN=ghp_...

# GCP Workload Identity (OIDC - Keyless)
GCP_WORKLOAD_IDENTITY_PROVIDER="projects/[PROJECT_NUMBER]/locations/global/workloadIdentityPools/backstage-pool/providers/github-provider"
GCP_SERVICE_ACCOUNT_EMAIL="backstage-terraform@[PROJECT_ID].iam.gserviceaccount.com"
```

### 3. Running Locally

Run the provided start script:
```bash
chmod +x start-local.sh
./start-local.sh
```
Access the portal at `http://localhost:3000`.

### 4. Running with Docker

Build and run the containerized app:
```bash
docker build -t backstage-portal .
docker run -p 7007:7007 --env-file .env backstage-portal
```

---

## 🛡️ Security Best Practices
- **No Hardcoded Secrets:** All credentials are provided via environment variables.
- **WIF-Powered CI/CD:** No static GCP keys are stored in GitHub; authentication is handled via OIDC.
- **Redacted Config:** Backstage automatically masks sensitive values in logs.

---
*Created by Johannes Reichhardt for showcasing Platform Engineering & DevOps excellence.*
