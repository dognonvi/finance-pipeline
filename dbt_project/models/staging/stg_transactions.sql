-- models/staging/stg_transactions.sql
-- ─────────────────────────────────────
-- Nettoyage et typage des données brutes
-- Source : raw.transactions (chargé par le script d'ingestion)

with source as (

    select * from {{ source('raw', 'transactions') }}

),

cleaned as (

    select
        -- Identifiants
        trim(transaction_id)                            as transaction_id,
        trim(customer_id)                               as customer_id,

        -- Date proprement typée
        cast(transaction_date as date)                  as transaction_date,

        -- Montant et devise
        cast(amount as numeric)                         as amount,
        upper(trim(currency))                           as currency,

        -- Catégorie & statut normalisés en majuscules
        upper(trim(category))                           as category,
        upper(trim(status))                             as status,

        -- Marchand
        trim(merchant)                                  as merchant,

        -- Métadonnées techniques
        current_timestamp()                             as _loaded_at

    from source
    where transaction_id is not null      -- filtre les lignes vides

)

select * from cleaned
