# --------------------------------------------------------------------
#  Ubuntu AMI
# --------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# --------------------------------------------------------------------
#  Security Group for ALB
# --------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name   = "${var.name_prefix}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --------------------------------------------------------------------
#  Security Group for Jenkins (Private Subnet)
# --------------------------------------------------------------------
resource "aws_security_group" "jenkins" {
  name   = "${var.name_prefix}-jenkins-sg"
  vpc_id = var.vpc_id

  # ALB → Jenkins (UI)
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Jenkins → Squid (outbound HTTP/HTTPS)
  egress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # General egress (for internal VPC)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}

# --------------------------------------------------------------------
#  Security Group for Squid Proxy (Public Subnet)
# --------------------------------------------------------------------
resource "aws_security_group" "squid" {
  name        = "${var.name_prefix}-squid-sg"
  description = "Allow Jenkins and VPC instances to use proxy"
  vpc_id      = var.vpc_id

  # Allow inbound proxy requests from private subnets
  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow Squid → Internet (to fetch content)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --------------------------------------------------------------------
#  Squid Proxy Instance (Public Subnet)
# --------------------------------------------------------------------
resource "aws_instance" "squid" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.squid.id]
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y squid
    sed -i 's/^http_access deny all/http_access allow all/' /etc/squid/squid.conf
    systemctl enable squid
    systemctl restart squid
  EOF

  tags = {
    Name = "${var.name_prefix}-squid"
  }
}

# --------------------------------------------------------------------
#  Jenkins Instance (Private Subnet) with Proxy Config
# --------------------------------------------------------------------
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/user_data.sh", {
    squid_ip = aws_instance.squid.private_ip
  })

  tags = {
    Name = "${var.name_prefix}-jenkins"
  }
}

# --------------------------------------------------------------------
#  ALB for Jenkins UI
# --------------------------------------------------------------------
resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-jenkins-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.name_prefix}-jenkins-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "att" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.jenkins.id
  port             = 8080
}
