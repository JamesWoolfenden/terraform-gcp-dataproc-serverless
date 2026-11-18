# IAM grants return before they propagate; submitting a CMEK batch (or creating
# the session template) straight after them can fail on the first apply.
resource "time_sleep" "iam_propagation" {
  create_duration = "60s"

  depends_on = [
    google_kms_crypto_key_iam_member.dataproc_agent,
    google_kms_crypto_key_iam_member.compute_agent,
    google_project_iam_member.batch_sa_worker,
  ]
}
