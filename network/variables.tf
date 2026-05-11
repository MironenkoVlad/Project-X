variable "environment" {
  type        = string
  description = "Which environment this module instance is for. Drives resource names and tags."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC. /16 in practice (e.g. 10.10.0.0/16)."

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR notation (e.g. 10.10.0.0/16)."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Exactly 3 CIDR blocks for public subnets, one per AZ (a/b/c in order)."

  validation {
    condition     = length(var.public_subnet_cidrs) == 3
    error_message = "public_subnet_cidrs must contain exactly 3 entries."
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Exactly 3 CIDR blocks for private subnets, one per AZ (a/b/c in order)."

  validation {
    condition     = length(var.private_subnet_cidrs) == 3
    error_message = "private_subnet_cidrs must contain exactly 3 entries."
  }
}

variable "cost_center" {
  type        = string
  default     = "platform"
  description = "Tag value applied to billable resources (e.g. platform-dev)."
}
