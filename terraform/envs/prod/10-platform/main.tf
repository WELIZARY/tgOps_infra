
module "network" {
  source     = "../../../modules/network"
  project_id = var.project_id
  region     = var.region
}

module "dns" {
  source           = "../../../modules/dns"
  project_id       = var.project_id
  primary_domain   = var.primary_domain
  secondary_domain = var.secondary_domain
}

module "security" {
  source     = "../../../modules/security"
  project_id = var.project_id
}

# реестр образов бота
resource "google_artifact_registry_repository" "images" {
  project       = var.project_id
  location      = var.region
  repository_id = "tgops-images"
  format        = "DOCKER"
  description   = "образы бота tgops"
}
