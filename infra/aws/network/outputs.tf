output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = [
    module.public_subnet_a.subnet_id,
    module.public_subnet_c.subnet_id
  ]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value = [
    module.private_subnet_a.subnet_id,
    module.private_subnet_c.subnet_id
  ]
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value = [
    module.nat_gateway_a.nat_gateway_id,
    module.nat_gateway_c.nat_gateway_id
  ]
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = module.public_route_table.route_table_id
}

output "private_route_table_ids" {
  description = "Private route table IDs"
  value = [
    module.private_route_table_a.route_table_id,
    module.private_route_table_c.route_table_id
  ]
}
