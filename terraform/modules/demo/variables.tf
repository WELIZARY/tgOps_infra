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

variable "nodes" {
  description = "имена demo нод, цели длясценариев"
  type        = list(string)
  default     = ["demo-app", "demo-host", "demo-broken", "ssl-target"]
}

variable "machine_type" {
  description = "тип машины демо нод"
  type        = string
  default     = "e2-small"
}
