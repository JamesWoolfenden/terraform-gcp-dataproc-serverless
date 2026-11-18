output "id" {
  value       = google_dataproc_batch.main.id
  description = "ID of the Dataproc Serverless batch"
}

output "state" {
  value       = google_dataproc_batch.main.state
  description = "State of the batch at the time of the last refresh"
}

output "session_template_id" {
  value       = try(google_dataproc_session_template.main[0].id, null)
  description = "ID of the session template, or null when none is created"
}
