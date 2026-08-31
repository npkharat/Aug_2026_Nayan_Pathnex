# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}


# ============================================================
# AVAILABILITY ZONES
# ============================================================

data "aws_availability_zones" "available" {
  state = "available"
}


# ============================================================
# INTERNET GATEWAY
# ============================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}


# ============================================================
# PUBLIC SUBNET - AZ 1
# ============================================================

resource "aws_subnet" "public_1" {
  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.1.0/24"

  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-public-1"

    "kubernetes.io/role/elb" = "1"
  }
}


# ============================================================
# PUBLIC SUBNET - AZ 2
# ============================================================

resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.2.0/24"

  availability_zone = data.aws_availability_zones.available.names[1]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-public-2"

    "kubernetes.io/role/elb" = "1"
  }
}


# ============================================================
# PRIVATE SUBNET - AZ 1
# ============================================================

resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.11.0/24"

  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.cluster_name}-private-1"

    "kubernetes.io/role/internal-elb" = "1"
  }
}


# ============================================================
# PRIVATE SUBNET - AZ 2
# ============================================================

resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.12.0/24"

  availability_zone = data.aws_availability_zones.available.names[1]

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.cluster_name}-private-2"

    "kubernetes.io/role/internal-elb" = "1"
  }
}


# ============================================================
# PUBLIC ROUTE TABLE
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.cluster_name}-public-rt"
  }
}


# ============================================================
# PUBLIC ROUTE TABLE ASSOCIATION
# ============================================================

resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public_1.id

  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "public_2" {
  subnet_id = aws_subnet.public_2.id

  route_table_id = aws_route_table.public.id
}


# ============================================================
# ELASTIC IP FOR NAT
# ============================================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.cluster_name}-nat-eip"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}


# ============================================================
# SINGLE NAT GATEWAY
# ============================================================

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public_1.id

  tags = {
    Name = "${var.cluster_name}-nat"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}


# ============================================================
# PRIVATE ROUTE TABLE
# ============================================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.cluster_name}-private-rt"
  }
}


# ============================================================
# PRIVATE ROUTE TABLE ASSOCIATION
# ============================================================

resource "aws_route_table_association" "private_1" {
  subnet_id = aws_subnet.private_1.id

  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "private_2" {
  subnet_id = aws_subnet.private_2.id

  route_table_id = aws_route_table.private.id
}