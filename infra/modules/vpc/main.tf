#############################################
# VPC Module - main.tf
# Purpose: Create VPC, Subnets, Route Tables,
# Internet Gateway, and VPC Endpoints.
#############################################

# -----------------------------
# VPC
# -----------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = var.vpc_name })
}

# -----------------------------
# Internet Gateway
# -----------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.vpc_name}-igw" })
}

# -----------------------------
# Public Subnets
# -----------------------------
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, index(var.public_subnet_cidrs, each.value))
  tags = merge(var.tags, { Name = "${var.vpc_name}-public-${each.key}" })
}

# -----------------------------
# Private Subnets
# -----------------------------
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  map_public_ip_on_launch = false
  availability_zone       = element(var.availability_zones, index(var.private_subnet_cidrs, each.value))
  tags = merge(var.tags, { Name = "${var.vpc_name}-private-${each.key}" })
}

# -----------------------------
# Route Tables
# -----------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, { Name = "${var.vpc_name}-public-rt" })
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.this.id
  tags     = merge(var.tags, { Name = "${var.vpc_name}-private-rt-${each.key}" })
}

# -----------------------------
# VPC Interface Endpoints (PrivateLink)
# For AWS services required by Jenkins + EKS
# -----------------------------
locals {
  interface_endpoints = {
    ecr_api         = "com.amazonaws.${var.region}.ecr.api"
    ecr_dkr         = "com.amazonaws.${var.region}.ecr.dkr"
    ssm             = "com.amazonaws.${var.region}.ssm"
    ssmmessages     = "com.amazonaws.${var.region}.ssmmessages"
    ec2messages     = "com.amazonaws.${var.region}.ec2messages"
    sts             = "com.amazonaws.${var.region}.sts"
    ec2             = "com.amazonaws.${var.region}.ec2"
    logs            = "com.amazonaws.${var.region}.logs"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each            = local.interface_endpoints
  vpc_id              = aws_vpc.this.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.private : s.id]
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.vpc_name}-${each.key}-endpoint" })
}

# -----------------------------
# Security Group for Interface Endpoints
# -----------------------------
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "${var.vpc_name}-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.this.id

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

  tags = merge(var.tags, { Name = "${var.vpc_name}-endpoint-sg" })
}
