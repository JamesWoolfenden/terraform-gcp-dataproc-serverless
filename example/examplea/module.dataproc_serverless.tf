# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "dataproc_serverless" {
  source          = "../../"
  batch_id        = "example-sparkpi"
  region          = local.region
  kms_key_name    = google_kms_crypto_key.main.id
  subnetwork      = google_compute_subnetwork.workloads.self_link
  service_account = google_service_account.batch.email
  network_tags    = [local.network_tag]

  spark_batch = {
    main_class    = "org.apache.spark.examples.SparkPi"
    jar_file_uris = ["file:///usr/lib/spark/examples/jars/spark-examples.jar"]
    args          = ["1000"]
  }

  session_template = {
    name   = "example-jupyter"
    kernel = "PYTHON"
  }

  labels = {
    team = "data"
  }
}
