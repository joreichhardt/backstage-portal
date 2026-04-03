provider "google" {
  project = "${{ values.projectId }}"
  region  = "${{ values.region }}"
}

resource "google_container_cluster" "primary" {
  name     = "${{ values.clusterName }}"
  location = "${{ values.region }}"

  # Standardmäßiger Pool wird sofort wieder entfernt (da wir eigene Pools nutzen)
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "my-node-pool"
  location   = "${{ values.region }}"
  cluster    = google_container_cluster.primary.name
  node_count = ${{ values.nodeCount }}

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
