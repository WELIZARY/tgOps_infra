variable "project_id" {
  description = "id gcp проекта"
  type        = string
}

variable "region" {
  description = "регион подсети"
  type        = string
  default     = "europe-west3"
}

variable "subnet_cidr" {
  description = "cidr основной подсети"
  type        = string
  default     = "10.10.0.0/20"
}
