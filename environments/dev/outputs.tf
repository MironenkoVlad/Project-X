output "vpc_id" {
  value = module.network.vpc_id
}

output "vpc_cidr_block" {
  value = module.network.vpc_cidr_block
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "public_subnet_1_id" {
  value = module.network.public_subnet_1_id
}

output "public_subnet_2_id" {
  value = module.network.public_subnet_2_id
}

output "public_subnet_3_id" {
  value = module.network.public_subnet_3_id
}

output "private_subnet_1_id" {
  value = module.network.private_subnet_1_id
}

output "private_subnet_2_id" {
  value = module.network.private_subnet_2_id
}

output "private_subnet_3_id" {
  value = module.network.private_subnet_3_id
}

output "alb_security_group_id" {
  value = module.network.alb_security_group_id
}

output "ecs_service_security_group_id" {
  value = module.network.ecs_service_security_group_id
}

output "rds_security_group_id" {
  value = module.network.rds_security_group_id
}

output "jenkins_security_group_id" {
  value = module.network.jenkins_security_group_id
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
