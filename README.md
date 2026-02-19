# 💰 Finance Data Pipeline — GCP + DBT + Jenkins

Pipeline de données financières cloud-native construit sur Google Cloud Platform,
transformé avec DBT et déployé automatiquement via Jenkins CI/CD.

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
 DBT Staging : stg_transactions       ← nettoyage, typage, validation
      │
      ▼
 DBT Marts :
  ├── mart_customer_kpis              ← KPIs par client
  └── mart_daily_kpis                ← KPIs par jour & catégorie
      │
      ▼
 Looker Studio Dashboard             ← visualisation & reporting
      ▲
      │
 Jenkins CI/CD                       ← lint → test → run → deploy prod
```

---

## 📁 Structure du projet

```
finance_pipeline/
├── ingestion/
│   ├── transactions.csv          # Données sources (simulées)
│   └── upload_to_gcs_bq.py      # Script d'ingestion GCS → BigQuery
│
├── dbt_project/
│   ├── dbt_project.yml           # Config DBT
│   ├── profiles.yml              # Connexions dev / prod
│   └── models/
│       ├── staging/
│       │   ├── stg_transactions.sql   # Nettoyage & typage
│       │   └── schema.yml             # Tests & documentation
│       └── marts/
│           ├── mart_customer_kpis.sql # KPIs par client
│           ├── mart_daily_kpis.sql    # KPIs journaliers
│           └── schema.yml             # Tests & documentation
│
├── jenkins/
│   └── Jenkinsfile               # Pipeline CI/CD complet
│
├── requirements.txt
└── README.md
```

---

## ⚙️ Prérequis

- Compte Google Cloud Platform avec facturation activée
- Projet GCP créé et BigQuery API activée
- Bucket GCS créé (ex: `finance-pipeline-raw`)
- Python 3.9+
- Jenkins installé (local ou VM)
- `gcloud` CLI configuré

---

## 🚀 Démarrage rapide

### 1. Cloner le projet
```bash
git clone https://github.com/vincent-dognon/finance-pipeline.git
cd finance_pipeline
pip install -r requirements.txt
```

### 2. Configurer les variables d'environnement
```bash
export GCP_PROJECT_ID="votre-project-id"
export GCS_BUCKET="finance-pipeline-raw"
export GCP_KEYFILE_PATH="/chemin/vers/service-account.json"
```

### 3. Lancer l'ingestion
```bash
python ingestion/upload_to_gcs_bq.py
```

### 4. Lancer DBT
```bash
cd dbt_project
dbt debug --profiles-dir .          # vérifie la connexion
dbt run   --profiles-dir .          # exécute les modèles
dbt test  --profiles-dir .          # lance les tests
```

### 5. Configurer Jenkins
- Créer un pipeline Jenkins pointant sur ce repo
- Ajouter les credentials : `gcp-project-id`, `gcp-service-account-key`
- Chaque push déclenche automatiquement le pipeline

---

## 📊 Modèles DBT

| Modèle | Couche | Type | Description |
|--------|--------|------|-------------|
| `stg_transactions` | Staging | View | Nettoyage & typage des transactions brutes |
| `mart_customer_kpis` | Marts | Table | KPIs agrégés par client |
| `mart_daily_kpis` | Marts | Table | KPIs agrégés par jour & catégorie |

---

## 🧪 Tests DBT intégrés

- `unique` et `not_null` sur toutes les clés primaires
- `accepted_values` sur `status` (SUCCESS / FAILED / PENDING)
- `accepted_values` sur `category` (SHOPPING / TRANSFER / FOOD / WITHDRAWAL)

---

## 🔄 Pipeline Jenkins

| Étape | Action |
|-------|--------|
| Checkout | Récupération du code |
| Install | Installation des dépendances Python & DBT |
| Ingestion | Upload CSV → GCS → BigQuery |
| DBT Debug | Vérification connexion BigQuery |
| DBT Source Tests | Tests sur les données sources |
| DBT Run | Exécution staging + marts |
| DBT Model Tests | Tests qualité sur les modèles |
| Deploy Prod | Deploy sur `prod` (branche `main` uniquement) |

---

## 📈 Dashboard Looker Studio

Connecter Looker Studio aux tables BigQuery :
- `prod_finance.mart_customer_kpis` → Scorecard clients, classement
- `prod_finance.mart_daily_kpis` → Graphiques de tendances, répartition par catégorie

---

## 🛠️ Stack Technique

`Python` · `Google Cloud Storage` · `BigQuery` · `DBT` · `Jenkins` · `Looker Studio` · `GCP` · `SQL` · `CI/CD`

---

## 👤 Auteur

**Vincent Dognon** — Data Engineer | GCP Certified × 3  
vince.dognon@gmail.com | [LinkedIn](https://linkedin.com/in/vincent-dognon)

## 🚀 CI/CD via GitHub Actions