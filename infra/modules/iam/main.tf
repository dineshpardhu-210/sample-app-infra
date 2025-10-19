#############################################
# IAM Module - main.tf
# Purpose: Create IAM Role + Instance Profile
# for Jenkins EC2 instance with SSM access
#############################################

resource "aws_iam_role" "jenkins_role" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = "${var.name}-role" })
}

# Attach core policy for SSM Session Manager
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Optional: Attach ECR pull policy if Jenkins needs to interact with ECR
resource "aws_iam_role_policy_attachment" "ecr" {
  count      = var.enable_ecr_access ? 1 : 0
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Optional: Allow Jenkins to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "cw" {
  count      = var.enable_cloudwatch_logs ? 1 : 0
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Create an instance profile for EC2
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.jenkins_role.name

  tags = merge(var.tags, { Name = "${var.name}-instance-profile" })
}
