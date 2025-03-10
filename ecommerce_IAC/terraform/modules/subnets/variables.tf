variable "project_name" {
  type        = string
  description = "Nom du projet"
}

variable "environment" {
  type        = string
  description = "Environnement"
}

variable "vpc_id" {
  type        = string
  description = "ID du VPC"
}

variable "public_route_table_id" {
  type        = string
  description = "ID de la table de routage publique"
  default     = null  # Pour permettre null pour les sous-réseaux privés
}

variable "availability_zones" {
  type        = list(string)
  description = "Liste des zones de disponibilité"
}

variable "subnets_cidr" {
  type        = list(string)
  description = "Liste des CIDR pour les subnets"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "Liste des CIDR pour les subnets publics"
  default     = []
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "Liste des CIDR pour les subnets privés"
  default     = []
}

variable "nat_gateway_ids" {
  type        = list(string)
  description = "IDs des NAT Gateways"
  default     = []
}

variable "private" {
  type        = bool
  description = "Indique si les subnets sont privés"
  default     = false
}
variable "cluster_name" {
  type        = string
  description = "Nom du cluster EKS"
}