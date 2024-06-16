resource "aws_vpc_peering_connection" "peering" {
    count = var.is_peering_required ? 1: 0 # if var is true then 1 else 0
    vpc_id = aws_vpc.main.id # requestor vpc id
    peer_vpc_id = var.acceptor_vpc_id == "" ? data.aws_vpc.default.id: var.acceptor_vpc_id  # if we dont have accceptor vpc id then we need to connect to default vpc, we will get deafult vpc using data sources
    auto_accept = var.acceptor_vpc_id == "" ? true : false

    tags = merge(
        var.common_tags,
        var.vpc_peering_tags,
        {
            Name = "${local.name}"
        }
    )
} 

# After peering established, need to connect the routes

resource "aws_route" "accceptor_route" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = var.vpc_cidr # roboshop CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id 
}

# similarly, need to do it for public
resource "aws_route" "public_peering" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

# similarly, need to do it for private
resource "aws_route" "private_peering" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

# similarly, need to do it for database
resource "aws_route" "database_peering" {
  count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}