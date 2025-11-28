terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "vpc" {
  source = "../../../modules/aws/vpc"

  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block

  tags = var.tags
}
