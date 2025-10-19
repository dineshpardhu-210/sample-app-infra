variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Optional AWS CLI profile"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "VPC name/prefix"
  type        = string
  default     = "sample-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "AZs list"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = { Project = "jenkins-eks" }
}

# NAT
variable "nat_ami" {
  description = "AMI for NAT instance (Amazon Linux or appropriate NAT AMI)"
  type        = string
  default     = ""
}

variable "nat_public_key_path" {
  description = "Path to public SSH key for NAT (used to create key pair)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# Jenkins
variable "jenkins_ami" {
  description = "AMI for Jenkins EC2 (Ubuntu recommended)"
  type        = string
  default     = ""
}

variable "jenkins_instance_type" {
  description = "Jenkins EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ssh_allowed_cidrs" {
  description = "Optional CIDRs allowed SSH (if used). Not required for SSM."
  type        = list(string)
  default     = []
}

# EKS
variable "eks_node_instance_types" {
  description = "EKS node instance types (single type will be used)"
  type        = list(string)
  default     = ["t3.small"]
}

variable "eks_node_desired" {
  description = "Desired EKS node count"
  type        = number
  default     = 2
}

# Backend (if provisioning via module.backend)
variable "backend_bucket_name" {
  description = "S3 bucket name for Terraform state backend (if creating via module)"
  type        = string
  default     = ""
}

variable "backend_dynamodb_table" {
  description = "DynamoDB table name for Terraform locks (if creating via module)"
  type        = string
  default     = ""
}
