module "vpc" {
  source = "./modules/vpc"
  name_prefix = var.name_prefix
  vpc_cidr    = var.vpc_cidr
  aws_region  =var.region
}

module "iam" {
  source      = "./modules/iam"
  name_prefix = var.name_prefix
}

module "jenkins_instance" {
  source                     = "./modules/jenkins_instance"
  name_prefix                 = var.name_prefix
  vpc_id                      = module.vpc.vpc_id
  vpc_cidr                    = var.vpc_cidr
  public_subnets              = module.vpc.public_subnets
  private_subnet_id           = module.vpc.private_subnets[0]
  public_subnet_id            = module.vpc.public_subnets[0]
  key_name                    = var.ssh_key_name
  jenkins_ssm_instance_profile_name = module.iam.jenkins_ssm_instance_profile_name
}

module "eks" {
  source                = "./modules/eks"
  name_prefix           = var.name_prefix
  private_subnets       = module.vpc.private_subnets
  cluster_role_arn      = module.iam.cluster_role_arn
  node_role_arn         = module.iam.node_role_arn
  eks_node_instance_type = "t3.small"
  squid_private_ip      = module.jenkins_instance.squid_private_ip   # Added
}
