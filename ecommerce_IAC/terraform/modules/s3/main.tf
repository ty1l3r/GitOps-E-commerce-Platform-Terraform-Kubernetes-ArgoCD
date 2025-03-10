#===============================================================================
# MODULE COMMONS - Définition des tags standards et nommage
#===============================================================================
module "commons" {
  source       = "../commons"
  project_name = var.project_name
  environment  = var.environment
}

locals {
  name = "${var.project_name}-${var.environment}"
}

#===============================================================================
# BUCKET DE BACKUP - Stockage pour les sauvegardes MongoDB et Velero
#===============================================================================
resource "aws_s3_bucket" "backup" {
  bucket        = "${local.name}-backup-2"
  force_destroy = true
  tags = merge(module.commons.tags, {
    Purpose = "Backups MongoDB et Velero"
  })
}

# Configuration du versioning pour le bucket backup
resource "aws_s3_bucket_versioning" "backup" {
  bucket = aws_s3_bucket.backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configuration des règles de cycle de vie pour le bucket backup
# la gestion de la rétention sera entièrement gérée par Velero plutôt que par des règles de cycle de vie S3.
# resource "aws_s3_bucket_lifecycle_configuration" "backup" {
#   bucket = aws_s3_bucket.backup.id

#   depends_on = [
#     aws_s3_bucket.backup,
#     aws_s3_bucket_versioning.backup
#   ]

#   # MongoDB backups - Configuration de rétention par service
#   dynamic "rule" {
#     for_each = ["customers", "products", "shopping"]
#     content {
#       id     = "mongodb_${rule.value}"
#       status = "Enabled"
#       filter {
#         prefix = "mongodb/${rule.value}/"
#       }
#       expiration {
#         days = var.retention_days.backup.mongodb
#       }
#     }
#   }

#   # Velero backups - Configuration de rétention par type de ressource
#   dynamic "rule" {
#     for_each = ["cluster-config", "namespaces", "deployments", "configs"]
#     content {
#       id     = "velero_${rule.value}"
#       status = "Enabled"
#       filter {
#         prefix = "velero/${rule.value}/"
#       }
#       expiration {
#         days = var.retention_days.backup.velero
#       }
#     }
#   }
# }

#===============================================================================
# BUCKET DE LOGS - Stockage pour les journaux d'application
#===============================================================================
resource "aws_s3_bucket" "logs" {
  bucket        = "${local.name}-logs-2"
  force_destroy = true
  tags = merge(module.commons.tags, {
    Purpose = "Application Logs"
  })
}

# Configuration du versioning pour le bucket logs
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  # Dépendance explicite pour garantir l'ordre de création
  depends_on = [aws_s3_bucket.logs]

  versioning_configuration {
    status = "Enabled"
  }
}

# Configuration du cycle de vie pour le bucket logs - Simplifiée
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  # Dépendances explicites pour assurer l'ordre de création
  depends_on = [
    aws_s3_bucket.logs,
    aws_s3_bucket_versioning.logs
  ]

  bucket = aws_s3_bucket.logs.id

  # Règle unique pour tous les logs (évite les problèmes de création)
  rule {
    id     = "all_logs_expiration"
    status = "Enabled"

    expiration {
      days = 30  # Période de rétention standard pour les logs
    }
  }

  # Assure une création correcte de la ressource
  lifecycle {
    create_before_destroy = true
  }
}