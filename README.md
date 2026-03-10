# 💰 Finance Data Pipeline — GCP + DBT + GitHub Actions

Pipeline de données financières cloud-native construit sur Google Cloud Platform,
transformé avec DBT et déployé automatiquement via GitHub Actions CI/CD.

---

## 🏗️ Architecture

```
transactions.csv
      │
      ▼
 [Ingestion Python]
      │
      ├──► Google Cloud Storage (GCS)  ← données brutes archivées
      │
      ▼
 BigQuery : raw.transactions
      │
      ▼
 DBT Staging : stg_transactions          ← nettoyage, typage, validation
      │
      ▼
 DBT Marts :
  ├── mart_customer_kpis                 ← KPIs agrégés par client
  └── mart_daily_kpis                   ← KPIs par jour & catégorie
      │
      ▼
 Looker Studio Dashboard                ← visualisation & reporting
      ▲
      │
 GitHub Actions CI/CD
  ├── pipeline-dev  (branches dev & main)  ← ingestion + dbt run/test
  └── pipeline-prod (branche main only)    ← deploy prod_finance
```

---

## 📁 Structure du projet

```
finance_pipeline/
├── .github/
│   └── workflows/
│       └── pipeline.yml          # CI/CD GitHub Actions (dev + prod)
│
├── ingestion/
│   ├── transactions.csv          # Données financières simulées (15 transactions)
│   └── upload_to_gcs_bq.py      # Script ingestion CSV → GCS → BigQuery
│
├── dbt_project/
│   ├── dbt_project.yml           # Configuration DBT
│   ├── profiles.yml              # Connexions BigQuery dev / prod (oauth)
│   └── models/
│       ├── staging/
│       │   ├── stg_transactions.sql   # Nettoyage & typage des données brutes
│       │   └── schema.yml             # Tests qualité (unique, not_null, accepted_values)
│       └── marts/
│           ├── mart_customer_kpis.sql # KPIs financiers par client
│           ├── mart_daily_kpis.sql    # KPIs journaliers par catégorie
│           └── schema.yml             # Tests qualité des marts
│
├── jenkins/
│   └── Jenkinsfile               # Pipeline Jenkins (documentation de référence)
│
├── requirements.txt
├── .env.example
├── .gitignore
└── README.md
```

---

## ⚙️ Prérequis

- Compte Google Cloud Platform avec projet actif
- BigQuery API et Cloud Storage API activées
- Datasets BigQuery créés : `raw`, `dev_finance`, `prod_finance`
- Bucket GCS créé
- Python 3.12+
- Compte GitHub avec Actions activé

---

## 🚀 Démarrage rapide (local)

### 1. Cloner le projet
```bash
git clone https://github.com/dognonvi/finance-pipeline.git
cd finance_pipeline
```

### 2. Créer et activer le venv
```bash
python -m venv venv
source venv/bin/activate   # Mac/Linux
pip install -r requirements.txt
```

### 3. Configurer les variables d'environnement
```bash
cp .env.example .env
# Remplir les valeurs dans .env
```

```bash
# .env
GCP_PROJECT_ID=votre-project-id
GCS_BUCKET=votre-bucket-name
GCP_KEYFILE_PATH=./service-account.json
```

### 4. Lancer l'ingestion
```bash
python ingestion/upload_to_gcs_bq.py
```

### 5. Lancer DBT
```bash
cd dbt_project
dbt debug --profiles-dir .    # vérifier la connexion
dbt run   --profiles-dir .    # exécuter les modèles
dbt test  --profiles-dir .    # lancer les tests
```

---

## 🔄 Pipeline GitHub Actions

Le CI/CD se déclenche automatiquement à chaque `push` ou `pull_request`.

### Workflow

| Job | Déclencheur | Actions |
|-----|-------------|---------|
| `pipeline-dev` | Toutes branches | Ingestion → DBT debug → DBT run (dev) → DBT test (dev) |
| `pipeline-prod` | Branche `main` uniquement | DBT run (prod) → DBT test (prod) |

### Authentification GCP

L'authentification GCP est gérée par `google-github-actions/auth@v1` — DBT utilise automatiquement les credentials via `method: oauth`. Un seul secret suffit.

### Secrets GitHub à configurer

```
Settings → Secrets and variables → Actions
```

| Secret | Description |
|--------|-------------|
| `GCP_PROJECT_ID` | ID du projet GCP |
| `GCS_BUCKET` | Nom du bucket GCS |
| `GCP_SA_KEY` | Contenu JSON du service account |

---

## 📊 Modèles DBT

| Modèle | Couche | Type | Description |
|--------|--------|------|-------------|
| `stg_transactions` | Staging | View | Nettoyage & typage des transactions brutes |
| `mart_customer_kpis` | Marts | Table | KPIs agrégés par client (taux succès, top catégorie, montants) |
| `mart_daily_kpis` | Marts | Table | KPIs agrégés par jour & catégorie |

### Datasets BigQuery

| Dataset | Environnement | Alimenté par |
|---------|---------------|--------------|
| `raw` | Tous | Script ingestion Python |
| `dev_finance_staging` | Dev | DBT target dev |
| `dev_finance_marts` | Dev | DBT target dev |
| `prod_finance` | Prod | GitHub Actions (branche main) |

---

## 🧪 Tests DBT intégrés

- `unique` et `not_null` sur toutes les clés primaires
- `accepted_values` sur `status` : SUCCESS / FAILED / PENDING
- `accepted_values` sur `category` : SHOPPING / TRANSFER / FOOD / WITHDRAWAL
- 17 tests au total — 15 PASS validés en CI/CD ✅

---

## 🛠️ Stack Technique

| Catégorie | Technologies |
|-----------|-------------|
| Cloud | Google Cloud Platform (GCP) |
| Stockage | Google Cloud Storage (GCS) |
| Data Warehouse | BigQuery |
| Transformation | DBT (Data Build Tool) |
| Langage | Python 3.12, SQL |
| CI/CD | GitHub Actions |
| Visualisation | Looker Studio |

---

## 👤 Auteur

**Vincent Dognon** — Data Engineer&IA | 3× Google Cloud Certified
vince.dognon@gmail.com | [LinkedIn](https://linkedin.com/in/vincent-dognon) | [GitHub](https://github.com/dognonvi)