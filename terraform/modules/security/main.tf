
resource "google_service_account" "bot" {
  project      = var.project_id
  account_id   = "bot-runtime"
  display_name = "tgops bot runtime"
}

resource "google_service_account" "jenkins" {
  project      = var.project_id
  account_id   = "jenkins-runtime"
  display_name = "tgops jenkins runtime"
}

resource "google_service_account" "mon" {
  project      = var.project_id
  account_id   = "mon-runtime"
  display_name = "tgops monitoring runtime"
}

locals {
  bot_roles = [
    "roles/secretmanager.secretAccessor",
    "roles/cloudsql.client",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader",
  ]
  jenkins_roles = [
    "roles/artifactregistry.reader",
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/compute.viewer",
    # для деплоя бота: ssh на bot-vm через iap туннель и osAdminLogin
    "roles/iap.tunnelResourceAccessor",
    "roles/compute.osAdminLogin",
  ]
  mon_roles = [
    "roles/monitoring.viewer",
    "roles/logging.viewer",
    "roles/logging.logWriter",
  ]
}

resource "google_project_iam_member" "bot" {
  for_each = toset(local.bot_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.bot.email}"
}

resource "google_project_iam_member" "jenkins" {
  for_each = toset(local.jenkins_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.jenkins.email}"
}

resource "google_project_iam_member" "mon" {
  for_each = toset(local.mon_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.mon.email}"
}

# контейнеры секретов, значения кладём руками через gcloud
resource "google_secret_manager_secret" "this" {
  for_each  = toset(var.secrets)
  project   = var.project_id
  secret_id = each.value
  replication {
    auto {}
  }
}

# доступ бота к своим секретам
resource "google_secret_manager_secret_iam_member" "bot" {
  for_each  = google_secret_manager_secret.this
  project   = var.project_id
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.bot.email}"
}

# jenkins читает свой webhook секрет
resource "google_secret_manager_secret_iam_member" "jenkins" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.this["tgops-jenkins-webhook-secret"].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.jenkins.email}"
}
