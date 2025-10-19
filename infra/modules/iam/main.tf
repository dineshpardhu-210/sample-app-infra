# --------------------------------------------------------------------
#  IAM Role for EKS Cluster
# --------------------------------------------------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.name_prefix}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ])
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = each.value
}

# --------------------------------------------------------------------
#  IAM Role for EKS Worker Nodes
# --------------------------------------------------------------------
resource "aws_iam_role" "eks_node_role" {
  name = "${var.name_prefix}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "eks_node_profile" {
  name = "${var.name_prefix}-eks-node-profile"
  role = aws_iam_role.eks_node_role.name
}

# --------------------------------------------------------------------
#  IAM Role for Jenkins EC2 (SSM Access)
# --------------------------------------------------------------------
resource "aws_iam_role" "jenkins_ssm_role" {
  name = "${var.name_prefix}-jenkins-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core_attach" {
  role       = aws_iam_role.jenkins_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jenkins_ssm_profile" {
  name = "${var.name_prefix}-jenkins-ssm-profile"
  role = aws_iam_role.jenkins_ssm_role.name
}
