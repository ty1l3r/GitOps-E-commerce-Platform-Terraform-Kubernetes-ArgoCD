variable "project_name" {
  type        = string
  description = "Nom du projet"
}

variable "environment" {
  type        = string
  description = "Environnement"
}

variable "vpc_config" {
  description = "Configuration du VPC"
  type = object({
    vpc_id     = string
    subnet_ids = list(string)
  })
}

variable "cluster_version" {
  type        = string
  description = "Version de Kubernetes"
  default     = "1.28"
}

variable "instance_types" {
  type        = list(string)
  description = "Types d'instances EC2 pour les nodes"
  default     = ["t3.large"]
}

variable "node_volume_size" {
  type        = number
  description = "Taille du volume EBS pour les nodes"
  default     = 18
}

variable "nodes_min_size" {
  type        = number
  description = "Nombre minimum de nodes"
  default     = 2
}

variable "nodes_max_size" {
  type        = number
  description = "Nombre maximum de nodes"
  default     = 2
}

variable "nodes_desired_size" {
  type        = number
  description = "Nombre désiré de nodes"
  default     = 2
}

variable "cluster_public_access_cidrs" {
  type        = list(string)
  description = "Liste des CIDR autorisés à accéder à l'API"
  default     = ["0.0.0.0/0"]
}

variable "cluster_service_ipv4_cidr" {
  type        = string
  description = "CIDR pour les services Kubernetes"
  default     = "172.20.0.0/16"
}

variable "eks_admins_iam_role_arn" {
  description = "ARN du rôle IAM admin EKS"
  type        = string
}

variable "mongodb_storage_class" {
  description = "Configuration du StorageClass MongoDB"
  type = object({
    name = string
    type = string
  })
}
variable "cluster_name" {
  type        = string
  description = "Nom standardisé du cluster EKS"
}
variable "node_role_arn" {
  description = "ARN du rôle IAM pour les nodes"
  type        = string
}
