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

resource "aws_iam_policy" "gha_shipments_api" {
  name = "gha-routebox-shipments-api-dev"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "gha_shipments_api" {
  name = "gha-routebox-shipments-api-dev"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = module.oidc.provider_arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:MironenkoVlad/Project-X:ref:refs/heads/main"
        }
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "gha_shipments_api" {
  role       = aws_iam_role.gha_shipments_api.name
  policy_arn = aws_iam_policy.gha_shipments_api.arn
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

# ZDAPROVA ARTEM Epta123

#123123123

