resource "google_dns_managed_zone" "zone" {
  name        = "${{ values.zoneName }}"
  dns_name    = "${{ values.dnsName }}"
  description = "${{ values.description }}"
  project     = "${{ values.projectId }}"

  visibility = "public"
}
