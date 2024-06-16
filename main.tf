# Creating vpc 
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
      Name = local.name
    }
    )

  
}
# creating intenet gateway and attach to vpc
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
      Name = local.name
    }
    )
}

# Creating public subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidr) # when we use count fn then it will become list of subnets
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets_cidr[count.index] # taking from condition in var file
  availability_zone = local.az_names[count.index]
  tags = merge(
    var.common_tags,
    var.public_subnets_tags,
    {
      Name = "${local.name}-public-${local.az_names[count.index]}"
    }
    )
}
# Creating private subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnets_cidr[count.index] # taking from condition in var file
  availability_zone = local.az_names[count.index]
  tags = merge(
    var.common_tags,
    var.private_subnets_tags,
    {
      Name = "${local.name}-private-${local.az_names[count.index]}"
    }
    )
}
# Creating database subnet
resource "aws_subnet" "database" {
  count = length(var.database_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnets_cidr[count.index] # taking from condition in var file
  availability_zone = local.az_names[count.index]
  tags = merge(
    var.common_tags,
    var.database_subnets_tags,
    {
      Name = "${local.name}-database-${local.az_names[count.index]}"
    }
    )
}
# Creating databse subnet group
resource "aws_db_subnet_group" "default" {
  name       = "${local.name}"
  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name = "${local.name}"
  }
}

# Creating elastic IP terraform

resource "aws_eip" "eip" {
  domain           = "vpc"
}

# Creating NAT gateway

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id # 0 is 1a taking from list
  tags = merge(
    var.common_tags,
    var.nat_gateway_tags,
    {
      Name = "${local.name}"
    }
  )
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]  # NAT gateway works only if igw is present and connected to public
}

# Creating Route table for public

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
      Name = "${local.name}-public"
    }
  )
}

# Creating Route table for private

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.private_route_table_tags,
    {
      Name = "${local.name}-private"
    }
  )
}
# Creating Route table for database

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.database_route_table_tags,
    {
      Name = "${local.name}-database"
    }
  )
}
# Creating route for public using public route table, It will be connect to internet gateway
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

# Creating route for private using private route table, It will be connect to NAT gateway
resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id  = aws_nat_gateway.main.id
}

# Creating route for database using database route table, It will be connect to NAT gateway
resource "aws_route" "database_route" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id  = aws_nat_gateway.main.id
}
# route table association with subnet, using loop function need to create 2 subnets (1a & 1b)
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public[*].id, count.index) # element function, 
  # list is aws.subnet.public[*].id = which give both id's in a form of list, 
  route_table_id = aws_route_table.public.id
}

# route table association with subnet, using loop function need to create 2 subnets (1a & 1b)
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private[*].id, count.index) # element function, 
  # list is aws.subnet.public[*].id = which give both id's in a form of list, 
  route_table_id = aws_route_table.private.id
}

# route table association with subnet, using loop function need to create 2 subnets (1a & 1b)
resource "aws_route_table_association" "database" {
  count = length(var.database_subnets_cidr)
  subnet_id      = element(aws_subnet.database[*].id, count.index) # element function, 
  # list is aws.subnet.public[*].id = which give both id's in a form of list, 
  route_table_id = aws_route_table.database.id
}