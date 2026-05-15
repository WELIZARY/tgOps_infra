terraform {
  # terraform init -backend-config=backend.hcl
  backend "gcs" {
    prefix = "state/prod/20-data"
  }
}
