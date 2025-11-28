resource "aws_ecr_repository" "main" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.kms_key_arn
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "main" {
  count      = var.lifecycle_policy != null ? 1 : 0
  repository = aws_ecr_repository.main.name

  policy = var.lifecycle_policy
}

resource "aws_ecr_repository_policy" "main" {
  count      = var.repository_policy != null ? 1 : 0
  repository = aws_ecr_repository.main.name
  policy     = var.repository_policy
}
