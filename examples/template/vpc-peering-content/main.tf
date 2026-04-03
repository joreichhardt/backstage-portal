resource "google_compute_network_peering" "peering1" {
  name         = "${{ values.peeringName }}"
  network      = "${{ values.localNetwork }}"
  peer_network = "${{ values.peerNetwork }}"

  export_custom_routes = ${{ values.exportRoutes }}
  import_custom_routes = ${{ values.importRoutes }}
}
