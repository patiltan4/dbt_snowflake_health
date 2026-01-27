select
    order_id,
    customer_id,
    order_date,
    total_amount,
    created_at as source_created_at
from {{ source('healf_bi', 'orders') }}