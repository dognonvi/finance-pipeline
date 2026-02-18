"""
ingestion/upload_to_gcs_bq.py
-------------------------------
Etape 1 : Upload le CSV brut vers GCS
Etape 2 : Charge les données dans BigQuery (table raw)
"""
from pathlib import Path
from dotenv import load_dotenv
from google.cloud import storage, bigquery
import os

load_dotenv()

# ─── CONFIG ────────────────────────────────────────────────────────────────────
BASE_DIR   = Path(__file__).parent
PROJECT_ID = os.getenv("GCP_PROJECT_ID")
BUCKET_NAME= os.getenv("GCS_BUCKET")
DATASET_ID = "raw"
TABLE_ID   = "transactions"
LOCAL_FILE = BASE_DIR / "transactions.csv"   # ← même dossier que le script
GCS_BLOB   = "transactions/transactions.csv"
# ───────────────────────────────────────────────────────────────────────────────


def upload_to_gcs(local_path: str, bucket_name: str, blob_name: str) -> str:
    """Upload un fichier local vers Google Cloud Storage."""
    client  = storage.Client(project=PROJECT_ID)
    bucket  = client.bucket(bucket_name)
    blob    = bucket.blob(blob_name)
    blob.upload_from_filename(local_path)
    gcs_uri = f"gs://{bucket_name}/{blob_name}"
    print(f"[GCS] Fichier uploadé : {gcs_uri}")
    return gcs_uri


def load_gcs_to_bigquery(gcs_uri: str, dataset: str, table: str) -> None:
    """Charge un CSV depuis GCS vers BigQuery (table raw)."""
    client    = bigquery.Client(project=PROJECT_ID)
    table_ref = f"{PROJECT_ID}.{dataset}.{table}"

    job_config = bigquery.LoadJobConfig(
        source_format       = bigquery.SourceFormat.CSV,
        skip_leading_rows   = 1,          # header
        write_disposition   = bigquery.WriteDisposition.WRITE_TRUNCATE,
        autodetect          = True,       # détection auto du schéma
    )

    load_job = client.load_table_from_uri(gcs_uri, table_ref, job_config=job_config)
    load_job.result()  # attend la fin du job

    table_obj = client.get_table(table_ref)
    print(f"[BQ] {table_obj.num_rows} lignes chargées dans {table_ref}")


def run():
    print("=== INGESTION PIPELINE START ===")
    gcs_uri = upload_to_gcs(LOCAL_FILE, BUCKET_NAME, GCS_BLOB)
    load_gcs_to_bigquery(gcs_uri, DATASET_ID, TABLE_ID)
    print("=== INGESTION PIPELINE DONE ===")


if __name__ == "__main__":
    run()
