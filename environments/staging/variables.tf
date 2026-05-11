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
