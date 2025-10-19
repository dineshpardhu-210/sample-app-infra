variable "name" {
  description = "EKS cluster name"
  type        = string
  default     = "jenkins-eks"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for node group"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for EKS cluster networking"
}

variable "tags" {
  type        = map(string)
  description = "Tags for EKS resources"
  default     = {}
}

variable "node_instance_types" {
  description = "List of instance types for node group"
  type        = list(string)
}

variable "node_desired_size" {
  description = "Desired node count for the EKS node group"
  type        = number
}
