variable "environment" {
  type        = string
  description = "Environment name."
}

variable "services" {
  type        = list(string)
  description = "List of service names — one ECR repo is created per service."
}

variable "image_retention_count" {
  type        = number
  description = "Number of tagged images to keep per repo."
  default     = 20
}
