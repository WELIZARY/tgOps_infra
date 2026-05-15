# cloud run сайт tgops.xyz, два региона за общим lb

locals {
  regions = var.enable_multiregion ? [var.primary_region, var.secondary_region] : [var.primary_region]
}

resource "google_cloud_run_v2_service" "site" {
  for_each = toset(local.regions)
  project  = var.project_id
  name     = "tgops-web-${each.value}"
  location = each.value
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }
    containers {
      image = var.image
      ports { container_port = 8080 }
    }
  }
}

# сайт публичный, доступ только через lb 
resource "google_cloud_run_v2_service_iam_member" "public" {
  for_each = google_cloud_run_v2_service.site
  project  = var.project_id
  location = each.value.location
  name     = each.value.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# serverless на каждый регион
resource "google_compute_region_network_endpoint_group" "site" {
  for_each              = google_cloud_run_v2_service.site
  project               = var.project_id
  name                  = "tgops-web-neg-${each.value.location}"
  region                = each.value.location
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = each.value.name
  }
}

resource "google_compute_backend_service" "site" {
  project               = var.project_id
  name                  = "tgops-web-backend"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"

  dynamic "backend" {
    for_each = google_compute_region_network_endpoint_group.site
    content {
      group = backend.value.id
    }
  }
}
