# публичные зоны cloud dns, ns записи прописываются у регистратора руками
resource "google_dns_managed_zone" "primary" {
  project     = var.project_id
  name        = "tgops-primary"
  dns_name    = "${var.primary_domain}."
  description = "основной домен tgops"
  visibility  = "public"
}

resource "google_dns_managed_zone" "secondary" {
  project     = var.project_id
  name        = "tgops-secondary"
  dns_name    = "${var.secondary_domain}."
  description = "второй домен ocpp"
  visibility  = "public"
}
