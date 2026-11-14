# Greenweez | SQL Window Functions Analytics

**SQL Portfolio Project | Google BigQuery | E-commerce Analytics | Customer Order & Sales Classification**

## Project Overview

This project demonstrates the application of SQL window functions in Google BigQuery to analyze customer purchasing behavior, identify first-time orders, and classify sales transactions.

Using Greenweez e-commerce training datasets, the project explores how `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()` behave across two different levels of transactional data:

- **Order-level data:** One record represents a customer order.
- **Sales-line-level data:** Multiple product records may belong to the same customer order.

The analysis focuses on selecting the appropriate window function for each data structure and developing reusable SQL transformations to identify first-time orders and their associated sales.

The final outputs are two structured BigQuery tables containing sequential order rankings and a binary `is_new` classification.

## Business Objectives

The project addresses five analytical objectives:

1. Identify the chronological sequence of purchases made by each customer.
2. Determine the first observed order for each customer.
3. Compare SQL ranking functions and understand how they handle duplicate ordering values.
4. Classify product-level sales according to whether they belong to a customer's first order.
5. Prepare consistent customer acquisition and repeat-purchase indicators for downstream commercial reporting.

These objectives support the development of reliable customer analytics, sales reporting, and customer lifecycle segmentation.

## Technology & Tools

| Technology | Application |
|---|---|
| Google BigQuery | Cloud-based SQL data warehouse |
| GoogleSQL (Standard SQL) | Data querying and transformation |
| SQL Window Functions | Order sequencing and ranking |
| Common Table Expressions (CTEs) | Multi-stage data transformations |
| GitHub | Version control and project documentation |

### SQL Concepts Demonstrated

- `ROW_NUMBER()`
- `RANK()`
- `DENSE_RANK()`
- `OVER()`
- `PARTITION BY`
- `ORDER BY`
- `CASE WHEN`
- `WITH ... AS`
- `CREATE TABLE IF NOT EXISTS`
- `CREATE OR REPLACE TABLE`
- `WHERE IN`
- Conditional classification
- Order-level and line-level data modeling
- SQL-based feature engineering

## Dataset Overview

The project uses two Greenweez training datasets stored in Google BigQuery.

| Source Table | Description | Data Granularity |
|---|---|---|
| `gwz_orders_17` | Customer order records | Order level |
| `gwz_sales_17` | Product-level sales transactions | Sales-line level |

Both tables were imported into the `course17` dataset of the working BigQuery project.

### Dataset 1 — Customer Orders

The `gwz_orders_17` table includes customer order history through August 31, 2021.

Key fields used in the analysis:

| Column | Description |
|---|---|
| `date_date` | Order date |
| `customers_id` | Unique customer identifier |
| `orders_id` | Unique order identifier |

The dataset enables the chronological sequencing of purchases for individual customers.

### Dataset 2 — Product-Level Sales

The `gwz_sales_17` table contains individual product lines associated with customer orders.

Relevant fields include:

| Column | Description |
|---|---|
| `date_date` | Transaction date |
| `orders_id` | Order identifier |
| `products_id` | Product identifier |
| `customers_id` | Customer identifier |
| `category_1` | Primary product category |
| `category_2` | Secondary product category |
| `category_3` | Detailed product category |
| `turnover_before_promo` | Revenue before promotions |
| `turnover` | Recorded sales revenue |
| `purchase_cost` | Product purchase cost |
| `qty` | Quantity sold |

Additional promotional fields are retained in the source data.

**Important distinction:** A single order may contain multiple product lines. Therefore, counting sales records is not equivalent to counting unique orders.

This distinction directly affects which SQL window function should be selected.

## Repository Structure

```text
greenweez-window-functions-analytics/
│
├── README.md
│
└── sql/
    ├── 01_data_import.sql
    ├── 02_order_window_functions.sql
    ├── 03_first_order_classification.sql
    ├── 04_sales_window_functions.sql
    └── 05_first_sale_classification.sql
```

### SQL Files

| File | Purpose |
|---|---|
| `01_data_import.sql` | Import customer order and sales datasets into BigQuery |
| `02_order_window_functions.sql` | Compare `ROW_NUMBER()` and `RANK()` at order level |
| `03_first_order_classification.sql` | Identify first customer orders using `ROW_NUMBER()` and `is_new` |
| `04_sales_window_functions.sql` | Compare all three ranking functions at sales-line level |
| `05_first_sale_classification.sql` | Identify first-order sales using `DENSE_RANK()` and `is_new` |

## Analysis 1 — Customer Order Sequencing

### Business Question

**How can we determine the sequence of orders placed by each customer?**

The analysis begins by applying `ROW_NUMBER()` to the customer order dataset.

The function partitions transactions by customer and orders them chronologically.

### Methodology

- Partition records using `customers_id`.
- Sort orders by `date_date` in ascending order.
- Assign consecutive sequence numbers using `ROW_NUMBER()`.
- Store the result in a new column named `rn`.

The first order receives `rn = 1`, the second receives `rn = 2`, and so on.

### Example

For customer `10`, the query returned:

| Order Date | Order ID | rn |
|---|---:|---:|
| 2021-04-12 | 839624 | 1 |
| 2021-05-16 | 878267 | 2 |
| 2021-06-24 | 915362 | 3 |

This demonstrates how a customer's purchasing history can be represented as an ordered sequence.

### Business Relevance

Sequential order numbers provide a foundation for:

- First-order identification
- Repeat-purchase analysis
- Customer lifecycle segmentation
- Purchase frequency analysis
- Future customer retention reporting

## Analysis 2 — ROW_NUMBER() vs. RANK()

### Business Question

**What happens when a customer places multiple orders on the same date?**

The project compares `ROW_NUMBER()` and `RANK()` using three selected customer IDs:

- `33690`
- `205343`
- `212497`

### Observed Results

**Customer 33690**

Two orders were placed on June 15, 2021.

| Order ID | rn | rk |
|---|---:|---:|
| 907887 | 2 | 1 |
| 907893 | 1 | 1 |

Both orders receive rank 1 because their dates are identical. However, `ROW_NUMBER()` assigns distinct numbers.

**Customer 205343**

The customer placed two orders on June 23, 2021.

The observed sequences were:

- `ROW_NUMBER()`: 1, 2, 3, 4, 5
- `RANK()`: 1, 2, 2, 4, 5

**Customer 212497**

Three orders were placed on April 29, 2021.

- `ROW_NUMBER()`: Three unique row numbers (1, 2, 3)
- `RANK()`: All three orders receive rank 1

### Interpretation

`ROW_NUMBER()` assigns a unique sequential value to every row.

`RANK()` assigns the same rank to rows sharing identical ordering values, potentially skipping subsequent rank numbers.

For order-level customer acquisition analysis, the objective is to identify exactly one first order per customer.

Therefore, **`ROW_NUMBER()` is the preferred function**.

### Deterministic Ordering

The final classification query includes both `date_date` and `orders_id` in the ordering criteria.

This establishes a consistent tie-breaking rule when multiple orders share the same date.

The resulting classification selects the earliest order date and, where necessary, the smallest order ID.

## Analysis 3 — First Customer Order Classification

### Business Question

**How can we automatically identify the first order placed by each customer?**

The project combines `ROW_NUMBER()` with a Common Table Expression (CTE) and a conditional classification.

### Transformation Logic

**Step 1 — Calculate the order number**

Use `ROW_NUMBER()` to generate a sequential order number for each customer.

**Step 2 — Assign the classification**

| Condition | is_new | Meaning |
|---|---:|---|
| `rn = 1` | 1 | First observed customer order |
| `rn > 1` | 0 | Subsequent customer order |

**Step 3 — Store the results**

Create the following BigQuery table:

`course17.gwz_orders_17_rn`

### Final Output

The resulting table retains the original order attributes and includes:

- `rn` — Sequential customer order number
- `is_new` — Binary first-order indicator

### Business Value

The classification provides a standardized foundation for:

- Identifying first-time purchases within the available data
- Separating first orders from repeat orders
- Monitoring new-order activity
- Developing customer acquisition reporting
- Analyzing customer purchasing progression

Using a CTE separates the ranking calculation from the business classification logic, improving readability and maintainability.

## Analysis 4 — Window Functions in Sales-Line-Level Data

### Business Question

**Which ranking function correctly represents customer order sequences when an order contains multiple products?**

Unlike the order-level dataset, the sales dataset contains individual product lines.

Therefore, the same `orders_id` may appear across multiple records.

The analysis compares three SQL window functions:

- `ROW_NUMBER()`
- `RANK()`
- `DENSE_RANK()`

All three functions partition data by customer and use both order date and order ID as ordering criteria.

### Observed Example — Customer 268263

This customer had two observed orders.

The first order, `858437`, contained three product lines. The second order, `894651`, contained one product line.

| Order ID | Product Lines | ROW_NUMBER() | RANK() | DENSE_RANK() |
|---|---:|---|---|---|
| 858437 | 3 | 1, 2, 3 | 1, 1, 1 | 1, 1, 1 |
| 894651 | 1 | 4 | 4 | 2 |

### Function Comparison

**ROW_NUMBER()**

Assigns a different number to every product line.

This is not suitable for representing order sequence numbers because multiple products from the same order receive different values.

**RANK()**

Assigns the same rank to product lines belonging to the same order.

However, ranking positions may be skipped when multiple rows share the same rank.

**DENSE_RANK()**

Assigns the same rank to all product lines belonging to the same order and generates consecutive order numbers without gaps.

This makes `DENSE_RANK()` the most appropriate function for the business requirement.

### Additional Observed Example — Customer 98869

The customer placed two orders containing two product lines each.

| Order ID | Number of Product Lines | RANK() | DENSE_RANK() |
|---|---:|---|---|
| 850979 | 2 | 1, 1 | 1, 1 |
| 907192 | 2 | 3, 3 | 2, 2 |

The result reinforces why `DENSE_RANK()` is preferable for identifying a customer's first, second, and subsequent orders within line-level sales data.

### Key Finding

**Ranking methods must match the granularity of the dataset.**

A function that works correctly for order-level records may produce misleading order numbers when applied to product-level sales records.

## Analysis 5 — First-Order Sales Classification

### Business Question

**How can every product line belonging to a customer's first order be identified?**

The final transformation uses `DENSE_RANK()` to number distinct orders within the sales dataset.

A CTE calculates the order ranking before a `CASE WHEN` expression generates the first-order indicator.

### Classification Logic

| Condition | is_new | Meaning |
|---|---:|---|
| `ds_rk = 1` | 1 | Product line belongs to the first observed order |
| `ds_rk > 1` | 0 | Product line belongs to a subsequent order |

### Output Table

`course17.gwz_sales_17_ds_rk`

The resulting table retains all original product-level sales attributes and adds:

- `ds_rk` — Sequential customer order number
- `is_new` — First-order sales indicator

### Example

For customer `268263`:

| Order ID | Product Lines | ds_rk | is_new |
|---|---:|---:|---:|
| 858437 | 3 | 1 | 1 |
| 894651 | 1 | 2 | 0 |

All three product lines from the first order are classified as new-order sales.

The subsequent order is classified as a repeat order.

### Business Value

This transformation enables future analysis of:

- Revenue associated with first orders
- Revenue associated with repeat orders
- Product categories purchased in first orders
- Customer acquisition-related sales activity
- First-order basket composition
- Repeat-purchase patterns

The classification also provides a foundation for identifying which categories or products are commonly included in customers' first observed purchases.

## Consolidated Findings

| Analysis Area | Selected Function | Reason |
|---|---|---|
| Order-level sequencing | `ROW_NUMBER()` | Assigns one unique number per order row |
| Order-level first-order classification | `ROW_NUMBER()` | Identifies exactly one first order per customer |
| Sales-line-level order ranking | `DENSE_RANK()` | Assigns the same consecutive order number to all product lines in an order |
| Sales-line-level first-order classification | `DENSE_RANK()` | Flags every product line from the first order |
| Intermediate transformations | `WITH ... AS` | Separates ranking calculations from classification logic |

### Key Business Insights

**1. Data granularity determines analytical methodology.**

Order-level and product-level data require different approaches to ranking, even when answering similar business questions.

**2. First-order identification is a foundation for customer analytics.**

A consistent first-order indicator supports the distinction between initial purchase activity and subsequent transactions.

**3. Duplicate ordering values must be handled carefully.**

Multiple orders can share a date, and multiple product lines can belong to one order. Ranking logic must reflect the underlying business entity.

**4. Window functions simplify customer-level calculations.**

SQL window functions enable customer-specific sequencing while preserving the original transaction rows.

**5. Structured transformations support future commercial reporting.**

The resulting tables can be used as inputs for dashboards, customer segmentation, purchasing behavior analysis, and e-commerce performance monitoring.

## Business Applications & Recommendations

### Customer Acquisition Analytics

Use first-order indicators to monitor initial purchase activity and distinguish first observed orders from repeat purchases.

### Sales & Revenue Reporting

Segment sales revenue into first-order and repeat-order categories to understand the composition of recorded commercial activity.

### Category Management

Examine the product categories appearing in first orders to identify potential customer entry points and category engagement patterns.

### Customer Retention Analytics

Use sequential order rankings to prepare repeat-purchase reports and investigate purchasing patterns over time.

### Business Intelligence

Integrate the classified datasets into Power BI or other reporting environments for recurring commercial performance analysis.

These are recommended downstream applications. The current project develops the SQL classification foundation rather than a full business intelligence dashboard or quantified performance assessment.

## Data Quality & Methodological Considerations

The following considerations are important when interpreting the analysis:

- **Observation period:** The first identified order is the earliest order present in the available dataset. It should not automatically be interpreted as the customer's first lifetime purchase unless complete historical coverage is confirmed.
- **Date ties:** Multiple orders on the same date require an additional sorting key. The final order-level transformation uses `orders_id` to establish deterministic sequencing.
- **Sales granularity:** Multiple sales rows may belong to one order. Aggregations must distinguish product-line counts from unique order counts.
- **First-order flags:** The `is_new` indicator is calculated at different granularities in the two output tables.
- **Revenue aggregation:** Summing first-order sales revenue at product-line level can be appropriate, but counting first-order transactions requires distinct order IDs to avoid double-counting.
- **Ranking assumptions:** The analysis assumes order IDs and dates correctly identify the ordering of customer transactions.
- **Customer identifiers:** The calculations rely on consistent customer IDs across transaction records.
- **Analytical scope:** The project focuses on classification and data transformation, not causal analysis or forecasting.

These considerations help ensure that the resulting analytical indicators are interpreted appropriately.

## How to Run the Project

### Prerequisites

- Access to Google BigQuery
- A Google Cloud project with the required permissions
- Access to the Greenweez training datasets
- A `course17` dataset in the appropriate BigQuery location

The source training datasets and working dataset are configured in the EU region.

### Recommended Execution Order

1. Run `sql/01_data_import.sql` to import the orders and sales tables.
2. Run `sql/02_order_window_functions.sql` to examine order-level ranking functions.
3. Run `sql/03_first_order_classification.sql` to create `gwz_orders_17_rn`.
4. Run `sql/04_sales_window_functions.sql` to compare ranking behavior across product-level sales.
5. Run `sql/05_first_sale_classification.sql` to create `gwz_sales_17_ds_rk`.

### Configuration Notes

The SQL files use the BigQuery project and dataset identifiers configured during development.

When running the project in a different environment, update the fully qualified table references accordingly.

The data import script uses `CREATE TABLE IF NOT EXISTS`, which preserves tables that already exist.

The final transformation scripts use `CREATE OR REPLACE TABLE`, meaning their output tables are rebuilt when executed.

## Final Deliverables

The project produces two analytical tables:

| Output Table | Added Fields | Purpose |
|---|---|---|
| `gwz_orders_17_rn` | `rn`, `is_new` | Identify first customer orders |
| `gwz_sales_17_ds_rk` | `ds_rk`, `is_new` | Identify all sales lines belonging to first customer orders |

Both output tables were successfully created in Google BigQuery during the project.

The repository contains the corresponding SQL scripts and documented ranking methodology.

## Skills Demonstrated

**Technical Skills**

- Google BigQuery SQL
- Advanced SQL window functions
- Customer-level partitioning
- Transaction ranking and sequencing
- Multi-stage queries with CTEs
- Conditional business classifications
- SQL table creation and transformation
- Data validation
- Data modeling across different granularities
- Query documentation and version control

**Business & Analytical Skills**

- E-commerce sales analytics
- Customer purchase behavior analysis
- New vs. repeat order classification
- Customer lifecycle analytics
- Commercial reporting foundations
- Data-driven decision support
- Analytical problem-solving
- Translating business requirements into SQL logic

## Conclusion

This project demonstrates how SQL window functions can transform raw e-commerce transaction records into structured customer order classifications.

The main technical outcome is the identification of appropriate ranking strategies for different transaction granularities:

- `ROW_NUMBER()` for assigning unique order numbers at order level.
- `DENSE_RANK()` for assigning consistent, consecutive order numbers across product-level sales records.

By combining these functions with CTEs and conditional expressions, the project establishes a reliable starting point for customer acquisition, repeat-purchase, and commercial performance analytics.

The resulting BigQuery tables are designed to support future business intelligence, reporting, and customer behavior analysis.

## Author

**Nagehan Bas**
