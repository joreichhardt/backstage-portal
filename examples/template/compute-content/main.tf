resource "google_compute_instance" "vm" {
  name         = "${{ values.instanceName }}"
  machine_type = "${{ values.machineType }}"
  zone         = "${{ values.zone }}"

  boot_disk {
    initialize_params {
      image = "${{ values.image }}"
    }
  }

  network_interface {
    network = "${{ values.network }}"
    access_config {
      # Gibt der VM eine externe IP
    }
  }
}
