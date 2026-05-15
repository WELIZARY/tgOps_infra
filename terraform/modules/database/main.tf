# пароль генерируем, в репозитории его нет, лежит только в secret manager
resource "random_password" "db" {
  length  = 28
  special = false
}

resource "random_id" "suffix" {
  byte_length = 3
}

resource "google_sql_database_instance" "primary" {
  project             = var.project_id
  name                = "tgops-pg-${random_id.suffix.hex}"
  region              = var.region
  database_version    = "POSTGRES_16"
  deletion_protection = false

  settings {
    tier              = var.tier
    availability_type = var.enable_ha ? "REGIONAL" : "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = 10
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_self_link
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "02:00"
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 7
      }
    }

    insights_config {
      query_insights_enabled = true
    }
  }

}

# read replica, поднимается опционально
resource "google_sql_database_instance" "replica" {
  count                = var.enable_read_replica ? 1 : 0
  project              = var.project_id
  name                 = "tgops-pg-replica-${random_id.suffix.hex}"
  region               = var.region
  database_version     = "POSTGRES_16"
  master_instance_name = google_sql_database_instance.primary.name
  deletion_protection  = false

  settings {
    tier              = var.tier
    availability_type = "ZONAL"
    disk_type         = "PD_SSD"

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_self_link
      ssl_mode        = "ENCRYPTED_ONLY"
    }
  }
}

resource "google_sql_database" "db" {
  project  = var.project_id
  name     = var.db_name
  instance = google_sql_database_instance.primary.name
}

resource "google_sql_user" "user" {
  project  = var.project_id
  name     = var.db_user
  instance = google_sql_database_instance.primary.name
  password = random_password.db.result
}

# пароль и строка подключения в secret manager
resource "google_secret_manager_secret" "db_password" {
  project   = var.project_id
  secret_id = "tgops-db-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db.result
}

resource "google_secret_manager_secret_iam_member" "bot" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.bot_sa_email}"
}
