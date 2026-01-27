select
    product_id,
    category,
    brand,
    price,
    created_at as source_created_at
from {{ source('healf_bi', 'products') }}
