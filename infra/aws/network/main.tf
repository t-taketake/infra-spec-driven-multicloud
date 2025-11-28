terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
module "vpc" {
  source = "../../../modules/aws/vpc"

  name                 = "${var.environment}-${var.service}-vpc"
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.service}-vpc"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.service
    }
  )
}

# Public Subnets
module "public_subnet_a" {
  source = "../../../modules/aws/subnet"

  name                    = "${var.environment}-${var.service}-subnet-public-a"
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  subnet_type             = "public"

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.service}-subnet-public-a"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.service
      Type        = "public"
    }
  )
}

module "public_subnet_c" {
  source = "../../../modules/aws/subnet"

  name                    = "${var.environment}-${var.service}-subnet-public-c"
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.public_subnet_c_cidr
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = true
  subnet_type             = "public"

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.service}-subnet-public-c"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.service
      Type        = "public"
    }
  )
}

# Private Subnets
module "private_subnet_a" {
  source = "../../../modules/aws/subnet"

  name                    = "${var.environment}-${var.service}-subnet-private-a"
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.private_subnet_a_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false
  subnet_type             = "private"

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.service}-subnet-private-a"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.service
      Type        = "private"
    }
  )
}

module "private_subnet_c" {
  source = "../../../modules/aws/subnet"

  name                    = "${var.environment}-${var.service}-subnet-private-c"
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.private_subnet_c_cidr
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = false
  subnet_type             = "private"

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.service}-subnet-private-c"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.service
      Type        = "private"
    }
  )
}

# NAT Gateways
module "nat_gateway_a" {
  source = "../../../modules/aws/nat_gateway"

  name                = "${var.environment}-${var.service}-nat-a"
  subnet_id           = module.public_subnet_a.subnet_id
  internet_gateway_id = module.vpc.internet_gateway_id

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.service}-nat-a"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.service
    }
  )
}

module "nat_gateway_c" {
  source = "../../../modules/aws/nat_gateway"

  name                = "${var.environment}-${var.service}-nat-c"
  subnet_id           = module.public_subnet_c.subnet_id
  internet_gateway_id = module.vpc.internet_gateway_id

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.service}-nat-c"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.service
    }
  )
}

# Public Route Table
module "public_route_table" {
  source = "../../../modules/aws/route_table"

  vpc_id           = module.vpc.vpc_id
  name             = "${var.environment}-${var.service}-rtb-public"
  route_table_type = "public"
  gateway_id       = module.vpc.internet_gateway_id
  subnet_ids = [
    module.public_subnet_a.subnet_id,
    module.public_subnet_c.subnet_id
  ]

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.service}-rtb-public"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.service
      Type        = "public"
    }
  )
}

# Private Route Table for AZ-a
module "private_route_table_a" {
  source = "../../../modules/aws/route_table"

  vpc_id           = module.vpc.vpc_id
  name             = "${var.environment}-${var.service}-rtb-private-a"
  route_table_type = "private"
  nat_gateway_id   = module.nat_gateway_a.nat_gateway_id
  subnet_ids       = [module.private_subnet_a.subnet_id]

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.service}-rtb-private-a"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.service
      Type        = "private"
    }
  )
}

# Private Route Table for AZ-c
module "private_route_table_c" {
  source = "../../../modules/aws/route_table"

  vpc_id           = module.vpc.vpc_id
  name             = "${var.environment}-${var.service}-rtb-private-c"
  route_table_type = "private"
  nat_gateway_id   = module.nat_gateway_c.nat_gateway_id
  subnet_ids       = [module.private_subnet_c.subnet_id]

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.service}-rtb-private-c"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.service
      Type        = "private"
    }
  )
}
