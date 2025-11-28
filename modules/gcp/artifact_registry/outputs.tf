output "repository_id" {
  description = "ID of the Artifact Registry repository"
  value       = google_artifact_registry_repository.main.id
}

output "repository_name" {
  description = "Name of the Artifact Registry repository"
  value       = google_artifact_registry_repository.main.name
}
