output "repository_id" {
  description = "ID of the Artifact Registry repository"
  value       = module.artifact_registry.repository_id
}

output "repository_name" {
  description = "Name of the Artifact Registry repository"
  value       = module.artifact_registry.repository_name
}
