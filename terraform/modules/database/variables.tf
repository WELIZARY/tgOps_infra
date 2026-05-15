variable "project_id" {
  description = "id gcp проекта"
  type        = string
}

variable "region" {
  description = "регион инстанса"
  type        = string
  default     = "europe-west3"
}

variable "network_self_link" {
  description = "self link vpc для приватного ip"
  type        = string
}

variable "psa_connection" {
  description = "id service networking connection, для зависимости порядка"
  type        = string
}

variable "tier" {
  description = "tier инстанса cloud sql"
  type        = string
  default     = "db-g1-small"
}

variable "enable_ha" {
  description = "regional ha (primary плюс standby с авто failover)"
  type        = bool
  default     = true
}

variable "enable_read_replica" {
  description = "поднимать read replica"
  type        = bool
  default     = true
}

variable "db_name" {
  description = "имя базы"
  type        = string
  default     = "tgops"
}

variable "db_user" {
  description = "имя пользователя бд"
  type        = string
  default     = "tgops"
}

variable "bot_sa_email" {
  description = "SA бота, ему выдается доступ к секрету с паролем"
  type        = string
}
