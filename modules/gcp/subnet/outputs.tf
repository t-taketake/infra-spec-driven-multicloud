output "subnet_id" {
  description = "ID of the subnet"
  value       = google_compute_subnetwork.main.id
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.main.name
}

output "subnet_self_link" {
  description = "Self link of the subnet"
  value       = google_compute_subnetwork.main.self_link
}
