output "instance_name" {
  value = google_compute_instance.bot.name
}

output "instance_zone" {
  value = google_compute_instance.bot.zone
}

output "internal_ip" {
  value = google_compute_address.internal.address
}

output "backend_service_id" {
  description = "бэкенд для host rule bot.домен в общем lb"
  value       = google_compute_backend_service.bot.id
}
