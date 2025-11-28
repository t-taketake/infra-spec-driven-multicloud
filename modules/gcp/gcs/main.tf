resource "google_storage_bucket" "main" {
  name          = var.bucket_name
  location      = var.location
  project       = var.project_id
  force_destroy = var.force_destroy
  storage_class = var.storage_class

  uniform_bucket_level_access = var.uniform_bucket_level_access

  versioning {
    enabled = var.versioning_enabled
  }

  encryption {
    default_kms_key_name = var.kms_key_name
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }

      condition {
        age                   = lookup(lifecycle_rule.value.condition, "age", null)
        created_before        = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state            = lookup(lifecycle_rule.value.condition, "with_state", null)
        matches_storage_class = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        num_newer_versions    = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
      }
    }
  }

  labels = var.labels
}
