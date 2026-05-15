terraform {
  # частичная конфигурация, бакет передаём через backend.hcl
  # terraform init -backend-config=backend.hcl
  backend "gcs" {
    prefix = "state/prod/10-platform"
  }
}
