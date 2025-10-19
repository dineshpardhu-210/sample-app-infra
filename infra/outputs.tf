output "vpc_id"           { value = module.vpc.vpc_id }
output "eks_cluster_name" { value = module.eks.cluster_name }
output "jenkins_alb_dns"  { value = module.jenkins_instance.alb_dns }
