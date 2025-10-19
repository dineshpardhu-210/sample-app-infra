#############################################
# IAM Module - outputs.tf
#############################################

output "jenkins_role_name" {
  description = "IAM Role name for Jenkins"
  value       = aws_iam_role.jenkins_role.name
}

output "jenkins_role_arn" {
  description = "IAM Role ARN for Jenkins"
  value       = aws_iam_role.jenkins_role.arn
}

output "jenkins_instance_profile_name" {
  description = "Instance profile name to attach to Jenkins EC2"
  value       = aws_iam_instance_profile.jenkins_profile.name
}
