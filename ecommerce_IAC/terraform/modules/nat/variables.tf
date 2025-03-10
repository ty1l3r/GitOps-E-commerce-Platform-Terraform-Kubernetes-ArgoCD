variable "project_name" {
  type        = string
  description = "Nom du projet"
}

variable "environment" {
  type        = string
  description = "Environnement (dev, staging, prod)"
}

variable "vpc_id" {
  type        = string
  description = "ID du VPC"
}

variable "availability_zones" {
  type        = list(string)
  description = "Liste des zones de disponibilité"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "IDs des subnets publics"
}