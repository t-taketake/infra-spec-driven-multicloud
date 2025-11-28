output "nat_id" {
  description = "ID of the Cloud NAT"
  value       = google_compute_router_nat.main.id
}

output "nat_name" {
  description = "Name of the Cloud NAT"
  value       = google_compute_router_nat.main.name
}
