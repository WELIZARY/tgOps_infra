output "mon_instance" { value = module.observability.instance_name }
output "mon_internal_ip" {
  description = "grafana через iap port forward на этот ip"
  value       = module.observability.internal_ip
}
output "demo_nodes" {
  value = var.enable_demo ? module.demo[0].nodes : {}
}
