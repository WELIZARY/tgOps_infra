
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

# управляемая пара ключей для деплоя jenkins на bot-vm (без os login)
# приватный читает jenkins при деплое, публичный кладёт ansible в authorized_keys
resource "tls_private_key" "deploy" {
  algorithm = "ED25519"
}

resource "google_secret_manager_secret" "deploy_key" {
  project   = var.project_id
  secret_id = "tgops-deploy-ssh-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "deploy_key" {
  secret      = google_secret_manager_secret.deploy_key.id
  secret_data = tls_private_key.deploy.private_key_openssh
}

resource "google_secret_manager_secret" "deploy_pub" {
  project   = var.project_id
  secret_id = "tgops-deploy-ssh-pub"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "deploy_pub" {
  secret      = google_secret_manager_secret.deploy_pub.id
  secret_data = tls_private_key.deploy.public_key_openssh
}

# приватный ключ читает только jenkins
resource "google_secret_manager_secret_iam_member" "jenkins_deploy_key" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.deploy_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.jenkins.email}"
}

# публичный ключ читает бот (ansible на bot-vm под bot-runtime)
resource "google_secret_manager_secret_iam_member" "bot_deploy_pub" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.deploy_pub.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.bot.email}"
}

# отдельная пара ключей, которой бот ходит по ssh на demo-ноды
resource "tls_private_key" "bot_ssh" {
  algorithm = "ED25519"
}

resource "google_secret_manager_secret" "bot_ssh_key" {
  project   = var.project_id
  secret_id = "tgops-bot-ssh-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "bot_ssh_key" {
  secret      = google_secret_manager_secret.bot_ssh_key.id
  secret_data = tls_private_key.bot_ssh.private_key_openssh
}

resource "google_secret_manager_secret" "bot_ssh_pub" {
  project   = var.project_id
  secret_id = "tgops-bot-ssh-pub"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "bot_ssh_pub" {
  secret      = google_secret_manager_secret.bot_ssh_pub.id
  secret_data = tls_private_key.bot_ssh.public_key_openssh
}

resource "google_secret_manager_secret_iam_member" "bot_ssh_key" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.bot_ssh_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.bot.email}"
}
