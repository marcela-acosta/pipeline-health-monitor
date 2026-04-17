# ---------------------------------------------------------------------------
# Shared VM infrastructure — configuration and IAM
# Compute → compute.tf | Networking → networking.tf
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
# Secret Manager: GitHub deploy key (SSH private key)
# Populated by scripts/setup-deploy-key.sh; read by the VM on startup.
# ---------------------------------------------------------------------------
resource "google_secret_manager_secret" "github_deploy_key" {
  secret_id = "github-deploy-key"

  replication {
    auto {}
  }
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

# IAM: start, stop, reset, and edit the VM from GCP console or gcloud
resource "google_project_iam_member" "instance_admin" {
  for_each = toset(local.users)
  project  = local.project_id
  role     = "roles/compute.instanceAdmin.v1"
  member   = "user:${each.value}"
}

# IAM: connect through Identity-Aware Proxy
resource "google_project_iam_member" "iap_tunnel" {
  for_each = toset(local.users)
  project  = local.project_id
  role     = "roles/iap.tunnelResourceAccessor"
  member   = "user:${each.value}"
}

# IAM: attach or use the VM's service account via gcloud or console
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
  description = "Name of the shared VM"
  value       = google_compute_instance.shared_vm.name
}

output "vm_zone" {
  description = "Zone where the VM runs"
  value       = google_compute_instance.shared_vm.zone
}

output "ssh_command" {
  description = "gcloud command to SSH into the VM via IAP"
  value       = "gcloud compute ssh ${google_compute_instance.shared_vm.name} --zone ${google_compute_instance.shared_vm.zone} --tunnel-through-iap"
}

output "airflow_tunnel_command" {
  description = "Run locally to open Airflow UI at http://localhost:8080"
  value       = "gcloud compute start-iap-tunnel ${google_compute_instance.shared_vm.name} 8080 --local-host-port=localhost:8080 --zone=${google_compute_instance.shared_vm.zone}"
}
