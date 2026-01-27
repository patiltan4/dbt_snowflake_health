with customers as (

    select
        customer_id,
        country
    from {{ ref('stg_healf_bi_customers') }}

),

orders_agg as (

    select
        customer_id,
        count(*) as total_orders,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        sum(total_amount) as lifetime_value
    from {{ ref('stg_healf_bi_orders') }}
    group by customer_id

)

select
    c.customer_id,
    c.country,

    coalesce(o.total_orders, 0) as total_orders,
    o.first_order_date,
    o.last_order_date,
    coalesce(o.lifetime_value, 0) as lifetime_value

from customers c
left join orders_agg o
    on c.customer_id = o.customer_id
