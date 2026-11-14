
-- Greenweez | SQL Window Functions Analytics
-- Task 1.2: Order-Level Window Function Comparison
-- Database: Google BigQuery (Standard SQL)
--
-- Compare ROW_NUMBER() and RANK() to determine
-- the appropriate approach for identifying each
-- customer's first order.

-- Step 1: Assign a sequential order number
-- within each customer partition.

SELECT
    date_date,
    customers_id,
    orders_id,
    ROW_NUMBER() OVER (
        PARTITION BY customers_id
        ORDER BY date_date ASC
    ) AS rn
FROM `project-c980fc5b-d2fc-410c-816.course17.gwz_orders_17`
ORDER BY customers_id, date_date;

-- Step 2: Compare ROW_NUMBER() and RANK()
-- for selected customers.

SELECT
    date_date,
    customers_id,
    orders_id,
    ROW_NUMBER() OVER (
        PARTITION BY customers_id
        ORDER BY date_date ASC
    ) AS rn,
    RANK() OVER (
        PARTITION BY customers_id
        ORDER BY date_date ASC
    ) AS rk
FROM `project-c980fc5b-d2fc-410c-816.course17.gwz_orders_17`
WHERE customers_id IN (212497, 205343, 33690)
ORDER BY customers_id, date_date, orders_id;

-- Findings:
-- ROW_NUMBER() assigns a unique sequential number
-- to every order, even when multiple orders share a date.
--
-- RANK() assigns the same rank to orders on the same
-- date and may skip subsequent ranking positions.
--
-- ROW_NUMBER() is preferred because the business
-- objective requires identifying exactly one first
-- order per customer.
--
-- For deterministic ordering, include orders_id
-- as a secondary sorting key in production queries.
