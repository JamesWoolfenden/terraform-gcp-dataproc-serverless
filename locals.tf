locals {
  # The Cloud Dataproc Service Agent — creates and manages the serverless
  # batch/session workloads and must be able to use the CMEK key.
  dataproc_service_agent = "serviceAccount:service-${data.google_project.current.number}@dataproc-accounts.iam.gserviceaccount.com"

  # The Compute Engine Service Agent — creates the persistent disks behind
  # serverless workloads, so it too must be able to use the CMEK key.
  compute_service_agent = "serviceAccount:service-${data.google_project.current.number}@compute-system.iam.gserviceaccount.com"

  # Batch run time limit plus 10 minutes for provisioning and teardown.
  batch_create_timeout = "${tonumber(trimsuffix(var.ttl, "s")) + 600}s"
}
