output "project_id" {
  value = var.project_id
}

output "project_number" {
  value = data.google_project.this.number
}

output "state_bucket" {
  description = "имя бакета, которое нужно подставить в backend.hcl"
  value       = google_storage_bucket.tf_state.name
}

output "db_export_bucket" {
  value = google_storage_bucket.db_export.name
}

output "tf_runner_sa" {
  value = google_service_account.tf_runner.email
}

output "gha_ci_sa" {
  value = google_service_account.gha_ci.email
}

output "wif_provider" {
  description = "resource name wif провайдера, в github secrets как WIF_PROVIDER"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "github_secrets_hint" {
  description = "секрет для github actions secrets"
  value = {
    WIF_PROVIDER        = google_iam_workload_identity_pool_provider.github.name
    WIF_SERVICE_ACCOUNT = google_service_account.gha_ci.email
    GCP_PROJECT_ID      = var.project_id
  }
}
