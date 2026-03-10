# variables.tf
# ─────────────────────────────────────────────
# Déclaration de toutes les variables

variable "project_id" {
  description = "ID du projet GCP"
  type        = string
}

variable "region" {
  description = "Région GCP"
  type        = string
  default     = "US"
}

variable "bucket_name" {
  description = "Nom du bucket GCS"
  type        = string
}

variable "environment" {
  description = "Environnement (dev ou prod)"
  type        = string
  default     = "dev"
}