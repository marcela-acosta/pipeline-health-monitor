# ---------------------------------------------------------------------------
# Shared VM on GCP with full access for 5 users
# ---------------------------------------------------------------------------
# This configuration creates a Compute Engine instance and grants full
# administrative access (both inside the VM and over the VM resource in GCP)
# to a list of 5 users. Authentication to the VM uses OS Login, and
# connectivity uses Identity-Aware Proxy (IAP) so no public SSH port is
# exposed to the internet.
# ---------------------------------------------------------------------------

provider "google" {
  project = "pipeline-health-mon-2026"
  region  = "us-central1"
  zone    = "us-central1-a"
}

# ---------------------------------------------------------------------------
# Compute Engine instance
# ---------------------------------------------------------------------------
resource "google_compute_instance" "shared_vm" {
  name         = "team-vm"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"

    # Public IP is optional when using IAP. Remove this block if you want
    # the VM to be fully private (recommended for production).
    access_config {}
  }

  # Enable OS Login so Google identities are mapped to Linux users
  # automatically. No manual user creation or SSH key management needed.
  metadata = {
    enable-oslogin = "TRUE"
  }
}

# ---------------------------------------------------------------------------
# List of users that will have full access
# ---------------------------------------------------------------------------
locals {
  users = [
    "marcelacostoff@gmail.com",
    "jsteven.romeror@gmail.com",
    "rey.raguilar@gmail.com",
    "jcardona1983@gmail.com",
    "adrianperezj@gmail.com",
  ]
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
  project  = "pipeline-health-mon-2026"
  role     = "roles/compute.instanceAdmin.v1"
  member   = "user:${each.value}"
}

# ---------------------------------------------------------------------------
# IAM: Connect through Identity-Aware Proxy (no exposed SSH port required)
# ---------------------------------------------------------------------------
resource "google_project_iam_member" "iap_tunnel" {
  for_each = toset(local.users)
  project  = "pipeline-health-mon-2026"
  role     = "roles/iap.tunnelResourceAccessor"
  member   = "user:${each.value}"
}

# ---------------------------------------------------------------------------
# IAM: Required to attach or use the VM's service account via gcloud/console
# ---------------------------------------------------------------------------
resource "google_project_iam_member" "service_account_user" {
  for_each = toset(local.users)
  project  = "pipeline-health-mon-2026"
  role     = "roles/iam.serviceAccountUser"
  member   = "user:${each.value}"
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------
output "vm_name" {
  value       = google_compute_instance.shared_vm.name
  description = "Name of the shared VM"
}

output "vm_zone" {
  value       = google_compute_instance.shared_vm.zone
  description = "Zone where the shared VM is deployed"
}

output "ssh_command" {
  value       = "gcloud compute ssh ${google_compute_instance.shared_vm.name} --zone ${google_compute_instance.shared_vm.zone} --tunnel-through-iap"
  description = "Command each user runs to connect to the VM"
}