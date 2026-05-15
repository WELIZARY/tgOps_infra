# vm мониторинга, стек ставит ansible (prometheus loki grafana alertmanager blackbox)

# диск под tsdb и логи, переживает пересоздание vm
resource "google_compute_disk" "data" {
  project = var.project_id
  name    = "tgops-mon-data"
  zone    = var.zone
  type    = "pd-balanced"
  size    = 30

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_instance" "mon" {
  project      = var.project_id
  name         = "tgops-mon-vm"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["monitoring"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
      type  = "pd-balanced"
    }
  }

  attached_disk {
    source      = google_compute_disk.data.id
    device_name = "mon-data"
  }

  network_interface {
    subnetwork = var.subnet_self_link
  }

  service_account {
    email  = var.mon_sa_email
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
