resource "aws_route_table" "main" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = var.name
      Type = var.route_table_type
    }
  )
}

resource "aws_route" "internet_gateway" {
  count                  = var.gateway_id != null ? 1 : 0
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.gateway_id
}

resource "aws_route" "nat_gateway" {
  count                  = var.nat_gateway_id != null ? 1 : 0
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_id
}

resource "aws_route_table_association" "main" {
  count          = length(var.subnet_ids)
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = aws_route_table.main.id
}
