#===============================================================================
# VARIABLES MODULE EBS
#===============================================================================
variable "project_name" {
  type        = string
  description = "Nom du projet"
}

variable "environment" {
  type        = string
  description = "Environnement (production, staging, etc.)"
}