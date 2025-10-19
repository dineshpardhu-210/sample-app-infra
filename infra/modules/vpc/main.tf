# -------------------
# Data Sources
# -------------------
data "aws_availability_zones" "azs" {}

# -------------------
# VPC
# -------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# -------------------
# Public Subnets
# -------------------
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(data.aws_availability_zones.azs.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                              = "${var.name_prefix}-public-${count.index}"
    "kubernetes.io/role/elb"          = "1"
    "kubernetes.io/cluster/${var.name_prefix}-eks" = "shared"
  }
}

# -------------------
# Private Subnets
# -------------------
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)

  tags = {
    Name                              = "${var.name_prefix}-private-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.name_prefix}-eks" = "shared"
  }
}

# -------------------
# Internet Gateway & Public Route Table
# -------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.name_prefix}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.name_prefix}-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -------------------
# Security Group for VPC Endpoints
# -------------------
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.name_prefix}-vpc-endpoints-sg"
  vpc_id      = aws_vpc.this.id
  description = "Allow HTTPS for VPC endpoints"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------
# Interface Endpoints (EKS, EC2, STS, Logs)
# -------------------
locals {
  interface_services = [
    "com.amazonaws.${var.aws_region}.eks",
    "com.amazonaws.${var.aws_region}.ec2",
    "com.amazonaws.${var.aws_region}.sts",
    "com.amazonaws.${var.aws_region}.logs"
  ]
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = toset(local.interface_services)
  vpc_id              = aws_vpc.this.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.name_prefix}-endpoint-${replace(each.value, "com.amazonaws.${var.aws_region}.", "")}"
  }
}

# -------------------
# Gateway Endpoints (S3, DynamoDB)
# -------------------
resource "aws_vpc_endpoint" "gateway_endpoints" {
  for_each = toset(["s3", "dynamodb"])

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public.id]

  tags = {
    Name = "${var.name_prefix}-endpoint-${each.key}"
  }
}
