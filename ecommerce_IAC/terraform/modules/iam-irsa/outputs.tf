output "fluentd_role_arn" {
  description = "ARN du rôle IAM pour Fluentd"
  value       = aws_iam_role.fluentd.arn
}

output "mongodb_backup_role_arn" {
  description = "ARN du rôle IAM pour MongoDB Backup"
  value       = aws_iam_role.mongodb_backup.arn
}

output "velero_role_arn" {
  description = "ARN du rôle IAM pour Velero"
  value       = aws_iam_role.velero.arn
}
