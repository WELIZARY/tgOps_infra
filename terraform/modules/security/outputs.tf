output "bot_sa_email" {
  value = google_service_account.bot.email
}

output "jenkins_sa_email" {
  value = google_service_account.jenkins.email
}

output "mon_sa_email" {
  value = google_service_account.mon.email
}

output "secret_ids" {
  description = "id созданных секретов, значения руками добавляется"
  value       = { for k, s in google_secret_manager_secret.this : k => s.secret_id }
}
