output "router_id" {
  description = "ID of the Cloud Router"
  value       = google_compute_router.main.id
}

output "router_name" {
  description = "Name of the Cloud Router"
  value       = google_compute_router.main.name
}
