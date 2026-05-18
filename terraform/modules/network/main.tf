# vpc и одна подсеть
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "tgops-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "snet" {
  project                  = var.project_id
  name                     = "tgops-snet"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
}

# cloud router и nat, единственный выход приватных vm в интернет
resource "google_compute_router" "router" {
  project = var.project_id
  name    = "tgops-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  project                            = var.project_id
  name                               = "tgops-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# private service access для приватного ip cloud sql
resource "google_compute_global_address" "psa" {
  project       = var.project_id
  name          = "tgops-psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "psa" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa.name]
}

# firewall, по умолчанию всё закрыто, ниже точечные разрешения

# ssh только из диапазона iap
resource "google_compute_firewall" "iap_ssh" {
  project       = var.project_id
  name          = "fw-allow-iap-ssh"
  network       = google_compute_network.vpc.id
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# iap туннель к ui мониторинга (grafana 3000, prometheus 9090, alertmanager 9093)
resource "google_compute_firewall" "iap_mon_ui" {
  project       = var.project_id
  name          = "fw-allow-iap-mon-ui"
  network       = google_compute_network.vpc.id
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["monitoring"]
  allow {
    protocol = "tcp"
    ports    = ["3000", "9090", "9093"]
  }
}

# health check и lb до bot и jenkins
resource "google_compute_firewall" "lb_health" {
  project       = var.project_id
  name          = "fw-allow-lb-health"
  network       = google_compute_network.vpc.id
  direction     = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["bot", "jenkins"]
  allow {
    protocol = "tcp"
    ports    = ["8080", "8443", "8081"]
  }
}


resource "google_compute_firewall" "mon_scrape" {
  project     = var.project_id
  name        = "fw-allow-mon-scrape"
  network     = google_compute_network.vpc.id
  direction   = "INGRESS"
  source_tags = ["monitoring"]
  target_tags = ["bot", "jenkins", "monitoring", "demo"]
  allow {
    protocol = "tcp"
    ports    = ["9100", "8080", "9115", "9090"]
  }
}

# bot ходит к demo vm (ssh, icmp, http) по приватной сети
resource "google_compute_firewall" "bot_to_demo" {
  project     = var.project_id
  name        = "fw-allow-bot-to-demo"
  network     = google_compute_network.vpc.id
  direction   = "INGRESS"
  source_tags = ["bot"]
  target_tags = ["demo"]
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  allow { protocol = "icmp" }
}

# jenkins ходит к bot по ssh для деплоя (приватный ip)
resource "google_compute_firewall" "jenkins_to_bot" {
  project     = var.project_id
  name        = "fw-allow-jenkins-to-bot"
  network     = google_compute_network.vpc.id
  direction   = "INGRESS"
  source_tags = ["jenkins"]
  target_tags = ["bot"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# внутренний icmp и dns
resource "google_compute_firewall" "internal" {
  project       = var.project_id
  name          = "fw-allow-internal"
  network       = google_compute_network.vpc.id
  direction     = "INGRESS"
  source_ranges = [var.subnet_cidr]
  allow { protocol = "icmp" }
  allow {
    protocol = "udp"
    ports    = ["53"]
  }
}
