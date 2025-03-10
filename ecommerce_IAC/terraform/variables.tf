#-----------------------------------
# Variables Communes
#-----------------------------------
variable "environment" {
  type        = string
  description = "Environnement (production, staging, etc.)"
}

variable "domain_name" {
  type        = string
  description = "Nom de domaine pour l'ingress"
}

variable "project_name" {
  type        = string
  description = "Nom du projet"
  default     = "red-project"
}

variable "aws_region" {
  type        = string
  description = "Région AWS"
  default     = "eu-west-3"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = ["eu-west-3a", "eu-west-3b"]
}

variable "cert_manager_email" {
  type        = string
  description = "Email pour Let's Encrypt"
}

variable "grafana_password" {
  type        = string
  description = "Mot de passe admin Grafana"
  sensitive   = true
}

variable "retention_days" {
  description = "Durée de rétention par type de données"
  type = object({
    backup = object({
      mongodb = number
      velero  = number    
    })
    logs = object({
      audit    = number
      security = number
      access   = number
      events   = number
    })
  })
}

variable "private_subnets_cidr" {
  description = "Liste des CIDR pour les sous-réseaux privés"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "public_subnets_cidr" {
  description = "Liste des CIDR pour les sous-réseaux publics"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
}

#-----------------------------------
# Variables GitLab/ArgoCD
#-----------------------------------
variable "gitlab_repo_url" {
  type        = string
  description = "URL du repository GitLab"
  default     = "git@gitlab.com:wonder-team-devops/prod-manifest.git"
}

variable "gitlab_ssh_key" {
  type        = string
  description = "Clé SSH pour l'accès au repository"
  sensitive   = true
}

variable "app_repository_url" {
  description = "URL du repository applicatif"
  type        = string
  default     = "git@gitlab.com:wonder-team-devops/prod-manifest.git"
}

variable "app_repository_secret" {
  type        = string
  description = "Clé SSH pour le repository manifest"
  sensitive   = true
}

variable "mongodb_storage_class" {
  description = "Configuration du StorageClass MongoDB"
  type = object({
    name = string
    type = string
  })
  default = {
    name = "gp3-encrypted"
    type = "gp3"
  }
}

variable "argocd_admin_password" {
  description = "Mot de passe admin pour ArgoCD"
  type        = string
  sensitive   = true
}

#-----------------------------------
# Variables State Management
#-----------------------------------
variable "tf_state_bucket" {
  description = "Nom du bucket S3 pour le state Terraform"
  type        = string
  default     = "red-project-production-tfstate"
}

variable "dynamodb_table" {
  description = "Nom de la table DynamoDB pour le state lock"
  type        = string
  default     = "red-project-production-tfstate-lock"
}