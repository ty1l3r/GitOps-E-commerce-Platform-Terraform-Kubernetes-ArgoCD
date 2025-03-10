variable "vpc_id" {
  description = "ID du VPC où les security groups seront créés"
  type        = string
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement (production, staging, development)"
  type        = string
  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "L'environnement doit être 'production', 'staging' ou 'development'"
  }
}

variable "tags" {
  description = "Tags additionnels à appliquer aux ressources"
  type        = map(string)
  default     = {}
}

variable "cluster_security_group_ids" {
  description = "Liste des security groups additionnels pour le cluster"
  type        = list(string)
  default     = []
}

variable "node_security_group_ids" {
  description = "Liste des security groups additionnels pour les nodes"
  type        = list(string)
  default     = []
}

variable "eks_nodes_security_group_id" {
  type        = string
  description = "ID du security group des nodes EKS"
}