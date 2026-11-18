resource "google_dataproc_batch" "main" {
  batch_id = var.batch_id
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
      ttl             = var.ttl
      staging_bucket  = var.staging_bucket
      network_tags    = var.network_tags
    }
  }

  spark_batch {
    main_class    = var.spark_batch.main_class
    jar_file_uris = var.spark_batch.jar_file_uris
    args          = var.spark_batch.args
    file_uris     = var.spark_batch.file_uris
    archive_uris  = var.spark_batch.archive_uris
  }

  # Create blocks on the batch's operation, which completes only when the
  # batch finishes; the provider's default create timeout is far shorter than
  # a typical var.ttl, so a healthy long-running batch would fail the apply.
  timeouts {
    create = local.batch_create_timeout
  }

  depends_on = [time_sleep.iam_propagation]
}
