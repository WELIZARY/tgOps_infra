variable "project_id" {
  description = "id gcp проекта"
  type        = string
}

variable "region" {
  description = "регион"
  type        = string
  default     = "europe-west3"
}

variable "zone" {
  description = "зона vm"
  type        = string
  default     = "europe-west3-a"
}

variable "state_bucket" {
  description = "бакет с remote state, для чтения слоя платформы"
  type        = string
  default     = "tgops-tfstate-prod"
}

variable "enable_demo" {
  description = "поднимать demo ноды для сценариев поломок"
  type        = bool
  default     = true
}
