output "pubsub_topic" {
  value = google_pubsub_topic.crm_events.id
}

output "sa_email" {
  value = google_service_account.pipeline_sa.email
}

output "bq_datasets" {
  value = [
    google_bigquery_dataset.bronze.dataset_id,
    google_bigquery_dataset.silver.dataset_id,
    google_bigquery_dataset.gold.dataset_id,
  ]
}

output "gcs_buckets" {
  value = [
    google_storage_bucket.bronze.name,
    google_storage_bucket.silver.name,
    google_storage_bucket.gold.name,
  ]
}
