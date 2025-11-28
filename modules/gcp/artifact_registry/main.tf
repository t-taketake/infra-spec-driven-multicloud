resource "google_artifact_registry_repository" "main" {
  location      = var.location
  repository_id = var.name
  format        = var.format
  project       = var.project_id
  description   = var.description

  labels = var.labels

  dynamic "docker_config" {
    for_each = var.format == "DOCKER" && var.immutable_tags ? [1] : []
    content {
      immutable_tags = var.immutable_tags
    }
  }
}
