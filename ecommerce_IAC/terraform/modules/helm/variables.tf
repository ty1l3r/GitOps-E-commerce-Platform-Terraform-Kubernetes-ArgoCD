#-----------------------------------
# Variables Cluster EKS
#-----------------------------------
variable "cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint du cluster EKS"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Certificate authority data du cluster"
  type        = string
}

#-----------------------------------
# Variables Nginx Ingress
#-----------------------------------
variable "nginx_ingress_enabled" {
  description = "Activer ou désactiver Nginx Ingress"
  type        = bool
  default     = true
}

#-----------------------------------
# Variables Cert Manager
#-----------------------------------
variable "cert_manager_enabled" {
  description = "Activer ou désactiver Cert Manager"
  type        = bool
  default     = true
}

variable "cert_manager_email" {
  type        = string
  description = "Email pour Let's Encrypt"
}

#-----------------------------------
# Variables Velero
#-----------------------------------
variable "velero_bucket_name" {
  description = "Nom du bucket S3 pour Velero"
  type        = string
}

variable "aws_region" {
  description = "Région AWS"
  type        = string
}

variable "velero_role_arn" {
  description = "ARN du rôle IAM pour Velero"
  type        = string
}

#-----------------------------------
# Variables Communes
#-----------------------------------
variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement (dev, prod, etc.)"
  type        = string
}

variable "domain_name" {
  description = "Nom de domaine pour l'ingress"
  type        = string
}

variable "grafana_password" {
  type        = string
  description = "Mot de passe admin Grafana"
  sensitive   = true
}

#-----------------------------------
# Variables Fluentd
#-----------------------------------
variable "logs_bucket_name" {
  description = "Nom du bucket S3 pour les logs"
  type        = string
}

variable "fluentd_role_arn" {
  description = "ARN du rôle IAM pour Fluentd"
  type        = string
}

variable "fluentd_enabled" {
  description = "Activer ou désactiver Fluentd"
  type        = bool
  default     = true
}

variable "cluster_oidc_issuer_url" {
  description = "URL du fournisseur OIDC du cluster EKS"
  type        = string
}


