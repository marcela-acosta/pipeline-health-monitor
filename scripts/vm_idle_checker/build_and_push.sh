#!/bin/bash
# Build and push the vm-idle-checker image to Artifact Registry.
# Run this once before `terraform apply`, and again on any code change.

set -euo pipefail

PROJECT_ID="pipeline-health-mon-2026"
REGION="us-central1"
REPO="vm-idle-checker"
IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/checker:latest"

echo "Configuring Docker auth for Artifact Registry..."
gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

echo "Building image: ${IMAGE}"
docker build -t "${IMAGE}" "$(dirname "$0")"

echo "Pushing image: ${IMAGE}"
docker push "${IMAGE}"

echo "Done. Image available at: ${IMAGE}"
