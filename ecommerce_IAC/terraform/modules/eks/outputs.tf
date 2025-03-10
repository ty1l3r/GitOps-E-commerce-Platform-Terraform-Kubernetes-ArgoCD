output "cluster_name" {
  description = "Nom du cluster EKS"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint du cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Certificate authority data pour l'authentification"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "URL de l'émetteur OIDC du cluster"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_primary_security_group_id" {
  description = "ID du security group principal du cluster"
  value       = module.eks.cluster_primary_security_group_id
}

output "node_security_group_id" {
  description = "ID du security group des nodes"
  value       = module.eks.node_security_group_id
}

output "oidc_provider" {
  description = "URL du provider OIDC EKS"
  value       = module.eks.cluster_oidc_issuer_url # Utilisation du module EKS
}

output "oidc_provider_arn" {
  description = "ARN du provider OIDC"
  value       = module.eks.oidc_provider_arn # Utilisation du module EKS
}

output "storage_class_name" {
  description = "Nom du StorageClass par défaut"
  value       = kubernetes_storage_class.gp3.metadata[0].name  # Correction du nom
}