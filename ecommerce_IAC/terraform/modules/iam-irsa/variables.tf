variable "project_name" {
  type        = string
  description = "Nom du projet"
}

variable "environment" {
  type        = string
  description = "Environnement"
}

variable "eks_oidc_provider" {
  type        = string
  description = "URL du provider OIDC EKS"
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "ARN du provider OIDC EKS"
}

variable "logs_bucket_arn" {
  description = "ARN du bucket S3 pour logs"
  type        = string
}

variable "backup_bucket_arn" {
  description = "ARN du bucket S3 pour backups"
  type        = string
}
variable "velero_namespace" {
  description = "Namespace où Velero est déployé"
  type        = string
  default     = "velero"
}

variable "velero_service_account" {
  description = "Nom du service account Velero"
  type        = string
  default     = "velero"
}
variable "tf_state_bucket" {
  description = "Nom du bucket S3 pour le state Terraform"
  type        = string
}