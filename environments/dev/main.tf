provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      CostCenter  = var.cost_center
    }
  }
}

module "network" {
  source = "../../network"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  cost_center          = var.cost_center
}

module "oidc" {
  source = "../../modules/oidc"

  github_org = "MironenkoVlad"

  roles = {
    "gha-routebox-infra-tf-dev" = {
      repo        = "Project-X"
      branch      = "main"
      policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
  }
}

module "rds" {
  source = "../../modules/rds"

  environment            = var.environment
  private_subnet_ids     = module.network.private_subnet_ids
  rds_security_group_id  = module.network.rds_security_group_id
  db_instance_class      = var.rds_instance_class
  db_allocated_storage   = var.rds_allocated_storage
  db_master_password     = var.rds_master_password
  backup_retention_days  = var.rds_backup_retention_days
  skip_final_snapshot    = true
}

module "ecr" {
  source = "../../modules/ecr"

  environment = var.environment
  services = [
    "ops-console",
    "route-optimizer",
    "tracking-events",
  ]
}

module "eks" {
  source = "../../modules/eks"

  environment        = var.environment
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  admin_role_arn     = var.eks_admin_role_arn
  cluster_version    = var.eks_cluster_version
  node_instance_type = var.eks_node_instance_type
  node_desired_size  = var.eks_node_desired_size
  node_min_size      = var.eks_node_min_size
  node_max_size      = var.eks_node_max_size
}
