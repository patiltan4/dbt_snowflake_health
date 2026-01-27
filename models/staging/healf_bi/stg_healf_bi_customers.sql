select
    customer_id,
    first_order_date,
    country,
    created_at as source_created_at
from {{ source('healf_bi', 'customers') }}
