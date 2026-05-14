output "provider_arn" {
  description = "OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "role_arns" {
  description = "Map of role-name → ARN."
  value       = { for k, v in aws_iam_role.gha : k => v.arn }
}
