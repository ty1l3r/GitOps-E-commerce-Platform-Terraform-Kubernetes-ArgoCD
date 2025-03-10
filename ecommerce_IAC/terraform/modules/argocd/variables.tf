# Variables obligatoires pour ArgoCD
variable "gitlab_repo_url" {
  type        = string
  description = "URL du repository manifest"
  default     = "git@gitlab.com:wonder-team-devops/prod-manifest.git"
}

variable "app_repository_secret" {
  type        = string
  description = "Clé SSH pour le repository manifest"
  sensitive   = true
}

variable "domain_name" {
  type        = string
  description = "Nom de domaine pour l'ingress"
}

variable "environment" {
  type        = string
  description = "Environnement (production)"
  default     = "production"
}

variable "helm_dependencies" {
  description = "Liste des dépendances Helm à attendre"
  type        = list(any)
  default     = []
}
