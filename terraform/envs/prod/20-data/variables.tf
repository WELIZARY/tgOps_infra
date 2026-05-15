variable "project_id" {
  description = "id gcp проекта"
  type        = string
}

variable "region" {
  description = "регион"
  type        = string
  default     = "europe-west3"
}

variable "state_bucket" {
  description = "бакет с remote state, для чтения слоя платформы"
  type        = string
  default     = "tgops-tfstate-prod"
}

variable "db_tier" {
  description = "tier cloud sql"
  type        = string
  default     = "db-g1-small"
}

variable "enable_ha" {
  description = "regional ha"
  type        = bool
  default     = true
}

variable "enable_read_replica" {
  description = "поднимать read replica"
  type        = bool
  default     = true
}
