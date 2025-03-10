output "eks_admin_role_arn" {
  description = "ARN du rôle admin EKS"
  value       = aws_iam_role.eks_admin.arn
}

output "node_group_role_arn" {
  description = "ARN du rôle pour les nodes EKS"
  value       = aws_iam_role.node_group.arn
}
