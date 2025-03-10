output "tags" {
  description = "Tags communs pour les ressources"
  value = {
    environment = var.environment
    project     = var.project_name
    managed-by  = "terraform"
  }
}

output "name_prefix" {
  description = "Préfixe pour les noms des ressources"
  value       = local.name_prefix
}