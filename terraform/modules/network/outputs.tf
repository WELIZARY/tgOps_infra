output "vpc_id" { value = google_compute_network.vpc.id }
output "vpc_self_link" { value = google_compute_network.vpc.self_link }
output "vpc_name" { value = google_compute_network.vpc.name }
output "subnet_id" { value = google_compute_subnetwork.snet.id }
output "subnet_self_link" { value = google_compute_subnetwork.snet.self_link }
output "subnet_cidr" { value = var.subnet_cidr }
output "psa_connection" { value = google_service_networking_connection.psa.id }
