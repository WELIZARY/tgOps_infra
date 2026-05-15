# vm jenkins controller, конфигурацию ставит ansible (jcasc, docker, тулинг)

# отдельный диск под jenkins_home, переживает пересоздание vm
resource "google_compute_disk" "data" {
  project = var.project_id
  name    = "tgops-jenkins-data"
  zone    = var.zone
  type    = "pd-balanced"
  size    = 30

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_instance" "jenkins" {
  project      = var.project_id
  name         = "tgops-jenkins-vm"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["jenkins"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
      type  = "pd-balanced"
    }
  }

  attached_disk {
    source      = google_compute_disk.data.id
    device_name = "jenkins-data"
  }

  network_interface {
    subnetwork = var.subnet_self_link
  }

  service_account {
    email  = var.jenkins_sa_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
    startup-script = <<-EOT
      #!/bin/bash
      set -e
      apt-get update -y
      apt-get install -y python3 ca-certificates curl
    EOT
  }

  allow_stopping_for_update = true
}

# cloud armor, пускаем к ui только свои ip
# на триале квота armor = 0, поэтому опционально выключаю от греха подальше
resource "google_compute_security_policy" "jenkins" {
  count   = var.enable_armor ? 1 : 0
  project = var.project_id
  name    = "tgops-jenkins-armor"

  rule {
    action   = "allow"
    priority = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = length(var.allow_ips) > 0 ? var.allow_ips : ["0.0.0.0/0"]
      }
    }
    description = "allowlist ip для ui jenkins"
  }

  rule {
    action   = length(var.allow_ips) > 0 ? "deny(403)" : "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
}

resource "google_compute_network_endpoint_group" "jenkins" {
  project               = var.project_id
  name                  = "tgops-jenkins-neg"
  network_endpoint_type = "GCE_VM_IP_PORT"
  zone                  = var.zone
  default_port          = var.jenkins_port
  network               = var.network_self_link
  subnetwork            = var.subnet_self_link
}

resource "google_compute_network_endpoint" "jenkins" {
  project                = var.project_id
  network_endpoint_group = google_compute_network_endpoint_group.jenkins.name
  zone                   = var.zone
  instance               = google_compute_instance.jenkins.name
  ip_address             = google_compute_instance.jenkins.network_interface[0].network_ip
  port                   = var.jenkins_port
}

resource "google_compute_health_check" "jenkins" {
  project = var.project_id
  name    = "tgops-jenkins-hc"
  http_health_check {
    port         = var.jenkins_port
    request_path = "/login"
  }
  check_interval_sec  = 15
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 5
}

resource "google_compute_backend_service" "jenkins" {
  project               = var.project_id
  name                  = "tgops-jenkins-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 60
  security_policy       = var.enable_armor ? google_compute_security_policy.jenkins[0].id : null
  health_checks         = [google_compute_health_check.jenkins.id]

  backend {
    group                 = google_compute_network_endpoint_group.jenkins.id
    balancing_mode        = "RATE"
    max_rate_per_endpoint = 50
  }
}
