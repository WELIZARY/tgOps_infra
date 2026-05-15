variable "project_id" {
  description = "id gcp проекта"
  type        = string
}

variable "region" {
  description = "основной регион"
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

variable "enable_jenkins" {
  description = "поднимать jenkins vm и его роут в lb"
  type        = bool
  default     = true
}

variable "jenkins_allow_ips" {
  description = "ip cidr с доступом к ui jenkins (только если включён armor)"
  type        = list(string)
  default     = []
}

variable "jenkins_enable_armor" {
  description = "cloud armor для jenkins, на trial квота = 0 поэтому выключено"
  type        = bool
  default     = false
}

variable "web_image" {
  description = "образ сайта tgops"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello" #временная заглуша до деплоя своей странички
}

variable "ocpp_bucket_name" {
  description = "имя бакета статики ocpp"
  type        = string
  default     = "tgops-ocpp-site"
}
