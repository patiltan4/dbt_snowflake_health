select
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    created_at as source_created_at
from {{ source('healf_bi', 'order_items') }}