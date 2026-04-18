# ---------------------------------------------------------------------------
# VM Idle Checker — Cloud Run Job + Cloud Scheduler
#
# Every 30 minutes Cloud Scheduler triggers a Cloud Run Job that:
#   1. Checks if team-vm is RUNNING
#   2. Queries average CPU over the last 60 minutes
#   3. Stops the VM if CPU < 5% (idle threshold)
#
# To deploy for the first time:
#   1. terraform apply   (creates Artifact Registry repo + all infra)
#   2. scripts/vm_idle_checker/build_and_push.sh   (builds & pushes image)
#   3. terraform apply   (no-op, image is now available)
# ---------------------------------------------------------------------------

# ── APIs ─────────────────────────────────────────────────────────────────────
resource "google_project_service" "run_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "scheduler_api" {
  service            = "cloudscheduler.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifact_registry_api" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# ── Artifact Registry repo ───────────────────────────────────────────────────
resource "google_artifact_registry_repository" "vm_checker" {
  location      = local.region
  repository_id = "vm-idle-checker"
  format        = "DOCKER"

  depends_on = [google_project_service.artifact_registry_api]
}

# ── Service Account for the Cloud Run Job ────────────────────────────────────
resource "google_service_account" "vm_checker_sa" {
  account_id   = "vm-idle-checker-sa"
  display_name = "VM Idle Checker SA"
}

resource "google_project_iam_member" "vm_checker_compute" {
  project = local.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.vm_checker_sa.email}"
}

resource "google_project_iam_member" "vm_checker_monitoring" {
  project = local.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.vm_checker_sa.email}"
}

# ── Cloud Run Job ─────────────────────────────────────────────────────────────
locals {
  checker_image = "${local.region}-docker.pkg.dev/${local.project_id}/vm-idle-checker/checker:latest"

  # How often to check (cron) and idle parameters
  check_schedule        = "*/30 * * * *"   # every 30 minutes
  idle_threshold_minutes = "60"             # minutes of low CPU before shutdown
  cpu_threshold_percent  = "5"             # % below which VM is considered idle
}

resource "google_cloud_run_v2_job" "vm_idle_checker" {
  name                = "vm-idle-checker"
  location            = local.region
  deletion_protection = false

  template {
    template {
      service_account = google_service_account.vm_checker_sa.email

      containers {
        image = local.checker_image

        env {
          name  = "PROJECT_ID"
          value = local.project_id
        }
        env {
          name  = "ZONE"
          value = local.zone
        }
        env {
          name  = "VM_NAME"
          value = google_compute_instance.shared_vm.name
        }
        env {
          name  = "IDLE_THRESHOLD_MINUTES"
          value = local.idle_threshold_minutes
        }
        env {
          name  = "CPU_THRESHOLD_PERCENT"
          value = local.cpu_threshold_percent
        }
      }
    }
  }

  depends_on = [
    google_project_service.run_api,
    google_artifact_registry_repository.vm_checker,
  ]
}

# ── Service Account for Cloud Scheduler ──────────────────────────────────────
resource "google_service_account" "scheduler_sa" {
  account_id   = "vm-checker-scheduler-sa"
  display_name = "VM Checker Scheduler SA"
}

resource "google_project_iam_member" "scheduler_run_invoker" {
  project = local.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.scheduler_sa.email}"
}

# ── Cloud Scheduler ───────────────────────────────────────────────────────────
data "google_project" "project" {}

resource "google_cloud_scheduler_job" "vm_idle_check" {
  name      = "vm-idle-check"
  region    = local.region
  schedule  = local.check_schedule
  time_zone = "America/Bogota"

  http_target {
    http_method = "POST"
    uri = join("/", [
      "https://run.googleapis.com/v2/projects",
      local.project_id,
      "locations",
      local.region,
      "jobs",
      "${google_cloud_run_v2_job.vm_idle_checker.name}:run",
    ])

    oauth_token {
      service_account_email = google_service_account.scheduler_sa.email
    }
  }

  depends_on = [
    google_project_service.scheduler_api,
    google_cloud_run_v2_job.vm_idle_checker,
  ]
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "checker_image" {
  description = "Full image path — build and push this before terraform apply"
  value       = local.checker_image
}

output "scheduler_schedule" {
  description = "Cron expression used by Cloud Scheduler"
  value       = local.check_schedule
}
