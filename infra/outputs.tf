output "vpc_id" {
  value = module.vpc.vpc_id
}

output "jenkins_instance_id" {
  value = module.jenkins.jenkins_instance_id
}

output "jenkins_private_ip" {
  value = module.jenkins.jenkins_private_ip
}

output "alb_dns" {
  value = module.alb.alb_dns_name
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
