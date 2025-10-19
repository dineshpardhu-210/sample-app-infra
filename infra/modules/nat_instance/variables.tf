variable "name" {
  description = "Prefix name for NAT resources"
  type        = string
}

variable "ami" {
  description = "AMI ID for NAT instance (Amazon Linux 2 recommended)"
  type        = string
}

variable "instance_type" {
  description = "NAT instance type"
  type        = string
  default     = "t3.micro"
}

variable "public_subnet_id" {
  description = "Subnet ID for NAT instance (must be public)"
  type        = string
}

variable "private_route_table_ids" {
  description = "List of private route table IDs to route through NAT"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Optional security groups for NAT instance"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
