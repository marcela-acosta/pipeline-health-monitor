# Pipeline Health Monitor

Infrastructure-as-code and tooling to monitor the health of our data/CI pipelines from a shared GCP virtual machine.

## Overview

This repository contains the Terraform configuration that provisions a shared Google Cloud Platform (GCP) Compute Engine VM used by the team to run and monitor pipeline health checks. Access is managed through GCP IAM + OS Login, and connectivity is handled through Identity-Aware Proxy (IAP) — no public SSH port is exposed.

## Repository layout

```
.
├── README.md           # This file
├── .gitignore          # Terraform / credentials ignore rules
└── shared_vm.tf        # Terraform: VM + IAM for 5 team members
```

## Prerequisites

- Terraform >= 1.5
- Google Cloud SDK (`gcloud`)
- A GCP project with billing enabled
- Owner or IAM Admin permissions on that project (to apply IAM bindings)

## One-time setup

```bash
gcloud auth application-default login
gcloud config set project <your-project-id>

gcloud services enable \
  compute.googleapis.com \
  iap.googleapis.com \
  oslogin.googleapis.com
```

## Deploy the VM

```bash
terraform init
terraform plan
terraform apply
```

## Connect to the VM

Every team member runs:

```bash
gcloud compute ssh team-vm \
  --zone us-central1-a \
  --tunnel-through-iap
```

## Access model

All five team members receive:

- `roles/compute.osAdminLogin` — SSH into the VM with sudo
- `roles/compute.instanceAdmin.v1` — start / stop / edit the VM
- `roles/iap.tunnelResourceAccessor` — connect through IAP (no public SSH)
- `roles/iam.serviceAccountUser` — use the VM's service account

To add or remove a member, edit the `locals.users` list in `shared_vm.tf` and run `terraform apply`.

## Remote state (recommended for teams)

Once everyone is collaborating, move the Terraform state to a GCS bucket so the team shares a single source of truth. See the `backend "gcs"` block commented at the top of `shared_vm.tf` (to be added).
