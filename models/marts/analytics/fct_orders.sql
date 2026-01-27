with orders as (

    select
        order_id,
        customer_id,
        order_date,
        total_amount
    from {{ ref('stg_healf_bi_orders') }}

),

order_items_agg as (

    select
        order_id,
        sum(quantity) as total_items
    from {{ ref('stg_healf_bi_order_items') }}
    group by order_id

)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.total_amount,
    coalesce(oi.total_items, 0) as total_items
from orders o
left join order_items_agg oi
    on o.order_id = oi.order_id
