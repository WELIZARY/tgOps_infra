
output "vpc_self_link" { value = module.network.vpc_self_link }
output "subnet_self_link" { value = module.network.subnet_self_link }
output "subnet_cidr" { value = module.network.subnet_cidr }
output "psa_connection" { value = module.network.psa_connection }

output "primary_zone_name" { value = module.dns.primary_zone_name }
output "secondary_zone_name" { value = module.dns.secondary_zone_name }
output "primary_name_servers" {
  description = "ns записи прописаны у регистратора tgops.xyz"
  value       = module.dns.primary_name_servers
}
output "secondary_name_servers" {
  description = "ns записи прописаны у регистратора ocpp.by"
  value       = module.dns.secondary_name_servers
}

output "bot_sa_email" { value = module.security.bot_sa_email }
output "jenkins_sa_email" { value = module.security.jenkins_sa_email }
output "mon_sa_email" { value = module.security.mon_sa_email }
output "secret_ids" { value = module.security.secret_ids }

output "artifact_registry" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.images.repository_id}"
}
