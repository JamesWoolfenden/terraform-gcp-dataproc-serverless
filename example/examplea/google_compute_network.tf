# holden:ignore:HLD_GCP_094: Just enough to drive the module
# holden:ignore:HLD_GCP_303: Just enough to drive the module
resource "google_compute_network" "private" {
  name                    = "dataproc-serverless-private"
  auto_create_subnetworks = false
}
