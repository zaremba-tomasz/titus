resource "google_cloud_run_service_iam_member" "backend_noauth" {
  location = google_cloud_run_service.backend.location
  service  = google_cloud_run_service.backend.name
  role = "roles/run.invoker"
  member = "allUsers"
}

resource "google_cloud_run_service" "backend" {
  name     = "titus-backend"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
        ports {
          container_port = "8080"
        }
        env {
          name  = "API_HOST"
          value = "0.0.0.0"
        }
        env {
          name  = "API_PORT"
          value = "8080"
        }
        env {
          name  = "CORS_ORIGIN"
          value = google_cloud_run_service.frontend.status.0.url
        }
        env {
          name  = "PG_HOST"
          value = "/cloudsql/${var.gcp_project_id}:${var.region}:${google_sql_database_instance.main.name}"
        }
        env {
          name  = "PG_PORT"
          value = "5432"
        }
        env {
          name  = "PG_DB"
          value = var.cloudsql_db_name
        }
        env {
          name  = "PG_USER"
          value = var.cloudsql_db_user
        }
        env {
          name  = "PG_PASS"
          value = random_password.db_password.result
        }
        env {
          name  = "JWT_SECRET"
          value = "1234abcd"
        }
        env {
          name  = "NODE_ENV"
          value = "production"
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "1000"
        "run.googleapis.com/cloudsql-instances" = "${var.gcp_project_id}:${var.region}:${google_sql_database_instance.main.name}"
        "run.googleapis.com/client-name"        = "cloud-console"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  autogenerate_revision_name = true

  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].spec[0].service_account_name,
      template[0].metadata[0].annotations
    ]
  }
}