output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data."
  value       = aws_eks_cluster.main.certificate_authority[0].data
}
