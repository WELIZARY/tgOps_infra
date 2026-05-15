variable "project_id" {
  description = "id gcp проекта"
  type        = string
}

variable "primary_domain" {
  description = "основной домен (tgops.xyz)"
  type        = string
}

variable "secondary_domain" {
  description = "второй домен (ocpp.by)"
  type        = string
}

variable "primary_zone_name" {
  description = "имя cloud dns зоны основного домена"
  type        = string
}

variable "secondary_zone_name" {
  description = "имя cloud dns зоны второго домена"
  type        = string
}

variable "web_backend_id" {
  description = "бэкенд сервис сайта tgops"
  type        = string
}

variable "bot_backend_id" {
  description = "бэкенд сервис вебхука бота"
  type        = string
}

variable "jenkins_backend_id" {
  description = "бэкенд сервис ui jenkins, пусто если jenkins выключен"
  type        = string
  default     = ""
}

variable "enable_jenkins" {
  description = "включён ли jenkins, известно на плане (в отличие от backend id)"
  type        = bool
  default     = false
}

variable "ocpp_backend_bucket_id" {
  description = "бэкенд-бакет статики ocpp"
  type        = string
}
