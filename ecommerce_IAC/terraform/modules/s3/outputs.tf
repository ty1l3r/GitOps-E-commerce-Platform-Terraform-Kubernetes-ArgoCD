#===============================================================================
# OUTPUTS
#===============================================================================

# Backup Bucket Outputs
output "backup_bucket" {
  description = "Informations du bucket backup (Velero)"
  value = {
    name = aws_s3_bucket.backup.id
    arn  = aws_s3_bucket.backup.arn
  }
}

# Logs Bucket Outputs
output "logs_bucket" {
  description = "Informations du bucket logs"
  value = {
    name = aws_s3_bucket.logs.id
    arn  = aws_s3_bucket.logs.arn
  }
}

# Outputs spécifiques pour Helm
output "velero_backup_bucket" {
  description = "Nom du bucket pour les backups Velero"
  value       = aws_s3_bucket.backup.id
}

output "fluentd_bucket" {
  description = "Nom du bucket pour Fluentd"
  value       = aws_s3_bucket.logs.id
}