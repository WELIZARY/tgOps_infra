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

variable "jenkins_sa_email" {
  description = "sa jenkins"
  type        = string
}

variable "machine_type" {
  description = "тип машины jenkins"
  type        = string
  default     = "e2-small"
}

variable "allow_ips" {
  description = "список ip cidr которым разрешён доступ к ui jenkins через cloud armor"
  type        = list(string)
  default     = []
}

variable "enable_armor" {
  description = "создавать cloud armor (на trial квота = 0, держим выключенным)"
  type        = bool
  default     = false
}

variable "jenkins_port" {
  description = "порт reverse proxy jenkins на vm"
  type        = number
  default     = 8081
}
