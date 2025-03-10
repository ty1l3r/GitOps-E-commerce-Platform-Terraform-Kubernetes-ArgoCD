#===============================================================================
# INFRASTRUCTURE DE BASE
#===============================================================================

# VPC & Networking
output "vpc_id" {
  description = "ID du VPC"
  value       = module.vpc.vpc_id
}

#===============================================================================
# EKS
#===============================================================================

output "cluster_name" {
  description = "Nom du cluster EKS"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint du cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate" {
  description = "Certificate Authority du cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_region" {
  description = "Région AWS du cluster"
  value       = var.aws_region
}

output "cluster_primary_security_group_id" {
  description = "ID du security group principal du cluster"
  value       = module.eks.cluster_primary_security_group_id
}

output "node_security_group_id" {
  description = "ID du security group des nodes"
  value       = module.eks.node_security_group_id
}

#===============================================================================
# IAM
#===============================================================================

output "eks_admins_role_arn" {
  description = "ARN du rôle IAM admin EKS"
  value       = module.iam_base.eks_admin_role_arn  # Correction ici
}

#===============================================================================
# STOCKAGE
#===============================================================================

output "backup_bucket" {
  description = "Nom du bucket de backup"
  value       = module.s3.backup_bucket.name
}

output "logs_bucket" {
  description = "Nom du bucket de logs"
  value       = module.s3.logs_bucket.name
}

#===============================================================================
# KUBERNETES NAMESPACES
#===============================================================================
output "monitoring_namespace" {
  description = "Namespace monitoring"
  value       = module.helm.prometheus_namespace
}

output "logging_namespace" {
  description = "Namespace logging"
  value       = module.helm.fluentd_namespace
}

output "cert_manager_namespace" {
  description = "Namespace cert-manager"
  value       = module.helm.cert_manager_namespace
}

#===============================================================================
# VELERO
#===============================================================================
output "velero_namespace" {
  description = "Namespace de Velero"
  value       = module.helm.velero_namespace
}

output "velero_backup_location" {
  description = "Location des backups Velero"
  value       = "${module.s3.backup_bucket.name}/velero"
}

output "velero_service_account" {
  description = "Service Account utilisé par Velero"
  value       = module.helm.velero_service_account
}

output "velero_role_arn" {
  description = "ARN du rôle IAM utilisé par Velero"
  value       = module.iam_irsa.velero_role_arn
}

output "cluster_subnet_ids" {
  description = "IDs des subnets du cluster"
  value       = concat(
    module.private_subnets.private_subnet_ids,
    module.public_subnets.public_subnet_ids
  )
}

output "mongodb_backup_role_arn" {
  description = "ARN du rôle IAM utilisé pour les backups MongoDB"
  value       = module.iam_irsa.mongodb_backup_role_arn
}

output "debug_ssh_key" {
  value = var.app_repository_secret
  sensitive = true
}

output "argocd_debug" {
  value = module.argocd.debug_values
  sensitive = true
}

output "storage_class_name" {
  description = "Nom du StorageClass par défaut"
  value       = module.eks.storage_class_name  # Vient du module EKS
}

# Expose les infos des volumes EBS
output "ebs_volumes" {
  description = "Configuration des volumes EBS"
  value       = module.ebs.volumes  # Vient du module EBS
}