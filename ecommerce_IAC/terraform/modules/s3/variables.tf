#===============================================================================
# VARIABLES
#===============================================================================
variable "project_name" {
  type        = string
  description = "Nom du projet"
  default     = "red-project"
}

variable "environment" {
  type        = string
  description = "Environnement déployé"
  default     = "production"
}

variable "retention_days" {
  description = "Durée de rétention par type de données"
  type = object({
    backup = object({
      mongodb = number
      velero  = number    # Ajout de velero, suppression de helm
    })
    logs = object({
      audit    = number
      security = number
      access   = number
      events   = number
    })
  })
}