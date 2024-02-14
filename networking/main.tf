variable "vpc_cidr" {}
variable "vpc_name" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
variable "subnet_availability_zone" {}

output "three_tier_vpc_id" {
  value = aws_vpc.three_tier_vpc.id
}

output "private_subnet_id" {
  value = aws_subnet.three_tier_private_subnet.*.id 
}

output "public_subnet_id" {
  value = aws_subnet.three_tier_public_subnet.*.id 
}

//vpc setup
resource "aws_vpc" "three_tier_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}
//public subnet
resource "aws_subnet" "three_tier_public_subnet" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = element(var.public_subnet_cidr, count.index)
  availability_zone       = element(var.subnet_availability_zone, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}
//private subnet
resource "aws_subnet" "three_tier_private_subnet" {
  count                   = length(var.private_subnet_cidr)
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = element(var.private_subnet_cidr, count.index)
  availability_zone       = element(var.subnet_availability_zone, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}


//internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.three_tier_vpc.id
  tags = {
    Name = "three_tier_igw"
  }
}

//public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route" "public_igw_route" {
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "private_igw_route" {
  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.natgw.id
}

//subnet association
resource "aws_route_table_association" "public_rt_association" {
  count          = length(aws_subnet.three_tier_public_subnet)
  subnet_id      = aws_subnet.three_tier_public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

//EIP
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

//NAT gateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.three_tier_public_subnet.*.id, 0)

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.igw, aws_eip.nat_eip]
}

//private route table
resource "aws_route_table" "private_route_table" {
  vpc_id     = aws_vpc.three_tier_vpc.id
  depends_on = [aws_nat_gateway.natgw]
  tags = {
    Name = "private-route-table"
  }
}

//private route table association

resource "aws_route_table_association" "private_rt_association" {
  count          = length(aws_subnet.three_tier_private_subnet)
  subnet_id      = aws_subnet.three_tier_private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}