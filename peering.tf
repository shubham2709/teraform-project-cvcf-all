# Create a VPC peering connection from VPC A to VPC B
resource "aws_vpc_peering_connection" "peering_12" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true
}

# Create a VPC peering connection from VPC B to VPC A
resource "aws_vpc_peering_connection" "peering_21" {
  vpc_id      = aws_vpc.vpc2.id
  peer_vpc_id = aws_vpc.vpc1.id
  # auto_accept = true
}

# Create a route in VPC A's route table to VPC B
resource "aws_route" "route_to_2" {
  route_table_id            = aws_vpc.vpc1.main_route_table_id
  destination_cidr_block    = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_12.id
}

# Create a route in VPC B's route table to VPC A
resource "aws_route" "route_to_1" {
  route_table_id            = aws_vpc.vpc2.main_route_table_id
  destination_cidr_block    = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_21.id
}