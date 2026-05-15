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

variable "network_self_link" {
  description = "self link vpc"
  type        = string
}

variable "subnet_self_link" {
  description = "self link подсети"
  type        = string
}

variable "bot_sa_email" {
  description = "sa бота"
  type        = string
}

variable "machine_type" {
  description = "тип машины бота"
  type        = string
  default     = "e2-small"
}

variable "webhook_port" {
  description = "порт на котором локальный caddy принимает webhook"
  type        = number
  default     = 8443
}
