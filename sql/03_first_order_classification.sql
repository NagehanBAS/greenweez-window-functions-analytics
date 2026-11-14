
-- Greenweez | SQL Window Functions Analytics
-- Task 1.2: First Customer Order Classification
-- Database: Google BigQuery (Standard SQL)
--
-- Identify each customer's first order using ROW_NUMBER().
-- Assign a binary flag:
-- 1 = First order (new customer order)
-- 0 = Subsequent order
--
-- A secondary sorting key (orders_id) ensures deterministic
-- numbering when multiple orders share the same date.

-- Step 1: Create a ranked orders table using a CTE.

CREATE OR REPLACE TABLE
    `project-c980fc5b-d2fc-410c-816.course17.gwz_orders_17_rn`
AS

WITH numbered_orders AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customers_id
            ORDER BY date_date ASC, orders_id ASC
        ) AS rn
    FROM `project-c980fc5b-d2fc-410c-816.course17.gwz_orders_17`
)

-- Step 2: Flag the first order for each customer.

SELECT
    *,
    CASE
        WHEN rn = 1 THEN 1
        ELSE 0
    END AS is_new
FROM numbered_orders;

-- Step 3: Verify the classification for selected customers.

SELECT
    date_date,
    customers_id,
    orders_id,
    rn,
    is_new
FROM `project-c980fc5b-d2fc-410c-816.course17.gwz_orders_17_rn`
WHERE customers_id IN (212497, 205343, 33690)
ORDER BY customers_id, rn;

-- Expected results:
-- rn = 1  -> is_new = 1
-- rn > 1  -> is_new = 0
--
-- Each customer has exactly one first order flagged as new.
