#############################################
# Jenkins Instance Module - main.tf
# Purpose: Deploy Jenkins EC2 in private subnet,
# with SSM access (via IAM profile from IAM module),
# and internet access via NAT instance.
#############################################

resource "aws_security_group" "jenkins_sg" {
  name        = "${var.name}-sg"
  description = "Security group for Jenkins instance"
  vpc_id      = var.vpc_id

  # ALB -> Jenkins (HTTP)
  ingress {
    description     = "Allow ALB access"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = var.alb_sg_ids
  }

  # Outbound access to NAT / internet / SSM
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-sg" })
}

resource "aws_instance" "jenkins" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = element(var.private_subnet_ids, 0)
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = false
  iam_instance_profile        = var.iam_instance_profile
  # user_data                   = file("${path.module}/user-data.sh")

  tags = merge(var.tags, {
    Name = "${var.name}-jenkins-instance"
  })
}
