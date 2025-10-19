variable "name_prefix" {
  description = "Prefix for EKS resources"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for EKS nodes"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM Role ARN for the EKS cluster"
  type        = string
}

variable "node_role_arn" {
  description = "IAM Role ARN for EKS worker nodes"
  type        = string
}

variable "eks_node_instance_type" {
  description = "Instance type for EKS worker nodes"
  type        = string
  default     = "t3.small" # ✅ You can override from root if needed
}

variable "squid_private_ip" {
  description = "Private IP of Squid proxy for DockerHub access"
  type        = string
}
