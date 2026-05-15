# одна vm под бота
resource "google_compute_address" "internal" {
  project      = var.project_id
  name         = "tgops-bot-ip"
  subnetwork   = var.subnet_self_link
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_instance" "bot" {
  project      = var.project_id
  name         = "tgops-bot-vm"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["bot"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = var.subnet_self_link
    network_ip = google_compute_address.internal.address
    # без external ip, наружу через nat, внутрь через lb и iap
  }

  service_account {
    email  = var.bot_sa_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
    # минимальный bootstrap, остальное ставит ansible
    startup-script = <<-EOT
      #!/bin/bash
      set -e
      apt-get update -y
      apt-get install -y python3 ca-certificates curl
    EOT
  }

  # пересоздание vm не должно ронять рантайм без нужды
  allow_stopping_for_update = true
}

# бэкенд для общего lb (host rule bot.tgops.xyz)
resource "google_compute_network_endpoint_group" "bot" {
  project               = var.project_id
  name                  = "tgops-bot-neg"
  network_endpoint_type = "GCE_VM_IP_PORT"
  zone                  = var.zone
  default_port          = var.webhook_port
  network               = var.network_self_link
  subnetwork            = var.subnet_self_link
}

resource "google_compute_network_endpoint" "bot" {
  project                = var.project_id
  network_endpoint_group = google_compute_network_endpoint_group.bot.name
  zone                   = var.zone
  instance               = google_compute_instance.bot.name
  ip_address             = google_compute_address.internal.address
  port                   = var.webhook_port
}

resource "google_compute_health_check" "bot" {
  project = var.project_id
  name    = "tgops-bot-hc"
  http_health_check {
    port         = var.webhook_port
    request_path = "/healthz"
  }
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}

resource "google_compute_backend_service" "bot" {
  project               = var.project_id
  name                  = "tgops-bot-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.bot.id]

  backend {
    group                 = google_compute_network_endpoint_group.bot.id
    balancing_mode        = "RATE"
    max_rate_per_endpoint = 100
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}
