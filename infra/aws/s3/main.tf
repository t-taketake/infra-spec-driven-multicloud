terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "s3" {
  source = "../../../modules/aws/s3"

  bucket_name = var.bucket_name

  tags = var.tags
}
