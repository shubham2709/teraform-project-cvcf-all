resource "aws_vpc" "vpc1" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "vpc-stage"
  }
}
#publicsublic
resource "aws_subnet" "publicsubnet" {
  #count                   = length(var.az)
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "public1"
  }
}
#privatesubnet
resource "aws_subnet" "privatesubnet" {
  #count      = length(var.az)
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.2.0/24"
  # map_public_ip_on_launch = "true"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "private1"
  }
}
#datasubnet
resource "aws_subnet" "datasubnet" {
  #count      = length(var.az)
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.3.0/24"
  # map_public_ip_on_launch = "true"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "data1"
  }
}

#internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "stage-igw"
  }
}


#nat-gateway elastic ip
resource "aws_eip" "eip" {
  vpc = true

  tags = {
    "nmae" = "eip-stage"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.publicsubnet.id

  tags = {
    Name = "gw NAT"
  }
}


#publiroute
resource "aws_route_table" "publicroute" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "publicroute"
  }

}
#privateroute
resource "aws_route_table" "privateroute" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name = "privateroute"
  }
}
#dataroute
resource "aws_route_table" "dataroute" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name = "dataroute"
  }
}

#public-association
resource "aws_route_table_association" "public-association" {
  #count          = length(var.publicsubnet)
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.publicroute.id
}
#private-association
resource "aws_route_table_association" "private-association" {
  #count          = length(var.privatesubnet)
  subnet_id      = aws_subnet.privatesubnet.id
  route_table_id = aws_route_table.privateroute.id
}
#data-association
resource "aws_route_table_association" "data-association" {
  #count          = length(var.datasubnet)
  subnet_id      = aws_subnet.datasubnet.id
  route_table_id = aws_route_table.dataroute.id
}