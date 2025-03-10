#===============================================================================
# VARIABLES
# Description: Variables nécessaires pour la configuration du VPC
#===============================================================================
variable "project_name" {
  type        = string
  description = "Nom du projet pour le tagging des ressources"
}
variable "environment" {
  type        = string
  description = "Environnement (dev, staging, prod) pour la séparation des ressources"
}
variable "region" {
  type        = string
  default     = "eu-west-3"
  description = "Région AWS (Paris par défaut)"
}
variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block pour définir la plage d'adresses IP du VPC"
}
variable "availability_zones" {
  description = "List of AZs"
  type        = list(string)
}
variable "private_subnets_cidr" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "public_subnets_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
#-----------------------------------
# Variables Velero
#-----------------------------------
variable "velero_provider" {
  description = "Provider pour Velero (aws, azure, gcp)"
  type        = string
  default     = "aws"
}

variable "velero_backup_retention_days" {
  description = "Nombre de jours de rétention des backups Velero"
  type        = number
  default     = 30
}

variable "velero_schedule" {
  description = "Schedule des backups Velero (format cron)"
  type        = string
  default     = "0 */6 * * *" # Toutes les 6 heures
}

variable "velero_included_namespaces" {
  description = "Liste des namespaces à sauvegarder"
  type        = list(string)
  default     = ["*"]  # Tous les namespaces
}
# Ajouter variable
variable "cluster_name" {
  type = string
  description = "Nom standardisé du cluster EKS"
}