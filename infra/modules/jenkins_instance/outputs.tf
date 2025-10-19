# --------------------------------------------------------------------
# Outputs
# --------------------------------------------------------------------
output "jenkins_alb_dns" {
  value = aws_lb.alb.dns_name
}

output "squid_private_ip" {
  value = aws_instance.squid.private_ip
}
