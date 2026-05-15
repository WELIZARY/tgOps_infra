variable "project_id" {
  description = "id gcp проекта"
  type        = string
}

variable "bucket_name" {
  description = "имя бакета статики, глобально уникальное"
  type        = string
  default     = "tgops-ocpp-site"
}

variable "location" {
  description = "локация бакета, eu для мульти региона"
  type        = string
  default     = "EU"
}
