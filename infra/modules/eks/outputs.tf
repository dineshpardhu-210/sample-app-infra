output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_certificate" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}



output "node_role_arn" {
  description = "IAM role ARN for EKS node group"
  value       = aws_iam_role.node_role.arn
}

output "node_group_name" {
  description = "EKS node group name"
  value       = aws_eks_node_group.this.node_group_name
}
