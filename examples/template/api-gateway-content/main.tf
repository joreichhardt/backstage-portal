resource "google_api_gateway_api" "api" {
  provider = google-beta
  project  = "${{ values.projectId }}"
  api_id   = "${{ values.apiId }}"
}

resource "google_api_gateway_api_config" "api_cfg" {
  provider      = google-beta
  project       = "${{ values.projectId }}"
  api           = google_api_gateway_api.api.api_id
  api_config_id = "${{ values.apiId }}-config"

  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = filebase64("openapi.yaml")
    }
  }
}

resource "google_api_gateway_gateway" "gw" {
  provider   = google-beta
  project    = "${{ values.projectId }}"
  region     = "${{ values.region }}"
  api_config = google_api_gateway_api_config.api_cfg.id
  gateway_id = "${{ values.gatewayId }}"
}
