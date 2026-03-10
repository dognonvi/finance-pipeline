# main.tf

# ── BUCKET GCS ────────────────────────────────────────
resource "google_storage_bucket" "finance_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true        # permet de supprimer même si non vide

  uniform_bucket_level_access = true  # sécurité recommandée par GCP
}

# ── DATASETS BIGQUERY ─────────────────────────────────

# Dataset raw — données brutes ingestion
resource "google_bigquery_dataset" "raw" {
  dataset_id  = "raw"
  description = "Données brutes ingestion Python"
  location    = var.region
}

# Dataset dev_finance — DBT target dev
resource "google_bigquery_dataset" "dev_finance" {
  dataset_id  = "dev_finance"
  description = "DBT transformations environnement dev"
  location    = var.region
}

# Dataset prod_finance — DBT target prod
resource "google_bigquery_dataset" "prod_finance" {
  dataset_id  = "prod_finance"
  description = "DBT transformations environnement prod"
  location    = var.region
}

# ── SERVICE ACCOUNT ───────────────────────────────────

resource "google_service_account" "pipeline_sa" {
  account_id   = "finance-pipeline-sa"
  display_name = "Finance Pipeline Service Account"
  description  = "SA pour le pipeline de données financières"
}

# ── IAM — Permissions BigQuery ────────────────────────

resource "google_project_iam_member" "bq_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

# ── IAM — Permissions GCS ─────────────────────────────

resource "google_project_iam_member" "gcs_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"
}

# ── IAM — Permissions Cloud Build ─────────────────────

resource "google_project_iam_member" "cloudbuild_sa" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.pipeline_sa.email}"
}