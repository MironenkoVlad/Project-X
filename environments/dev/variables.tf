variable "environment" {
  type        = string
  description = "Environment name passed through to the network module."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of 3 public subnet CIDRs."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of 3 private subnet CIDRs."
}

variable "cost_center" {
  type        = string
  description = "Cost-allocation tag value."
  default     = "platform"
}

variable "eks_admin_role_arn" {
  type        = string
  description = "IAM role ARN granted cluster-admin access via EKS access entry."
}

variable "eks_cluster_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster."
  default     = "1.31"
}

variable "eks_node_instance_type" {
  type        = string
  description = "EC2 instance type for managed node group."
  default     = "t3.medium"
}

variable "eks_node_desired_size" {
  type        = number
  description = "Desired number of nodes."
  default     = 2
}

variable "eks_node_min_size" {
  type        = number
  description = "Minimum number of nodes."
  default     = 1
}

variable "eks_node_max_size" {
  type        = number
  description = "Maximum number of nodes."
  default     = 3
}
