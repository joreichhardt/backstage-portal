resource "google_project_service" "compute_api" {
  project = "${{ values.projectId }}"
  service = "compute.googleapis.com"
}

resource "google_project_service" "container_api" {
  count   = ${{ values.enableGKE }} ? 1 : 0
  project = "${{ values.projectId }}"
  service = "container.googleapis.com"
}

resource "google_project_service" "secretmanager_api" {
  count   = ${{ values.enableSecretManager }} ? 1 : 0
  project = "${{ values.projectId }}"
  service = "secretmanager.googleapis.com"
}
