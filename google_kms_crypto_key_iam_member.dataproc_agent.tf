resource "google_kms_crypto_key_iam_member" "dataproc_agent" {
  crypto_key_id = var.kms_key_name
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = local.dataproc_service_agent
}
