output "primary_zone_name" {
  value = google_dns_managed_zone.primary.name
}

output "secondary_zone_name" {
  value = google_dns_managed_zone.secondary.name
}

output "primary_name_servers" {
  description = "эти ns прописаны у регистратора tgops.xyz"
  value       = google_dns_managed_zone.primary.name_servers
}

output "secondary_name_servers" {
  description = "эти ns прописаны у регистратора ocpp.by"
  value       = google_dns_managed_zone.secondary.name_servers
}
