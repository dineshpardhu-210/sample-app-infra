variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_id" {
  description = "Private subnet ID for Jenkins"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for Squid proxy"
  type        = string
}

variable "key_name" {
  description = "SSH key name for EC2 instances"
  type        = string
}

variable "jenkins_ssm_instance_profile_name" {
  description = "IAM instance profile name with SSM permissions"
  type        = string
}
    