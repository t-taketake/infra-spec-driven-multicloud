terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "ecr" {
  source = "../../../modules/aws/ecr"

  name = var.repository_name

  tags = var.tags
}
