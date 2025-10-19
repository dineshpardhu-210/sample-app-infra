################################################
# Root wiring - main.tf
# Modules: vpc -> nat-instance -> iam -> jenkins -> alb -> eks
################################################

# 1) VPC
module "vpc" {
  source               = "./modules/vpc"
  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  region               = var.aws_region
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  tags                 = var.tags
}

# 2) NAT instance (depends on VPC)
module "nat" {
  source                  = "./modules/nat_instance"
  name                    = "jenkins-nat"
  ami                     = var.nat_ami
  instance_type           = "t3.micro"
  public_subnet_id        = module.vpc.public_subnet_ids[0]
  private_route_table_ids = module.vpc.private_route_table_ids
  tags                    = var.tags
}


# 3) IAM module (creates instance profile for Jenkins)
module "iam" {
  source                 = "./modules/iam"
  name                   = "jenkins"
  enable_ecr_access      = true
  enable_cloudwatch_logs = false
  tags                   = var.tags
}

# 4) Jenkins EC2
module "jenkins" {
  source               = "./modules/jenkins_instance"
  name                 = "jenkins"
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  ami                  = var.jenkins_ami
  instance_type        = var.jenkins_instance_type
  alb_sg_ids           = [module.alb.alb_sg_id]
  iam_instance_profile = module.iam.jenkins_instance_profile_name
  tags                 = var.tags

  # ensure vpc and iam are created first
  depends_on = [module.vpc, module.iam, module.nat]
}

# NOTE: we need ALB to have security group id available. Because ALB module creates its own SG,
# we'll create ALB after Jenkins and then update Jenkins security group ingress to allow ALB SG (or pass ALB SG into Jenkins).
# For simplicity we'll create ALB next and then create a security-group rule to allow ALB->Jenkins.

# 5) ALB
module "alb" {
  source            = "./modules/alb"
  name              = "sample-alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  tags              = var.tags
}


# create a security group ingress rule to allow ALB SG to reach Jenkins SG
resource "aws_security_group_rule" "allow_alb_to_jenkins" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.jenkins.jenkins_sg_id
  source_security_group_id = module.alb.alb_sg_id
  description              = "Allow traffic from ALB to Jenkins"
}

# 6) EKS
module "eks" {
  source              = "./modules/eks"
  name                = "jenkins-eks"
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  node_instance_types = var.eks_node_instance_types
  node_desired_size   = var.eks_node_desired
  tags                = var.tags

  depends_on = [module.vpc, module.nat, module.iam]
}

resource "aws_lb_target_group_attachment" "jenkins_attachment" {
  target_group_arn = module.alb.alb_target_group_arn
  target_id        = module.jenkins.jenkins_instance_id
  port             = 8080
}

