
# --------------------------------------------------------------------
# Outputs
# --------------------------------------------------------------------
output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "jenkins_ssm_instance_profile_name" {
  value = aws_iam_instance_profile.jenkins_ssm_profile.name
}
