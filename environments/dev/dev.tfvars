environment = "dev"

vpc_cidr             = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.0.0/22", "10.10.4.0/22", "10.10.8.0/22"]
private_subnet_cidrs = ["10.10.16.0/20", "10.10.32.0/20", "10.10.48.0/20"]

cost_center = "platform-dev"

rds_master_password = "ChangeMe-dev-only-not-real-password"

eks_admin_role_arn     = "arn:aws:iam::957424402576:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_4063ec7cb61557a0"
eks_cluster_version    = "1.31"
eks_node_instance_type = "t3.medium"
eks_node_desired_size  = 2
eks_node_min_size      = 1
eks_node_max_size      = 3
