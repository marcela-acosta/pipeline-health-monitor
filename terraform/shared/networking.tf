# ---------------------------------------------------------------------------
# Networking: firewall rules for IAP access
# All SSH and tunnel traffic enters through Identity-Aware Proxy only —
# no direct public access to the VM.
# ---------------------------------------------------------------------------

# IAP source range for TCP forwarding (Google-managed, does not change)
locals {
  iap_cidr = "35.235.240.0/20"
}

# Allow SSH (port 22) via IAP tunnel
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [local.iap_cidr]
  target_tags   = []

  description = "Allow SSH only from IAP — blocks direct public SSH"
}

# Allow access to Airflow UI (port 8080) via IAP tunnel
resource "google_compute_firewall" "allow_iap_airflow" {
  name    = "allow-iap-airflow"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = [local.iap_cidr]

  description = "Allow Airflow web UI tunneled through IAP"
}
