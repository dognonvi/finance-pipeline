# outputs.tf
# ─────────────────────────────────────────────
# Informations affichées après terraform apply

output "bucket_url" {
  description = "URL du bucket GCS créé"
  value       = google_storage_bucket.finance_bucket.url
}

output "bucket_name" {
  description = "Nom du bucket GCS"
  value       = google_storage_bucket.finance_bucket.name
}

output "service_account_email" {
  description = "Email du service account créé"
  value       = google_service_account.pipeline_sa.email
}

output "dataset_raw" {
  description = "ID du dataset BigQuery raw"
  value       = google_bigquery_dataset.raw.dataset_id
}

output "dataset_dev" {
  description = "ID du dataset BigQuery dev"
  value       = google_bigquery_dataset.dev_finance.dataset_id
}

output "dataset_prod" {
  description = "ID du dataset BigQuery prod"
  value       = google_bigquery_dataset.prod_finance.dataset_id
}
