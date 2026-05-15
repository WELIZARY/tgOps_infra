data "google_project" "this" {
  project_id = var.project_id
}

#необходимые для работы api
locals {
  apis = [
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "dns.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "iam.googleapis.com",
    "sts.googleapis.com",
    "certificatemanager.googleapis.com",
    "iap.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "servicenetworking.googleapis.com",
  ]
}

resource "google_project_service" "apis" {
  for_each                   = toset(local.apis)
  project                    = var.project_id
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = false
}

# бакет под terraform rs
resource "google_storage_bucket" "tf_state" {
  name                        = var.state_bucket_name
  project                     = var.project_id
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning { enabled = true }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.apis]
}

# бакет под dr (экспорт бд)
resource "google_storage_bucket" "db_export" {
  name                        = var.db_export_bucket_name
  project                     = var.project_id
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning { enabled = true }

  # срок хранения дампов 30 дней
  lifecycle_rule {
    condition { age = 30 }
    action { type = "Delete" }
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.apis]
}

# SA для terraform apply
resource "google_service_account" "tf_runner" {
  project      = var.project_id
  account_id   = "tf-runner"
  display_name = "terraform runner (tgops)"
  depends_on   = [google_project_service.apis]
}

locals {
  tf_runner_roles = [
    "roles/compute.admin",
    "roles/cloudsql.admin",
    "roles/dns.admin",
    "roles/run.admin",
    "roles/artifactregistry.admin",
    "roles/secretmanager.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.admin",
    "roles/certificatemanager.editor",
    "roles/monitoring.admin",
    "roles/iap.admin",
    "roles/servicenetworking.networksAdmin",
  ]
}

resource "google_project_iam_member" "tf_runner" {
  for_each = toset(local.tf_runner_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.tf_runner.email}"
}

# SA для github actions ci
resource "google_service_account" "gha_ci" {
  project      = var.project_id
  account_id   = "gha-ci"
  display_name = "github actions ci (пуш образа)"
  depends_on   = [google_project_service.apis]
}

resource "google_project_iam_member" "gha_ci_ar" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.gha_ci.email}"
}

# workload identity federation для github actions
resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "github actions pool"
  depends_on                = [google_project_service.apis]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc"
  display_name                       = "github oidc"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # только репа нужного владельца
  attribute_condition = "assertion.repository_owner == \"${var.github_owner}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# список разрешенных репо
resource "google_service_account_iam_member" "gha_wif" {
  for_each           = toset(var.github_repos)
  service_account_id = google_service_account.gha_ci.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${each.value}"
}