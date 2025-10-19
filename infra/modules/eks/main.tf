# ------------------------------------------------------------------
#  EKS Cluster
# ------------------------------------------------------------------
resource "aws_eks_cluster" "this" {
  name     = "${var.name_prefix}-eks"
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.private_subnets
  }

  depends_on = [var.cluster_role_arn]
}

# ------------------------------------------------------------------
#  Launch Template for Worker Nodes (with Squid Proxy)
# ------------------------------------------------------------------
data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["602401143452"] # Amazon EKS optimized AMIs
  filter {
    name   = "name"
    values = ["amazon-eks-node-*"]
  }
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix   = "${var.name_prefix}-lt"
  image_id      = data.aws_ami.eks_worker.id
  instance_type = var.eks_node_instance_type  # ✅ Controlled via variable

  # ✅ User data to configure proxy for Docker
  user_data = base64encode(templatefile("${path.module}/node_user_data.sh", {
    squid_ip = var.squid_private_ip
  }))

  credit_specification {
    cpu_credits = "unlimited"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name_prefix}-eks-node"
    }
  }
}

# ------------------------------------------------------------------
#  Managed Node Group using Launch Template
# ------------------------------------------------------------------
resource "aws_eks_node_group" "ng" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name_prefix}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  depends_on = [aws_launch_template.eks_nodes]
}

# ------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------
output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "node_group_name" {
  value = aws_eks_node_group.ng.node_group_name
}
