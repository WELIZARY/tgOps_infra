
data "terraform_remote_state" "platform" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket
    prefix = "state/prod/10-platform"
  }
}

module "database" {
  source              = "../../../modules/database"
  project_id          = var.project_id
  region              = var.region
  network_self_link   = data.terraform_remote_state.platform.outputs.vpc_self_link
  psa_connection      = data.terraform_remote_state.platform.outputs.psa_connection
  bot_sa_email        = data.terraform_remote_state.platform.outputs.bot_sa_email
  tier                = var.db_tier
  enable_ha           = var.enable_ha
  enable_read_replica = var.enable_read_replica
}
