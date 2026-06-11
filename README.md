## Task Overview

An e-commerce analytics database backs a "Top Products" dashboard used by category managers to decide which items to promote. The PostgreSQL database already contains a large fact table with hundreds of thousands of order line items and supporting product, category, and customer dimensions, all created and populated automatically. However, the current SQL that powers a top-products report is both logically incorrect (it shows global top products instead of per-category top-N and does not reliably exclude discontinued items) and inefficient on the large fact table due to avoidable full scans and non-sargable date filters. In this time-bounded task, you will work only at the SQL level to correct the analytics logic and improve performance; the database deployment and data loading are already complete and do not require any changes.

## Objectives

- Replace the existing top-products query in `sample_queries.sql` with a version that returns **top 3 products by total quantity per category** instead of a single global ranking.
- Structure your solution using a **CTE** to aggregate quantity per product and a **window function** (such as `ROW_NUMBER()` over a category partition) to rank products within each category.
- Ensure discontinued products are **fully excluded** from the result set based on the `is_discontinued` flag in the product dimension.
- Rewrite the date filter on the large `fact_order_items` table so that it is **sargable** (i.e., can benefit from an index on the date column if present) rather than applying functions directly to the fact table's date column.
- Optionally, add one or more **indexes** on the fact table to support the joins and date filtering used by your query, with the goal that `EXPLAIN` shows index usage instead of an unnecessary sequential scan on the entire fact table for this report.
- Demonstrate that your revised query is both **correct** (returns top 3 per category, excludes discontinued products) and **more efficient** on the large dataset, using execution timing and/or `EXPLAIN`/`EXPLAIN ANALYZE` for verification.

## Database Access

- Host: `<DROPLET_IP>`
- Port: `5432`
- Database name: `ecom_analytics`
- Username: `utkrusht`
- Password: `utkrusht_password`

You can connect using any PostgreSQL-compatible client such as `psql`, pgAdmin, DBeaver, or DataGrip. The database already contains a large `fact_order_items` table with around 150,000 rows representing production-scale order line items, along with supporting dimensions `dim_products`, `dim_categories`, and `dim_customers`. All tables and data are fully initialized before you start; your work is limited to reading, analyzing, and improving SQL queries against this schema.

## How to Verify

- Run the original query in `sample_queries.sql` to observe its behaviour: note that it returns a single global list of products and may take longer than expected due to scanning the entire `fact_order_items` table.
- Implement your revised query in a separate SQL block and run it, verifying that the output includes:
  - One or more rows per category.
  - At most **three products per category**, based on total quantity sold in the chosen time window.
  - No products where `is_discontinued` is true.
- Use `EXPLAIN` or `EXPLAIN ANALYZE` on your revised query and compare it with the original. Check that:
  - The plan for your query shows more efficient access patterns (for example, index scans instead of a full sequential scan on `fact_order_items` when appropriate).
  - The estimated and actual row counts for the fact table are reduced compared to scanning all rows.
- Optionally, measure execution time before and after your changes (e.g., using `\timing` in `psql`) to confirm that your version is at least somewhat faster or more scalable on the large fact table.
- Confirm that the ranking logic is correct by spot-checking one or two categories: manually compute total quantity per product for a single category and ensure that the top 3 in your result match those totals.

## Helpful Tips

- Consider how scanning all rows of a large fact table affects performance compared to using a selective filter on the date column.
- Consider which columns in `fact_order_items` are used for **joins** and **WHERE** conditions in the top-products query and how indexing those columns might change the query plan.
- Think about how to use a **CTE** to first compute total quantity per product and then apply a window function to rank products within each category in a clear, maintainable way.
- Think about how to write date predicates so they filter on a range of values (for example, between two dates) without calling functions on the fact table's date column.
- Explore how `ROW_NUMBER()` with `PARTITION BY category_id` and `ORDER BY total quantity DESC` can be used to select the top N products for each category.
- Explore `EXPLAIN` and `EXPLAIN ANALYZE` output to see when PostgreSQL performs a sequential scan versus an index scan on `fact_order_items`.
- Review how boolean flags like `is_discontinued` should be used in WHERE clauses to reliably exclude discontinued products from analytics reports.
