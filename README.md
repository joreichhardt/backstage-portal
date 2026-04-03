# GCP Platform Engineering Portal with Backstage

An Internal Developer Portal (IDP) built with [Backstage](https://backstage.io), designed to automate infrastructure provisioning on **Google Cloud Platform (GCP)** via self-service Scaffolder templates.

---

## Key Features

- **Self-Service Infrastructure:** 12 ready-to-use templates for push-button GCP provisioning
  - **Compute:** GKE Clusters, Compute Instances (VMs)
  - **Storage & Databases:** Cloud Storage Buckets, Cloud SQL (PostgreSQL/MySQL)
  - **Networking:** VPC Peering, Cloud DNS, Domain Registration, API Gateway
  - **Security:** Secret Manager, IAM Role Assignment, Cert Manager (SSL/Let's Encrypt)
  - **Setup:** GCP Project API enablement
- **Keyless Security:** GitHub Actions authenticate to GCP via OIDC (Workload Identity Federation) — no JSON keys in repos
- **Modern Backstage Architecture:** New backend system (`createBackend()`) with Permission Framework enabled
- **Fully Containerized:** Multi-stage Dockerfile for reproducible builds

---

## Architecture

```
Developer → Backstage UI (React)
               ↓
         Scaffolder Template
               ↓
    Generated: Terraform + GitHub Actions Workflow
               ↓
    GitHub Actions → GCP (via Workload Identity Federation)
               ↓
         GCP Resources
```

---

## GCP Setup & Permissions

This portal uses **Workload Identity Federation (WIF)** to allow GitHub Actions to authenticate to GCP without long-lived JSON keys.

### 1. Enable Required APIs

```bash
gcloud services enable \
    iam.googleapis.com \
    iamcredentials.googleapis.com \
    cloudresourcemanager.googleapis.com \
    sts.googleapis.com
```

### 2. Create a Service Account

```bash
gcloud iam service-accounts create backstage-terraform \
    --display-name="Backstage Terraform Service Account"
```

### 3. Assign Required Roles

```bash
# For demo: Editor role. For production, prefer granular roles.
gcloud projects add-iam-policy-binding [PROJECT_ID] \
    --member="serviceAccount:backstage-terraform@[PROJECT_ID].iam.gserviceaccount.com" \
    --role="roles/editor"
```

### 4. Configure Workload Identity Federation

```bash
# Create the Workload Identity Pool
gcloud iam workload-identity-pools create backstage-pool \
    --location="global" \
    --display-name="Backstage Pool"

# Create the OIDC Provider for GitHub
gcloud iam workload-identity-pools providers create-oidc github-provider \
    --location="global" \
    --workload-identity-pool="backstage-pool" \
    --display-name="GitHub Provider" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
    --issuer-uri="https://token.actions.githubusercontent.com"

# Allow GitHub Actions to impersonate the Service Account
gcloud iam service-accounts add-iam-policy-binding \
    backstage-terraform@[PROJECT_ID].iam.gserviceaccount.com \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/[PROJECT_NUMBER]/locations/global/workloadIdentityPools/backstage-pool/attribute.repository/[GITHUB_ORG]/[REPO_NAME]"
```

---

## Configuration

The app uses two config files that are merged at startup:

| File | Purpose |
|---|---|
| `app-config.yaml` | Base config + local development defaults |
| `app-config.production.yaml` | Production overrides (DB, auth, TechDocs) |

### Environment Variables

Create a `.env` file in the root directory:

```bash
# Backstage domain
# Dev: leave unset or set to localhost (baseUrl is hardcoded to localhost in app-config.yaml)
# Prod: your actual domain, e.g. backstage.example.com
APP_DOMAIN=backstage.example.com

# GitHub OAuth App (create at github.com/settings/developers)
GITHUB_CLIENT_ID=your_client_id
GITHUB_CLIENT_SECRET=your_client_secret

# GitHub Personal Access Token (scopes: repo, workflow)
GITHUB_TOKEN=ghp_...

# Backend service-to-service auth secret (any strong random string)
BACKEND_SECRET=your_strong_random_secret

# GCP Workload Identity Federation
GCP_WORKLOAD_IDENTITY_PROVIDER="projects/[PROJECT_NUMBER]/locations/global/workloadIdentityPools/backstage-pool/providers/github-provider"
GCP_SERVICE_ACCOUNT_EMAIL="backstage-terraform@[PROJECT_ID].iam.gserviceaccount.com"

# Production only: PostgreSQL
POSTGRES_HOST=your_db_host
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=your_db_password

# Production only: TechDocs GCS bucket
TECHDOCS_GCS_BUCKET_NAME=your-techdocs-bucket
```

---

## Dev vs. Production Differences

| | Development | Production |
|---|---|---|
| **Config files** | `app-config.yaml` only | `app-config.yaml` + `app-config.production.yaml` |
| **Database** | SQLite (local file `./data`) | PostgreSQL |
| **Auth** | Guest mode + GitHub OAuth | GitHub OAuth only (no guest access) |
| **TechDocs** | Local builder, local publisher | External builder, Google Cloud Storage |
| **Backend URL** | `http://localhost:7007` | `https://${APP_DOMAIN}` |
| **Backend secret** | Required (`BACKEND_SECRET`) | Required (`BACKEND_SECRET`) |
| **Permissions** | Enabled (allow-all policy) | Enabled (allow-all policy) |
| **Search engine** | PostgreSQL module (falls back gracefully) | PostgreSQL |

### Why two config files?

Backstage merges config files in order. `app-config.production.yaml` overrides only what differs in production — database, auth, TechDocs, and URLs — without duplicating shared settings like integrations, Kubernetes, or Scaffolder configuration.

---

## Local Development

### Prerequisites

- Node.js 22 or 24
- Yarn 4
- Docker (for TechDocs generation)

### Setup

```bash
# 1. Install dependencies
yarn install

# 2. Create your .env (see above, only the non-production vars are needed locally)

# 3. Start the dev server
chmod +x start-local.sh
./start-local.sh
```

Access the portal at `http://localhost:3000`.

The dev server starts both frontend (port 3000) and backend (port 7007) with hot-reload.

---

## Production Deployment

### Docker

```bash
# Build
docker build -t backstage-portal .

# Run (pass all env vars from .env including production ones)
docker run -p 7007:7007 --env-file .env backstage-portal
```

The Docker image serves both frontend and backend from port 7007 using `app-config.yaml` + `app-config.production.yaml`.

### TechDocs (Production)

TechDocs docs are built externally (e.g., in CI) and published to GCS. Create the bucket before deploying:

```bash
gcloud storage buckets create gs://[TECHDOCS_GCS_BUCKET_NAME] \
    --location=EU \
    --uniform-bucket-level-access

# Grant the Backstage service account read access
gcloud storage buckets add-iam-policy-binding gs://[TECHDOCS_GCS_BUCKET_NAME] \
    --member="serviceAccount:backstage-terraform@[PROJECT_ID].iam.gserviceaccount.com" \
    --role="roles/storage.objectViewer"
```

---

## Security

- **No hardcoded secrets:** All credentials via environment variables
- **Workload Identity Federation:** No static GCP keys in GitHub
- **Backend secret:** Service-to-service auth between backend plugins
- **Permission Framework:** Enabled with allow-all policy by default — replace with a custom policy to restrict template execution by team/role

---

*Created by Johannes Reichhardt — Platform Engineering & DevOps*
