variable "project_id" {
  description = "id gcp проекта"
  type        = string
}

variable "zone" {
  description = "зона vm"
  type        = string
  default     = "europe-west3-a"
}

variable "subnet_self_link" {
  description = "self link подсети"
  type        = string
}

variable "mon_sa_email" {
  description = "sa мониторинга"
  type        = string
}

variable "machine_type" {
  description = "тип машины"
  type        = string
  default     = "e2-medium"
}
