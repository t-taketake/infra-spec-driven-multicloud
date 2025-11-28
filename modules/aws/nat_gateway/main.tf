resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-eip"
    }
  )

  depends_on = [var.internet_gateway_id]
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.subnet_id

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  depends_on = [var.internet_gateway_id]
}
