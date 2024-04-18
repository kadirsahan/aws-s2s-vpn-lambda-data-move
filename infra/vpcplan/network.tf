# Creating  Private Subnet
resource "aws_subnet" "private_subnet_a" {
  vpc_id = "${aws_vpc.clvrtp-test.id}"
  cidr_block = "10.100.0.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "Private subnet A"
  }
}

# Creating Route table for Private Subnet
resource "aws_route_table" "rt_private" {
    vpc_id = aws_vpc.clvrtp-test.id
    route {
    cidr_block = "10.200.0.0/16"
    gateway_id = "${aws_vpn_gateway.vpngw.id}"
  }
tags = {
        Name = "Route Table for the Private Subnet"
    }
}
resource "aws_route_table_association" "rt_associate_private_2" {
    subnet_id = aws_subnet.private_subnet_a.id
    route_table_id = aws_route_table.rt_private.id
}



#This IP address will be the public IP of the router/firewall on-premise
resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65000
  ip_address = "35.153.138.148" # this up should be replaced by public ip of the sftpserver
  type       = "ipsec.1"

  tags = {
    Name = "On-Premise Customer Gateway"
  }
}


#Virtual Private Gateway creation and attachment to AWS VPC; Route propagation enabled
resource "aws_vpn_gateway" "vpngw" {
  vpc_id = aws_vpc.clvrtp-test.id

  tags = {
    Name = "AWS VGW"
  }
}

resource "aws_vpn_gateway_attachment" "vpngw_attachment" {
  vpc_id         = aws_vpc.clvrtp-test.id
  vpn_gateway_id = aws_vpn_gateway.vpngw.id
}

#Creation of site to site VPN in AWS using the AWS Virtual Private Gateway, the Customer Gateway of the on-premise router/firewall, and a predefined pre-shared key for the tunnel
resource "aws_vpn_connection" "vpn" {
  vpn_gateway_id      = aws_vpn_gateway.vpngw.id
  customer_gateway_id = aws_customer_gateway.cgw.id
  type                = "ipsec.1"
  static_routes_only  = true
  tunnel1_preshared_key = "abc123xyz987"
  tunnel2_preshared_key = "abc123xyz987"
  local_ipv4_network_cidr  = "10.200.0.0/16"
  remote_ipv4_network_cidr = "10.100.0.0/16"
}

resource "aws_vpn_connection_route" "office" {
  destination_cidr_block = "10.200.0.0/16"
  vpn_connection_id      = aws_vpn_connection.vpn.id
}

#######change

# Subnets
# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.clvrtp-test.id
  tags = {
    Name        = "igw"
  }
}



# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

# NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)

  tags = {
    Name        = "nat"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.clvrtp-test.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet"
  }
}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.clvrtp-test.id

  tags = {
    Name        = "public-route-table"
  }
}


# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.rt_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet_a.*.id, count.index)
  route_table_id = aws_route_table.rt_private.id
}


