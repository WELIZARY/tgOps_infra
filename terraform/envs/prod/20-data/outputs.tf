output "connection_name" { value = module.database.connection_name }
output "private_ip" { value = module.database.private_ip }
output "replica_private_ip" { value = module.database.replica_private_ip }
output "db_name" { value = module.database.db_name }
output "db_user" { value = module.database.db_user }
output "password_secret_id" { value = module.database.password_secret_id }
