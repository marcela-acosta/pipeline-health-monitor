# ---------------------------------------------------------------------------
# Compute Engine: shared VM for the 5-person team
# ---------------------------------------------------------------------------

data "google_compute_default_service_account" "default" {}

resource "google_compute_instance" "shared_vm" {
  name         = "team-vm"
  machine_type = "e2-medium"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  # Default service account with scopes needed to read secrets and call GCP APIs.
  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = file("${path.module}/../../scripts/startup.sh")
}

# Grant the VM's default service account read access to the GitHub deploy key secret.
resource "google_secret_manager_secret_iam_member" "vm_reads_secret" {
  secret_id = google_secret_manager_secret.github_deploy_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}
