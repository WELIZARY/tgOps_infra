variable "project_id" {
  description = "id gcp проекта"
  type        = string
}

variable "secrets" {
  description = "имена секретов в secret manager, значения добавляются ручками"
  type        = list(string)
  default = [
    "tgops-telegram-token",
    "tgops-telegram-webhook-secret",
    "tgops-telegram-alert-secret",
    "tgops-jenkins-webhook-secret",
  ]
}
