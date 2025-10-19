#############################################
# Jenkins Instance Module - outputs.tf
#############################################

output "jenkins_instance_id" {
  description = "ID of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.id
}

output "jenkins_private_ip" {
  description = "Private IP address of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.private_ip
}

output "jenkins_sg_id" {
  description = "Security Group ID for Jenkins EC2 instance"
  value       = aws_security_group.jenkins_sg.id
}
