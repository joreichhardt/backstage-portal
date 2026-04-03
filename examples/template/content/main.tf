resource "google_storage_bucket" "static-site" {
  name          = "${{ values.bucketName }}"
  location      = "${{ values.region }}"
  storage_class = "${{ values.storageClass }}"

  uniform_bucket_level_access = true
}
