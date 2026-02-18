-- models/marts/mart_daily_kpis.sql
-- ─────────────────────────────────────────────────────
-- KPIs financiers agrégés par jour et catégorie
-- Alimente le dashboard Looker Studio (vue tendances)

with transactions as (

    select * from {{ ref('stg_transactions') }}

),

daily as (

    select
        transaction_date,
        category,

        -- Volumes
        count(*)                                                        as nb_transactions,
        sum(amount)                                                     as total_amount_eur,
        avg(amount)                                                     as avg_amount,

        -- Statuts
        countif(status = 'SUCCESS')                                     as nb_success,
        countif(status = 'FAILED')                                      as nb_failed,

        -- Taux de succès journalier (%)
        round(
            safe_divide(countif(status = 'SUCCESS'), count(*)) * 100, 2
        )                                                               as daily_success_rate_pct,

        -- Montant total uniquement sur les transactions réussies
        sum(case when status = 'SUCCESS' then amount else 0 end)        as successful_amount_eur

    from transactions
    group by transaction_date, category

)

select * from daily
order by transaction_date, category
