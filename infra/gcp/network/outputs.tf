output "network_id" {
  description = "VPC network ID"
  value       = module.vpc.network_id
}

output "network_name" {
  description = "VPC network name"
  value       = module.vpc.network_name
}

output "subnet_ids" {
  description = "Subnet IDs"
  value = [
    module.subnet_a.subnet_id,
    module.subnet_b.subnet_id
  ]
}

output "subnet_names" {
  description = "Subnet names"
  value = [
    module.subnet_a.subnet_name,
    module.subnet_b.subnet_name
  ]
}

output "cloud_router_id" {
  description = "Cloud Router ID"
  value       = module.cloud_router.router_id
}

output "cloud_nat_id" {
  description = "Cloud NAT ID"
  value       = module.cloud_nat.nat_id
}
