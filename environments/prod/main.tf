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

module "oidc" {
  source = "../../modules/oidc"

  github_org = "MironenkoVlad"

  roles = {
    "gha-routebox-infra-tf-prod" = {
      repo        = "Project-X"
      branch      = "main"
      policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
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
