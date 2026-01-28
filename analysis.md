Analysis:

Early Personalisation with Limited Data

With the limited attributes available, early personalisation can rely on simple behavioral signals rather than detailed preferences. Customers who place repeat orders, purchase multiple items in their first order, or return shortly after their initial purchase are strong candidates for early personalisation. Basic signals such as country and product category can also support coarse but useful tailoring.

From this dataset, we can infer early engagement and purchase frequency. With richer data, such as product views, add-to-cart events, and search behavior, personalisation could be driven by intent and interest rather than just purchase history. Over time, cohort analysis and experimentation would help validate which personalised experiences drive higher retention.

Measuring AOV and Repeat Purchase Behaviour Over Time

Average Order Value and repeat purchase behavior can be measured using the order-level fact table by aggregating orders over time. Grouping by week or month allows tracking of AOV trends and the proportion of customers who place multiple orders. With small data, this analysis focuses on directional changes rather than statistical precision.

At scale, this would be extended using cohort-based analysis, incremental aggregation tables, and rolling averages to improve performance and stability. Additional behavioral and marketing data would allow changes in AOV and repeat behavior to be attributed to specific campaigns, experiments, or product changes rather than observed in isolation.