
data "terraform_remote_state" "platform" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket
    prefix = "state/prod/10-platform"
  }
}

module "bot" {
  source            = "../../../modules/bot"
  project_id        = var.project_id
  region            = var.region
  zone              = var.zone
  network_self_link = data.terraform_remote_state.platform.outputs.vpc_self_link
  subnet_self_link  = data.terraform_remote_state.platform.outputs.subnet_self_link
  bot_sa_email      = data.terraform_remote_state.platform.outputs.bot_sa_email
}

module "jenkins" {
  count             = var.enable_jenkins ? 1 : 0
  source            = "../../../modules/jenkins"
  project_id        = var.project_id
  region            = var.region
  zone              = var.zone
  network_self_link = data.terraform_remote_state.platform.outputs.vpc_self_link
  subnet_self_link  = data.terraform_remote_state.platform.outputs.subnet_self_link
  jenkins_sa_email  = data.terraform_remote_state.platform.outputs.jenkins_sa_email
  allow_ips         = var.jenkins_allow_ips
  enable_armor      = var.jenkins_enable_armor
}

module "web_tgops" {
  source     = "../../../modules/web-tgops"
  project_id = var.project_id
  image      = var.web_image
}

module "web_ocpp" {
  source      = "../../../modules/web-ocpp"
  project_id  = var.project_id
  bucket_name = var.ocpp_bucket_name
}

module "gateway" {
  source                 = "../../../modules/gateway"
  project_id             = var.project_id
  primary_domain         = var.primary_domain
  secondary_domain       = var.secondary_domain
  primary_zone_name      = data.terraform_remote_state.platform.outputs.primary_zone_name
  secondary_zone_name    = data.terraform_remote_state.platform.outputs.secondary_zone_name
  web_backend_id         = module.web_tgops.backend_service_id
  bot_backend_id         = module.bot.backend_service_id
  enable_jenkins         = var.enable_jenkins
  jenkins_backend_id     = var.enable_jenkins ? module.jenkins[0].backend_service_id : ""
  ocpp_backend_bucket_id = module.web_ocpp.backend_bucket_id
}
