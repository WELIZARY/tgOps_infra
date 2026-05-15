# статика ocpp.by в gcs, раздаётся через cloud cdn 
resource "google_storage_bucket" "site" {
  name                        = var.bucket_name
  project                     = var.project_id
  location                    = var.location
  uniform_bucket_level_access = true
  force_destroy               = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}

# содержимое читают все, бакет только под этот статик сайт
resource "google_storage_bucket_iam_member" "public" {
  bucket = google_storage_bucket.site.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_object" "index" {
  name         = "index.html"
  bucket       = google_storage_bucket.site.name
  content_type = "text/html; charset=utf-8"
  content      = <<-HTML
    <!doctype html>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>ocpp.by</title>
      <style>
        body{margin:0;min-height:100vh;display:flex;align-items:center;justify-content:center;
             font-family:system-ui,Segoe UI,Roboto,sans-serif;
             background:radial-gradient(circle at 30% 30%,#1b2735,#090a0f);color:#e8eef5}
        .card{text-align:center;padding:48px 64px;border:1px solid #2a3a4d;border-radius:18px;
              background:rgba(255,255,255,.03);backdrop-filter:blur(6px)}
        h1{margin:0 0 8px;font-size:42px;letter-spacing:1px}
        p{margin:6px 0;color:#9fb3c8}
        .dot{display:inline-block;width:10px;height:10px;border-radius:50%;
             background:#3ddc84;margin-right:8px;box-shadow:0 0 10px #3ddc84}
      </style>
    </head>
    <body>
      <div class="card">
        <h1>ocpp.by</h1>
        <p><span class="dot"></span>service is up</p>
        <p>served from gcs and cloud cdn edge</p>
        <p>tgops demo platform</p>
      </div>
    </body>
    </html>
  HTML
}

resource "google_compute_backend_bucket" "site" {
  project     = var.project_id
  name        = "tgops-ocpp-backend"
  bucket_name = google_storage_bucket.site.name
  enable_cdn  = true
  cdn_policy {
    cache_mode  = "CACHE_ALL_STATIC"
    default_ttl = 3600
    client_ttl  = 3600
    max_ttl     = 86400
  }
}
