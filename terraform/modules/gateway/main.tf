# один глобальный внешний https lb на все сервисы, один ip, один серт

locals {
  bot_host     = "bot.${var.primary_domain}"
  jenkins_host = "jenkins.${var.primary_domain}"
  www_host     = "www.${var.primary_domain}"

  cert_domains = compact([
    var.primary_domain,
    local.www_host,
    local.bot_host,
    var.enable_jenkins ? local.jenkins_host : "",
    var.secondary_domain,
  ])
}

resource "google_compute_global_address" "lb" {
  project = var.project_id
  name    = "tgops-lb-ip"
}

resource "google_compute_managed_ssl_certificate" "lb" {
  project = var.project_id
  name    = "tgops-lb-cert"
  managed {
    domains = local.cert_domains
  }
}

# маршрутизация по host
resource "google_compute_url_map" "lb" {
  project         = var.project_id
  name            = "tgops-lb-urlmap"
  default_service = var.web_backend_id

  host_rule {
    hosts        = [var.primary_domain, local.www_host]
    path_matcher = "web"
  }
  path_matcher {
    name            = "web"
    default_service = var.web_backend_id
  }

  host_rule {
    hosts        = [local.bot_host]
    path_matcher = "bot"
  }
  path_matcher {
    name            = "bot"
    default_service = var.bot_backend_id
  }

  host_rule {
    hosts        = [var.secondary_domain]
    path_matcher = "ocpp"
  }
  path_matcher {
    name            = "ocpp"
    default_service = var.ocpp_backend_bucket_id
  }

  dynamic "host_rule" {
    for_each = var.enable_jenkins ? [1] : []
    content {
      hosts        = [local.jenkins_host]
      path_matcher = "jenkins"
    }
  }
  dynamic "path_matcher" {
    for_each = var.enable_jenkins ? [1] : []
    content {
      name            = "jenkins"
      default_service = var.jenkins_backend_id
    }
  }
}

resource "google_compute_target_https_proxy" "lb" {
  project          = var.project_id
  name             = "tgops-lb-https"
  url_map          = google_compute_url_map.lb.id
  ssl_certificates = [google_compute_managed_ssl_certificate.lb.id]
}

resource "google_compute_global_forwarding_rule" "https" {
  project               = var.project_id
  name                  = "tgops-lb-fwd-https"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.lb.id
  port_range            = "443"
  target                = google_compute_target_https_proxy.lb.id
}

# редирект http на https
resource "google_compute_url_map" "redirect" {
  project = var.project_id
  name    = "tgops-lb-redirect"
  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "redirect" {
  project = var.project_id
  name    = "tgops-lb-http"
  url_map = google_compute_url_map.redirect.id
}

resource "google_compute_global_forwarding_rule" "http" {
  project               = var.project_id
  name                  = "tgops-lb-fwd-http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.lb.id
  port_range            = "80"
  target                = google_compute_target_http_proxy.redirect.id
}

# dns записи на ip lb
resource "google_dns_record_set" "primary" {
  for_each     = toset([var.primary_domain, local.www_host, local.bot_host])
  project      = var.project_id
  managed_zone = var.primary_zone_name
  name         = "${each.value}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.lb.address]
}

resource "google_dns_record_set" "jenkins" {
  count        = var.enable_jenkins ? 1 : 0
  project      = var.project_id
  managed_zone = var.primary_zone_name
  name         = "${local.jenkins_host}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.lb.address]
}

resource "google_dns_record_set" "ocpp" {
  project      = var.project_id
  managed_zone = var.secondary_zone_name
  name         = "${var.secondary_domain}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.lb.address]
}
