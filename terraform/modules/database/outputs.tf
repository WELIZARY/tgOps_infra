output "instance_name" {
  value = google_sql_database_instance.primary.name
}

output "connection_name" {
  value = google_sql_database_instance.primary.connection_name
}

output "private_ip" {
  value = google_sql_database_instance.primary.private_ip_address
}

output "replica_private_ip" {
  description = "приватный ip реплики, пусто если реплика выключена"
  value       = var.enable_read_replica ? google_sql_database_instance.replica[0].private_ip_address : ""
}

output "db_name" {
  value = google_sql_database.db.name
}

output "db_user" {
  value = google_sql_user.user.name
}

output "password_secret_id" {
  value = google_secret_manager_secret.db_password.secret_id
}
