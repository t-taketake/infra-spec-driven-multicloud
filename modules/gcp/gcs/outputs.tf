output "bucket_name" {
  description = "Name of the GCS bucket"
  value       = google_storage_bucket.main.name
}

output "bucket_url" {
  description = "URL of the GCS bucket"
  value       = google_storage_bucket.main.url
}

output "bucket_self_link" {
  description = "Self link of the GCS bucket"
  value       = google_storage_bucket.main.self_link
}
