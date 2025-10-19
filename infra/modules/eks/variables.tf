variable "name_prefix" {
  description = "Prefix for all EKS resources"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs for EKS"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM role ARN for EKS cluster"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for EKS node group"
  type        = string
}

variable "squid_private_ip" {
  description = "Private IP of Squid proxy in public subnet"
  type        = string
}
