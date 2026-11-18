locals {
  region      = "europe-west2" # single source of truth: workload region, subnet region and KMS key ring location must match
  network_tag = "dataproc-serverless"
}
