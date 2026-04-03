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
