output "lb_ip" {
  description = "глобальный ip балансировщика, на него уже указывают dns записи"
  value       = module.gateway.lb_ip
}

output "cert_domains" { value = module.gateway.cert_domains }

output "bot_instance" { value = module.bot.instance_name }
output "bot_internal_ip" { value = module.bot.internal_ip }

output "jenkins_instance" {
  value = var.enable_jenkins ? module.jenkins[0].instance_name : ""
}
output "jenkins_internal_ip" {
  value = var.enable_jenkins ? module.jenkins[0].internal_ip : ""
}

output "ocpp_bucket" { value = module.web_ocpp.bucket_name }
