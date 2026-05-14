output "repository_urls" {
  description = "Map of service name → ECR repository URL."
  value       = { for k, v in aws_ecr_repository.services : k => v.repository_url }
}

output "registry_id" {
  description = "AWS account ID that owns the registries."
  value       = values(aws_ecr_repository.services)[0].registry_id
}
