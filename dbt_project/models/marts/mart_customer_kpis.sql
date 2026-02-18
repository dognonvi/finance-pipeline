-- models/marts/mart_customer_kpis.sql

with transactions as (

    select * from {{ ref('stg_transactions') }}

),

-- Catégorie favorite par client via ARRAY_AGG (compatible BigQuery)
top_category as (

    select
        customer_id,
        array_agg(category order by cnt desc limit 1)[offset(0)] as top_category
    from (
        select
            customer_id,
            category,
            count(*) as cnt
        from transactions
        group by customer_id, category
    )
    group by customer_id

),

kpis as (

    select
        t.customer_id,
        count(*)                                                        as total_transactions,
        sum(t.amount)                                                   as total_amount_eur,
        round(avg(t.amount), 2)                                         as avg_transaction_amount,
        max(t.amount)                                                   as max_transaction_amount,
        min(t.amount)                                                   as min_transaction_amount,
        countif(t.status = 'SUCCESS')                                   as nb_success,
        countif(t.status = 'FAILED')                                    as nb_failed,
        countif(t.status = 'PENDING')                                   as nb_pending,
        round(
            safe_divide(countif(t.status = 'SUCCESS'), count(*)) * 100, 2
        )                                                               as success_rate_pct,
        min(t.transaction_date)                                         as first_transaction_date,
        max(t.transaction_date)                                         as last_transaction_date,
        date_diff(max(t.transaction_date), min(t.transaction_date), day) as activity_span_days
    from transactions t
    group by t.customer_id

)

select
    k.*,
    tc.top_category
from kpis k
left join top_category tc using (customer_id)
order by total_amount_eur desc