
-- Greenweez | SQL Window Functions Analytics
-- Task 2.2: First-Order Sales Classification
-- Database: Google BigQuery (Standard SQL)
--
-- Identify all product lines belonging to each
-- customer's first order using DENSE_RANK().
--
-- Classification:
-- 1 = Product line from the customer's first order
-- 0 = Product line from a subsequent order
--
-- Unlike ROW_NUMBER(), DENSE_RANK() assigns the same
-- order number to all products in the same order.

-- Step 1: Create the classified sales table.

CREATE OR REPLACE TABLE
    `project-c980fc5b-d2fc-410c-816.course17.gwz_sales_17_ds_rk`
AS

WITH ranked_sales AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY customers_id
            ORDER BY date_date ASC, orders_id ASC
        ) AS ds_rk
    FROM `project-c980fc5b-d2fc-410c-816.course17.gwz_sales_17`
)

-- Step 2: Flag product lines from the first order.

SELECT
    *,
    CASE
        WHEN ds_rk = 1 THEN 1
        ELSE 0
    END AS is_new
FROM ranked_sales;

-- Step 3: Verify the classification for selected customers.

SELECT
    date_date,
    customers_id,
    orders_id,
    products_id,
    ds_rk,
    is_new
FROM `project-c980fc5b-d2fc-410c-816.course17.gwz_sales_17_ds_rk`
WHERE customers_id IN (98869, 217071, 268263)
ORDER BY customers_id, date_date, orders_id, products_id;

-- Expected results:
-- ds_rk = 1 -> is_new = 1
-- ds_rk > 1 -> is_new = 0
--
-- All product lines belonging to a customer's first
-- order are consistently classified as new.
