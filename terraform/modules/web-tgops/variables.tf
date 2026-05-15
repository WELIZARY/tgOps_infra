variable "project_id" {
  description = "id gcp проекта"
  type        = string
}

variable "primary_region" {
  description = "первый регион cloud run"
  type        = string
  default     = "europe-west3"
}

variable "secondary_region" {
  description = "второй регион cloud run для multi region"
  type        = string
  default     = "europe-west4"
}

variable "enable_multiregion" {
  description = "поднимать cloud run во втором регионе"
  type        = bool
  default     = true
}

variable "image" {
  description = "образ сайта, по умолчанию hello заглушка пока ci не собрал свой"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}
