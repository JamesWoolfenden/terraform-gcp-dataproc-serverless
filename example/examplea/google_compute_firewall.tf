# Dataproc Serverless requires the subnet to allow ingress between workload
# VMs on all ports (driver <-> executor traffic); without it the batch fails.
# Scoped to the workload network tag in both directions.
# holden:ignore:HLD_GCP_290: Dataproc Serverless needs all ports open between its own workload VMs; source and target are both limited to the workload tag
resource "google_compute_firewall" "workload_internal" {
  name      = "dataproc-serverless-internal"
  network   = google_compute_network.private.id
  direction = "INGRESS"
  priority  = 1000

  source_tags = [local.network_tag]
  target_tags = [local.network_tag]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
