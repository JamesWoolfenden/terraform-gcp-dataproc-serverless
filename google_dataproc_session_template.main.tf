resource "google_dataproc_session_template" "main" {
  count = var.session_template == null ? 0 : 1

  name     = "projects/${data.google_project.current.project_id}/locations/${var.region}/sessionTemplates/${var.session_template.name}"
  location = var.region
  labels   = var.labels

  runtime_config {
    version    = var.runtime_version
    properties = var.spark_properties
  }

  environment_config {
    execution_config {
      service_account = var.service_account
      subnetwork_uri  = var.subnetwork
      kms_key         = var.kms_key_name
      idle_ttl        = var.session_template.idle_ttl
      ttl             = var.ttl
      staging_bucket  = var.staging_bucket
      network_tags    = var.network_tags
    }
  }

  jupyter_session {
    kernel       = var.session_template.kernel
    display_name = var.session_template.display_name
  }

  depends_on = [time_sleep.iam_propagation]
}
