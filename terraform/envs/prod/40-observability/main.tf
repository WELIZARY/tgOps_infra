
data "terraform_remote_state" "platform" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket
    prefix = "state/prod/10-platform"
  }
}

module "observability" {
  source           = "../../../modules/observability"
  project_id       = var.project_id
  zone             = var.zone
  subnet_self_link = data.terraform_remote_state.platform.outputs.subnet_self_link
  mon_sa_email     = data.terraform_remote_state.platform.outputs.mon_sa_email
}

module "demo" {
  count            = var.enable_demo ? 1 : 0
  source           = "../../../modules/demo"
  project_id       = var.project_id
  zone             = var.zone
  subnet_self_link = data.terraform_remote_state.platform.outputs.subnet_self_link
}
