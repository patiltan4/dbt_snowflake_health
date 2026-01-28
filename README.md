Healf dbt Analytics Project

Overview

This project implements a production-style analytics pipeline using dbt on Snowflake. The objective is to transform raw e-commerce data into well-structured, analytics-ready fact and dimension tables while demonstrating good data modeling practices, testing discipline, and environment management.

Project Structure

The project follows a standard dbt layering approach, separating concerns clearly between ingestion, transformation, and analytics consumption.

models/
  sources/          -- External source definitions (raw Snowflake tables)
  staging/          -- Light transformations and standardisation (views)
  marts/
    analytics/      -- Analytics-ready facts and dimensions (tables)

macros/             -- Custom dbt macros (dynamic schema generation)


Source models describe upstream tables owned outside of dbt. Staging models perform minimal transformations such as renaming, type consistency, and basic cleaning. The marts layer contains business-facing models materialized as tables, designed for analytics and reporting use cases.

Core Analytics Models

The analytics layer contains three primary models.

dim_customers represents one row per customer and includes stable attributes alongside derived lifecycle metrics such as total orders, first and last order dates, and lifetime value. The model intentionally avoids transactional or highly volatile metrics to preserve a clean customer grain.

fct_orders is the canonical order-level fact table, with one row per order. It captures transactional truth such as order date, total order value, and total item count. Metrics like Average Order Value (AOV) are not stored directly but are derived from this table to retain flexibility.

fct_order_items_enriched operates at the order-item grain and joins customers, orders, order items, and products. This model demonstrates how the four core entities relate to one another and supports detailed product- and revenue-level analysis.

How to Run the Project

The project uses dbt Core with Snowflake key-pair authentication. Required Snowflake privileges include usage on the warehouse and database, the ability to create schemas, and create tables or views within the analytics database.

To validate the setup and run the models:

dbt debug
dbt build --target dev


For a production run, the same code can be deployed using:

dbt run --target prod

Environment and Schema Strategy

The project uses dynamic schema generation to support isolated development environments without requiring separate codebases or branches. Each developer runs dbt against a personal schema (for example, DEV_<username>), while production runs deploy to a stable PROD schema.

This approach ensures that development work is isolated, reduces the risk of conflicts, and allows the same models to be promoted through environments without modification. Environment behavior is controlled entirely through dbt targets and environment variables, not through SQL or Git branching.

Key Tradeoffs and Assumptions

The dataset provided is small and static, so marts are materialized as tables primarily for clarity and convention rather than performance necessity. In a larger environment, incremental materializations would likely be used for large fact tables.

Metrics such as AOV are intentionally derived rather than persisted. This avoids hard-coding business logic into base models and allows analysts to compute metrics flexibly over different time windows or cohorts.

Customer attributes are limited, so the customer dimension focuses on lifecycle signals derived from orders. Slowly changing dimensions and historical attribute tracking are not implemented due to lack of source data.

Light Analysis Prompts
Defining High-Value Customers

With the current data, high-value customers can be identified using a combination of lifetime revenue, number of orders, and recency of activity. Customers with multiple orders and higher cumulative spend can reasonably be treated as more valuable, even with limited attributes.

With richer data, this definition would improve significantly. Net revenue after refunds, discounts, and shipping costs would provide a more accurate picture of value. Acquisition channel and marketing spend would allow comparison of customer profitability rather than revenue alone. Cohort-based lifetime value (for example, 90-day or 180-day) would also help distinguish early strong customers from long-term loyal ones.

Measuring AOV and Repeat Purchase Behaviour Over Time

Average Order Value and repeat purchase behavior can be measured by aggregating the order fact table over time. By grouping orders by week or month and comparing average order values and repeat purchase rates, trends can be monitored as the business scales.

At larger scale, this approach would be supported by incremental aggregation tables and partitioning on order date in Snowflake. Cohort analysis based on first purchase date would allow more meaningful comparisons over time, while rolling averages would help smooth short-term volatility.

PostHog Linkage (Conceptual)

If PostHog event or experiment data were available, it would be ingested into Snowflake as a raw events table containing distinct_id, person_id, session_id, and timestamps.

To link this data back to customer and order models, a dedicated identity mapping table would be created. This table would map PostHog identifiers to internal customer identifiers and would be updated as identity stitching occurs.

A typical mapping table would include:

distinct_id

person_id

customer_id

first_seen_at

last_seen_at

In practice, anonymous users generate events with a distinct_id. Once a user logs in or converts, PostHog associates that activity with a person_id. The mapping table ensures this relationship is stable, auditable, and historically traceable. Session identifiers are useful for behavioral analysis but are not used as primary join keys.

Advanced dbt Questions
Q1: ref() vs var()

The ref() function is used to reference dbt models and is fundamental to dependency tracking, lineage, and build ordering. It ensures dbt understands how models relate to one another and enables safe refactoring.

The var() function is intended for runtime configuration values such as dates, thresholds, or feature flags. It should not be used to reference relations, as doing so hides dependencies and breaks dbt’s DAG awareness.

In production projects, ref() should always be used for models, while var() should be reserved for non-relational parameters.

Q2: Does ref() rebuild everything every run?

Using ref() does not cause all upstream models to be rebuilt on every run. Rebuild behavior is controlled by model materialization, selection strategy, and whether upstream data has changed.

Incremental models, selective execution (dbt run --select), and targeted builds all allow teams to control cost and performance. Replacing ref() with var() does not prevent rebuilds and introduces significant maintenance and correctness issues.

Q3: Fixing a “vars everywhere” Anti-Pattern

In a project where models are referenced via var() due to fear of rebuilds, the correct fix is structural rather than tactical.

At a high level, shared core models should be centralized into a clearly defined analytics or core mart and referenced consistently using ref(). Orchestration jobs should use dbt’s selection syntax to control what runs, rather than avoiding dependencies.

Cost and performance should be managed through appropriate materializations, such as incremental models for large tables, partitioning in Snowflake, and avoiding unnecessary full refreshes. var() should still be used for runtime flags or parameters, but never for model relation names.


Question

How would you fix a dbt project that overuses var() to avoid rebuilds of shared core tables, while still controlling cost?

Answer
1. Project Structure

Move shared tables (e.g. Shopify enriched sales) into a clear core / analytics mart

Reference all dbt-managed models using ref()

Remove var()-based relation definitions

2. Orchestration Strategy

Use dbt selectors (--select, tags, folders) to control what runs

Schedule core models separately from downstream domain models

Rebuild core tables only when explicitly selected

3. Cost & Performance Control

Use incremental models for large fact tables

Partition or cluster tables in Snowflake

Avoid routine full refreshes

Keep staging as views, marts as tables

4. When to Use var()

Runtime parameters (dates, flags, thresholds)

Rare external relations not managed by dbt

Never for dbt model references