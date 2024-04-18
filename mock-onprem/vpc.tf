# Define a vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.200.0.0/16"
  tags = {
    Name = "${var.prefix}"
  }
}

# Routing table for public subnets
resource "aws_route_table" "public_subnet_routes" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "Public subnet routing table"
  }
}

# Internet gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "Public gateway"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.200.0.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "Public subnet A"
  }
}

# resource "aws_ssm_parameter" "subnet_a" {
#   name = "/${var.prefix}/base/subnet/a/id"
#   value = "${aws_subnet.public_subnet_a.id}"
#   type  = "String"
# }

# Here, you can add more subnets in other availability zones

# Associate the routing table to public subnet A
resource "aws_route_table_association" "public_subnet_routes_assn_a" {
  subnet_id = "${aws_subnet.public_subnet_a.id}"
  route_table_id = "${aws_route_table.public_subnet_routes.id}"
}


