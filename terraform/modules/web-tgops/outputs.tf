output "backend_service_id" {
  value = google_compute_backend_service.site.id
}

output "service_names" {
  value = [for s in google_cloud_run_v2_service.site : s.name]
}
