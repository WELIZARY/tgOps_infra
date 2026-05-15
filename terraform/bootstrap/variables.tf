variable "project_id" {
  description = "id gcp проекта (например tgops-prod)"
  type        = string
}

variable "region" {
  description = "основной регион compute"
  type        = string
  default     = "europe-west3"
}

variable "github_owner" {
  description = "github owner или org для wif условия"
  type        = string
  default     = "WELIZARY"
}

variable "github_repos" {
  description = "репозитории которым разрешён wif (owner/repo)"
  type        = list(string)
  default     = ["WELIZARY/tgOps", "WELIZARY/tgOps_infra"]
}

variable "state_bucket_name" {
  description = "имя gcs бакета под terraform state"
  type        = string
  default     = "tgops-tfstate-prod"
}

variable "db_export_bucket_name" {
  description = "имя gcs бакета под dr экспорт бд"
  type        = string
  default     = "tgops-db-export-prod"
}
