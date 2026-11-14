
-- Greenweez | SQL Window Functions Analytics
-- Task 2.2: Sales-Level Window Function Comparison
-- Database: Google BigQuery (Standard SQL)
--
-- Compare ROW_NUMBER(), RANK(), and DENSE_RANK()
-- to identify the correct method for numbering
-- customer orders in sales-line-level data.
--
-- Each order can contain multiple product lines.
-- Therefore, multiple rows can share the same
-- customer ID, date, and order ID.

-- Step 1: Compare ROW_NUMBER() and RANK().

SELECT
    *,
    ROW_NUMBER() OVER (
        PARTITION BY customers_id
        ORDER BY date_date ASC, orders_id ASC
    ) AS rn,
    RANK() OVER (
        PARTITION BY customers_id
        ORDER BY date_date ASC, orders_id ASC
    ) AS rk
FROM `project-c980fc5b-d2fc-410c-816.course17.gwz_sales_17`
WHERE customers_id IN (98869, 217071, 268263)
ORDER BY customers_id, date_date, orders_id;

-- Step 2: Compare all three window functions.

SELECT
    date_date,
    customers_id,
    orders_id,
    products_id,
    ROW_NUMBER() OVER (
        PARTITION BY customers_id
        ORDER BY date_date ASC, orders_id ASC
    ) AS rn,
    RANK() OVER (
        PARTITION BY customers_id
        ORDER BY date_date ASC, orders_id ASC
    ) AS rk,
    DENSE_RANK() OVER (
        PARTITION BY customers_id
        ORDER BY date_date ASC, orders_id ASC
    ) AS ds_rk
FROM `project-c980fc5b-d2fc-410c-816.course17.gwz_sales_17`
WHERE customers_id IN (98869, 217071, 268263)
ORDER BY customers_id, date_date, orders_id, products_id;

-- Findings:
--
-- ROW_NUMBER() assigns a unique number to every product line,
-- even when multiple products belong to the same order.
--
-- RANK() assigns the same rank to product lines from the
-- same order but skips subsequent ranking positions.
--
-- DENSE_RANK() assigns the same rank to all product lines
-- belonging to one order and produces consecutive order
-- numbers without gaps.
--
-- Example: Customer 268263
-- First order (3 product lines):
--   ROW_NUMBER: 1, 2, 3
--   RANK:       1, 1, 1
--   DENSE_RANK: 1, 1, 1
--
-- Second order (1 product line):
--   ROW_NUMBER: 4
--   RANK:       4
--   DENSE_RANK: 2
--
-- DENSE_RANK() is the preferred function for classifying
-- customer orders within sales-line-level records.
