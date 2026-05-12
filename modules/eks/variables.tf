variable "environment" {
  type        = string
  description = "Environment name."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID from the network module."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for EKS nodes (from network module)."
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster."
  default     = "1.31"
}

variable "node_instance_type" {
  type        = string
  description = "EC2 instance type for managed node group."
  default     = "t3.medium"
}

variable "node_desired_size" {
  type        = number
  description = "Desired number of nodes."
  default     = 2
}

variable "node_min_size" {
  type        = number
  description = "Minimum number of nodes."
  default     = 1
}

variable "node_max_size" {
  type        = number
  description = "Maximum number of nodes."
  default     = 3
}

variable "admin_role_arn" {
  type        = string
  description = "IAM role ARN granted cluster-admin via EKS access entry."
}
