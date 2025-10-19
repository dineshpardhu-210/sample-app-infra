#############################################
# IAM Module - variables.tf
#############################################

variable "name" {
  description = "Prefix name for IAM role and instance profile"
  type        = string
  default     = "jenkins"
}

variable "enable_ecr_access" {
  description = "Attach ECR read-only policy for Docker image pull access"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_logs" {
  description = "Attach CloudWatch logging policy for Jenkins monitoring"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}
