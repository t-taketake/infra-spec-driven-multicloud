output "subnet_id" {
  description = "ID of the subnet"
  value       = aws_subnet.main.id
}

output "subnet_arn" {
  description = "ARN of the subnet"
  value       = aws_subnet.main.arn
}

output "subnet_cidr_block" {
  description = "CIDR block of the subnet"
  value       = aws_subnet.main.cidr_block
}
