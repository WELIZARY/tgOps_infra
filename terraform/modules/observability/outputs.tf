output "instance_name" {
  value = google_compute_instance.mon.name
}

output "instance_zone" {
  value = google_compute_instance.mon.zone
}

output "internal_ip" {
  description = "приватный ip, grafana смотрим через iap port forward"
  value       = google_compute_instance.mon.network_interface[0].network_ip
}
