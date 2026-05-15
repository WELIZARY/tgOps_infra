output "lb_ip" {
  description = "глобальный ip lb"
  value       = google_compute_global_address.lb.address
}

output "cert_domains" {
  value = local.cert_domains
}
