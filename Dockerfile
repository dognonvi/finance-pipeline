# ─────────────────────────────────────────────────────────────────────────────
# Dockerfile — Finance Data Pipeline
# Image Python + DBT + Google Cloud SDK
# ─────────────────────────────────────────────────────────────────────────────

# ── STAGE 1 : Base ────────────────────────────────────────────────────────────
FROM python:3.12-slim AS base

# Métadonnées
LABEL maintainer="Vincent Dognon <vince.dognon@gmail.com>"
LABEL description="Finance Data Pipeline — GCP + DBT"

# Variables d'environnement
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DBT_PROFILES_DIR=/app/dbt_project

# Répertoire de travail
WORKDIR /app

# ── STAGE 2 : Dependencies ────────────────────────────────────────────────────
FROM base AS dependencies

# Copier uniquement requirements d'abord (cache Docker optimisé)
COPY requirements.txt .

# Installer les dépendances
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# ── STAGE 3 : Final ───────────────────────────────────────────────────────────
FROM dependencies AS final

# Copier tout le projet
COPY . .

# Créer un utilisateur non-root pour la sécurité
RUN useradd -m -u 1000 pipeline && \
    chown -R pipeline:pipeline /app

USER pipeline

# Point d'entrée par défaut — peut être surchargé
CMD ["python", "ingestion/upload_to_gcs_bq.py"]