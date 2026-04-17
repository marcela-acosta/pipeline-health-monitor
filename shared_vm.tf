# ---------------------------------------------------------------------------
# Shared VM on GCP with full access for 5 users
# ---------------------------------------------------------------------------
# This configuration creates a Compute Engine instance that:
#   - Has OS Login enabled (Google identities map to Linux users)
#   - Runs a startup script that installs Docker and boots Airflow
#   - Pulls the project from a private GitHub repo via a deploy key
#     stored in Google Secret Manager
# Access to the VM is managed via IAM + IAP (no public SSH).
# ---------------------------------------------------------------------------

locals {
  project_id = "pipeline-health-mon-2026"
  region     = "us-central1"
  zone       = "us-central1-a"

  users = [
    "marcelacostoff@gmail.com",
    "jsteven.romeror@gmail.com",
    "rey.raguilar@gmail.com",
    "jcardona1983@gmail.com",
    "adrianperezj@gmail.com",
  ]
}

provider "google" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}

# ---------------------------------------------------------------------------
# Secret Manager: GitHub deploy key (SSH private key) used by the VM
# to clone the private repo during startup.
# The secret itself is populated by scripts/setup-deploy-key.sh
# ---------------------------------------------------------------------------
resource "google_secret_manager_secret" "github_deploy_key" {
  secret_id = "github-deploy-key"

  replication {
    auto {}
  }
}

# ---------------------------------------------------------------------------
# Compute Engine instance
# ---------------------------------------------------------------------------
resource "google_compute_instance" "shared_vm" {
  name         = "team-vm"
  machine_type = "e2-medium"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30 # GB — enough room for Docker images + Airflow data
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  # Default service account with the scopes needed to read secrets.
  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  # This script runs once when the VM first boots.
  metadata_startup_script = file("${path.module}/scripts/startup.sh")
}

# ---------------------------------------------------------------------------
# IAM: grant the VM's default service account read access to the secret
# ---------------------------------------------------------------------------
data "google_compute_default_service_account" "default" {}

resource "google_secret_manager_secret_iam_member" "vm_reads_secret" {
  secret_id = google_secret_manager_secret.github_deploy_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

# ---------------------------------------------------------------------------
# Firewall: allow IAP TCP forwarding to Airflow (port 8080)
# ---------------------------------------------------------------------------
resource "google_compute_firewall" "allow_iap_airflow" {
  name    = "allow-iap-airflow"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  # IAP's reserved source range for TCP forwarding
  source_ranges = ["35.235.240.0/20"]
}

# ---------------------------------------------------------------------------
# IAM: SSH access with sudo privileges inside the VM
# ---------------------------------------------------------------------------
resource "google_compute_instance_iam_member" "os_admin" {
  for_each      = toset(local.users)
  project       = google_compute_instance.shared_vm.project
  zone          = google_compute_instance.shared_vm.zone
  instance_name = google_compute_instance.shared_vm.name
  role          = "roles/compute.osAdminLogin"
  member        = "user:${each.value}"
}

# ---------------------------------------------------------------------------
# IAM: Ability to manage the VM from GCP (start, stop, reset, edit, etc.)
# ---------------------------------------------------------------------------
resource "google_project_iam_member" "instance_admin" {
  for_each = toset(local.users)
  project  = local.project_id
  role     = "roles/compute.instanceAdmin.v1"
  member   = "user:${each.value}"
}

# ---------------------------------------------------------------------------
# IAM: Connect through Identity-Aware Proxy
# ---------------------------------------------------------------------------
resource "google_project_iam_member" "iap_tunnel" {
  for_each = toset(local.users)
  project  = local.project_id
  role     = "roles/iap.tunnelResourceAccessor"
  member   = "user:${each.value}"
}

# ---------------------------------------------------------------------------
# IAM: Required to attach or use the VM's service account via gcloud/console
# ---------------------------------------------------------------------------
resource "google_project_iam_member" "service_account_user" {
  for_each = toset(local.users)
  project  = local.project_id
  role     = "roles/iam.serviceAccountUser"
  member   = "user:${each.value}"
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------
output "vm_name" {
  value = google_compute_instance.shared_vm.name
}

output "vm_zone" {
  value = google_compute_instance.shared_vm.zone
}

output "ssh_command" {
  value = "gcloud compute ssh ${google_compute_instance.shared_vm.name} --zone ${google_compute_instance.shared_vm.zone} --tunnel-through-iap"
}

output "airflow_tunnel_command" {
  value       = "gcloud compute start-iap-tunnel ${google_compute_instance.shared_vm.name} 8080 --local-host-port=localhost:8080 --zone=${google_compute_instance.shared_vm.zone}"
  description = "Run this locally, then open http://localhost:8080 to access Airflow"
}
