resource "aws_eks_cluster" "this" {
  name     = "${var.name_prefix}-eks"
  role_arn = var.cluster_role_arn
  vpc_config {
    subnet_ids = var.private_subnets
  }
}

resource "aws_eks_node_group" "ng" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name_prefix}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnets
  instance_types  = [var.eks_node_instance_type]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}
