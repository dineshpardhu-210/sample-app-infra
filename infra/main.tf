module "vpc" {
  source       = "./modules/vpc"
  name_prefix  = var.name_prefix
  vpc_cidr     = var.vpc_cidr
}

module "iam" {
  source       = "./modules/iam"
  name_prefix  = var.name_prefix
}

module "eks" {
  source                 = "./modules/eks"
  name_prefix            = var.name_prefix
  vpc_id                 = module.vpc.vpc_id
  private_subnets        = module.vpc.private_subnets
  cluster_role_arn       = module.iam.cluster_role_arn
  node_role_arn          = module.iam.node_role_arn
  eks_node_instance_type = "t3.medium"
}

module "jenkins_instance" {
  source            = "./modules/jenkins_instance"
  name_prefix       = var.name_prefix
  vpc_id            = module.vpc.vpc_id
  private_subnet_id = element(module.vpc.private_subnets, 0)
  public_subnet_id  = element(module.vpc.public_subnets, 0)
  public_subnets    = module.vpc.public_subnets
  key_name          = var.ssh_key_name
}
