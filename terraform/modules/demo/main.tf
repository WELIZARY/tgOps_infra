# управляемые ботом demo ноды, на них будут сценарии работы боты

resource "google_compute_instance" "node" {
  for_each     = toset(var.nodes)
  project      = var.project_id
  name         = "tgops-${each.value}"
  machine_type = lookup(var.machine_type_overrides, each.value, var.machine_type)
  zone         = var.zone
  tags         = ["demo"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 15
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = var.subnet_self_link
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
