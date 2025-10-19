#############################################
# Jenkins Instance Module - variables.tf
#############################################

variable "name" {
  description = "Prefix name for Jenkins resources"
  type        = string
  default     = "jenkins"
}

variable "vpc_id" {
  description = "VPC ID where Jenkins will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Jenkins placement"
  type        = list(string)
}

variable "ami" {
  description = "AMI ID for Jenkins EC2 instance (Ubuntu recommended)"
  type        = string
}

variable "instance_type" {
  description = "Instance type for Jenkins EC2"
  type        = string
  default     = "t3.medium"
}

variable "alb_sg_ids" {
  description = "List of ALB security group IDs"
  type        = list(string)
  default     = []
}


variable "iam_instance_profile" {
  description = "IAM instance profile name from IAM module for SSM access"
  type        = string
}

variable "tags" {
  description = "Tags for Jenkins resources"
  type        = map(string)
  default     = {}
}
