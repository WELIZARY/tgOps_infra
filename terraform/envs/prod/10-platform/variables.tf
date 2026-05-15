variable "project_id" {
  description = "id gcp проекта"
  type        = string
}

variable "region" {
  description = "основной регион"
  type        = string
  default     = "europe-west3"
}

variable "primary_domain" {
  description = "основной домен"
  type        = string
  default     = "tgops.xyz"
}

variable "secondary_domain" {
  description = "второй домен"
  type        = string
  default     = "ocpp.by"
}
