variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "red-project"
}
variable "availability_zones" {
  description = "AWS AZs to use"
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
}
