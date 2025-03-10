variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}
variable "tfstate_bucket" {
  type = string
  description = "Nom du bucket S3 pour le tfstate"
}
variable "backup_bucket_name" {
  type        = string
  description = "Nom du bucket S3 pour les backups Velero"
  default     = "red-project-production-2-backup"
}

variable "cluster_role_arn" {
  description = "ARN du rôle du cluster EKS"
  type        = string
  default     = null  # Permet l'utilisation conditionnelle
}

