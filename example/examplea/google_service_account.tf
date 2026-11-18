resource "google_service_account" "batch" {
  account_id   = "dataproc-batch"
  display_name = "Dataproc Serverless batch service account"
}
