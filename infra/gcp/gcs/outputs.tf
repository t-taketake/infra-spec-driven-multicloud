output "bucket_name" {
  description = "Name of the GCS bucket"
  value       = module.gcs.bucket_name
}

output "bucket_url" {
  description = "URL of the GCS bucket"
  value       = module.gcs.bucket_url
}
