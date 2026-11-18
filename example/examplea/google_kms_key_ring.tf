resource "google_kms_key_ring" "main" {
  name     = "dataproc-serverless-keyring"
  location = local.region
}
