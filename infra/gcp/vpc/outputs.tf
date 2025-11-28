output "network_id" {
  description = "ID of the VPC network"
  value       = module.vpc.network_id
}

output "network_name" {
  description = "Name of the VPC network"
  value       = module.vpc.network_name
}
