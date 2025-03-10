#-----------------------------------
# Outputs ArgoCD
#-----------------------------------
output "argocd_namespace" {
  description = "Namespace d'ArgoCD"
  value       = helm_release.argocd.namespace
}

output "argocd_server_url" {
  description = "URL du serveur ArgoCD"
  value       = "http://argocd.${var.domain_name}"
}

output "argocd_server_service_name" {
  description = "Nom du service ArgoCD"
  value       = "argocd-server"
}

output "argocd_repository_credentials" {
  description = "Statut des credentials du repository"
  value       = "Configured for ${var.gitlab_repo_url}"
  sensitive   = true
}

output "argocd_applications" {
  description = "Applications configurées dans ArgoCD"
  value = {
    name        = "prod-apps"
    namespace   = var.environment
    repository  = var.gitlab_repo_url
    path        = var.environment
  }
}

output "argocd_ingress_host" {
  description = "Hostname de l'ingress ArgoCD"
  value       = "argocd.${var.domain_name}"
}


output "debug_values" {
  value = templatefile("${path.module}/template/values.yaml", {
    domain_name           = var.domain_name
    gitlab_repo_url       = var.gitlab_repo_url
    app_repository_secret = var.app_repository_secret
  })
  sensitive = true
}

