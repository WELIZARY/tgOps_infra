output "instance_name" {
  value = google_compute_instance.jenkins.name
}

output "instance_zone" {
  value = google_compute_instance.jenkins.zone
}

output "internal_ip" {
  value = google_compute_instance.jenkins.network_interface[0].network_ip
}

output "backend_service_id" {
  description = "бэкенд для host rule jenkins.домен в общем lb"
  value       = google_compute_backend_service.jenkins.id
}
