
-- Greenweez | SQL Window Functions Analytics
-- Task 1.1 & Task 2.1: Dataset Setup and Data Import
-- Database: Google BigQuery (Standard SQL)
--
-- Import order-level and sales-line-level data from
-- the Greenweez training project into the course17 dataset.

-- Step 1: Import customer orders.

CREATE TABLE IF NOT EXISTS
    `project-c980fc5b-d2fc-410c-816.course17.gwz_orders_17`
AS
SELECT *
FROM `data-analytics-469406.course17.gwz_orders_17`;

-- Step 2: Verify the imported order records.

SELECT COUNT(*) AS total_orders
FROM `project-c980fc5b-d2fc-410c-816.course17.gwz_orders_17`;

-- Step 3: Import sales-line-level data.

CREATE TABLE IF NOT EXISTS
    `project-c980fc5b-d2fc-410c-816.course17.gwz_sales_17`
AS
SELECT *
FROM `data-analytics-469406.course17.gwz_sales_17`;

-- Step 4: Verify the imported sales records.

SELECT COUNT(*) AS total_sales_records
FROM `project-c980fc5b-d2fc-410c-816.course17.gwz_sales_17`;
