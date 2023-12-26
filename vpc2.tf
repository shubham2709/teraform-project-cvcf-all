resource "aws_vpc" "vpc2" {
  cidr_block           = "192.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"



  tags = {
    Name = "vpc2"
  }
}
#publicsublic
resource "aws_subnet" "publicsubnetvpc2" {
  #count                   = length(var.az)
  vpc_id                  = aws_vpc.vpc2.id
  cidr_block              = "192.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-northeast-1a"



  tags = {
    Name                              = "publicvpc2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/ed-eks-01" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
}
#privatesubnet
resource "aws_subnet" "privatesubnetvpc2" {
  #count      = length(var.az)
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = "192.0.2.0/24"
  # map_public_ip_on_launch = "true"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name                              = "privatevpc2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/ed-eks-01" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
}
#datasubnet
resource "aws_subnet" "datasubnetvpc2" {
  #count      = length(var.az)
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = "192.0.3.0/24"
  # map_public_ip_on_launch = "true"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name                              = "datavpc2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/ed-eks-01" = "shared"
    "kubernetes.io/role/elb"          = "1"
  }
}



#internet gateway
resource "aws_internet_gateway" "igwvpc2" {
  vpc_id = aws_vpc.vpc2.id



  tags = {
    Name = "vpc2igw"
  }
}




#nat-gateway elastic ip
resource "aws_eip" "eipvpc2" {
  vpc = true



  tags = {
    "Name" = "eipvpc2"
  }
}



resource "aws_nat_gateway" "nat-gwvpc2" {
  allocation_id = aws_eip.eipvpc2.id
  subnet_id     = aws_subnet.publicsubnetvpc2.id



  tags = {
    Name = "igwNATvpc2"
  }
}




#publiroute
resource "aws_route_table" "publicroutevpc2" {
  vpc_id = aws_vpc.vpc2.id



  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igwvpc2.id
  }
  tags = {
    Name = "publicroutevpc2"
  }



}
#privateroute
resource "aws_route_table" "privateroutevpc2" {
  vpc_id = aws_vpc.vpc2.id



  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gwvpc2.id
  }
  tags = {
    Name = "privateroutevpc2"
  }
}
#dataroute
resource "aws_route_table" "dataroutevpc2" {
  vpc_id = aws_vpc.vpc2.id



  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gwvpc2.id
  }
  tags = {
    Name = "dataroutevpc2"
  }
}



#public-association
resource "aws_route_table_association" "public-associationvpc2" {
  #count          = length(var.publicsubnet)
  subnet_id      = aws_subnet.publicsubnetvpc2.id
  route_table_id = aws_route_table.publicroutevpc2.id
}
#private-association
resource "aws_route_table_association" "private-association2" {
  #count          = length(var.privatesubnet)
  subnet_id      = aws_subnet.privatesubnetvpc2.id
  route_table_id = aws_route_table.privateroutevpc2.id
}
#data-association
resource "aws_route_table_association" "data-association2" {
  #count          = length(var.datasubnet)
  subnet_id      = aws_subnet.datasubnetvpc2.id
  route_table_id = aws_route_table.dataroutevpc2.id
}