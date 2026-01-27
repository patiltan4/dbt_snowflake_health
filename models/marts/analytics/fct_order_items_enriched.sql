select
    oi.order_item_id,
    o.order_id,
    o.order_date,
    c.customer_id,
    c.country,
    p.product_id,
    p.category,
    p.brand,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price as item_revenue

from {{ ref('stg_healf_bi_order_items') }} oi

join {{ ref('stg_healf_bi_orders') }} o
    on oi.order_id = o.order_id

join {{ ref('stg_healf_bi_customers') }} c
    on o.customer_id = c.customer_id

join {{ ref('stg_healf_bi_products') }} p
    on oi.product_id = p.product_id
