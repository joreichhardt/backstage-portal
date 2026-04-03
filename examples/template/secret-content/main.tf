resource "google_secret_manager_secret" "secret" {
  project   = "${{ values.projectId }}"
  secret_id = "${{ values.secretId }}"

  replication {
    automatic = true
  }
}
