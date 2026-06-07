-- ==============================================================================
-- STRATEGIC SUPERSTORE DATASET ANALYTICS WORKBOOK
-- Focus: Subqueries, CTEs, Window Functions, and Customer Insights
-- Target Dataset: https://www.kaggle.com/datasets/vivek468/superstore-dataset-final
-- ==============================================================================

-- ==============================================================================
-- STEP 1: SETUP DATA & RELATIONAL SCHEMA NORMALIZATION
-- ==============================================================================

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(255),
    segment VARCHAR(100)
);

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    sub_category VARCHAR(100)
);

CREATE TABLE orders (
    row_id INT PRIMARY KEY,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(100),
    customer_id VARCHAR(50),
    product_id VARCHAR(50),
    sales DECIMAL(10, 2),
    quantity INT,
    discount DECIMAL(4, 2),
    profit DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers (customer_id, customer_name, segment)
SELECT DISTINCT `Customer ID`, `Customer Name`, `Segment`
FROM superstore_raw;

INSERT INTO products (product_id, product_name, category, sub_category)
SELECT DISTINCT `Product ID`, `Product Name`, `Category`, `Sub-Category`
FROM superstore_raw;

INSERT INTO orders (row_id, order_id, order_date, ship_date, ship_mode, customer_id, product_id, sales, quantity, discount, profit)
SELECT 
    `Row ID`, 
    `Order ID`, 
    STR_TO_DATE(`Order Date`, '%m/%d/%Y'), 
    STR_TO_DATE(`Ship Date`, '%m/%d/%Y'), 
    `Ship Mode`, `Customer ID`, `Product ID`, `Sales`, `Quantity`, `Discount`, `Profit`
FROM superstore_raw;


-- ==============================================================================
-- STEP 2: CORE ADVANCED QUERY SPECIFICATIONS
-- ==============================================================================

-- Q1: Orders where sales are greater than the average sales
SELECT order_id, customer_id, sales 
FROM orders 
WHERE sales > (SELECT AVG(sales) FROM orders);

-- Q2: Highest sales order for each customer
SELECT o.customer_id, o.order_id, o.sales
FROM orders o
WHERE o.sales = (
    SELECT MAX(sub.sales) 
    FROM orders sub 
    WHERE sub.customer_id = o.customer_id
);

-- Q3: Total sales for each customer
WITH CustomerSales AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT cs.customer_id, c.customer_name, cs.total_sales
FROM CustomerSales cs
JOIN customers c ON cs.customer_id = c.customer_id;

-- Q4: Customers whose total sales are above average
WITH CustomerSales AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT cs.customer_id, cs.total_sales
FROM CustomerSales cs
WHERE cs.total_sales > (SELECT AVG(total_sales) FROM CustomerSales);

-- Q5: Rank all customers based on total sales
SELECT 
    customer_id,
    SUM(sales) AS total_sales,
    DENSE_RANK() OVER (ORDER BY SUM(sales) DESC) AS customer_rank
FROM orders
GROUP BY customer_id;

-- Q6: Assign row numbers to each order within a customer
SELECT 
    customer_id,
    order_id,
    order_date,
    sales,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS order_sequence
FROM orders;

-- Q7: Top 3 customers based on total sales
WITH RankedCustomers AS (
    SELECT 
        customer_id,
        SUM(sales) AS total_sales,
        DENSE_RANK() OVER (ORDER BY SUM(sales) DESC) AS ranking
    FROM orders
    GROUP BY customer_id
)
SELECT rc.customer_id, c.customer_name, rc.total_sales, rc.ranking
FROM RankedCustomers rc
JOIN customers c ON rc.customer_id = c.customer_id
WHERE rc.ranking <= 3;


-- ==============================================================================
-- STEP 3: FINAL COMBINED ARCHITECTURE MASTER QUERY
-- ==============================================================================

WITH SalesAggregation AS (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
),
RankedMetrics AS (
    SELECT 
        customer_id,
        total_sales,
        DENSE_RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
    FROM SalesAggregation
)
SELECT 
    c.customer_name,
    rm.total_sales,
    rm.sales_rank
FROM RankedMetrics rm
JOIN customers c ON rm.customer_id = c.customer_id
ORDER BY rm.sales_rank ASC;


-- ==============================================================================
-- MINI PROJECT: BUSINESS CASE INSIGHTS & CUSTOMER SEGMENTATION
-- ==============================================================================

-- Task 1: Who are the top 5 customers?
WITH RankedSummary AS (
    SELECT customer_id, SUM(sales) AS total_sales,
           DENSE_RANK() OVER (ORDER BY SUM(sales) DESC) AS ranking
    FROM orders GROUP BY customer_id
)
SELECT r.customer_id, c.customer_name, r.total_sales 
FROM RankedSummary r JOIN customers c ON r.customer_id = c.customer_id 
WHERE r.ranking <= 5;

-- Task 2: Who are the bottom 5 customers?
WITH RankedSummary AS (
    SELECT customer_id, SUM(sales) AS total_sales,
           DENSE_RANK() OVER (ORDER BY SUM(sales) ASC) AS ranking
    FROM orders GROUP BY customer_id
)
SELECT r.customer_id, c.customer_name, r.total_sales 
FROM RankedSummary r JOIN customers c ON r.customer_id = c.customer_id 
WHERE r.ranking <= 5 ORDER BY r.total_sales ASC;

-- Task 3: Which customers made only one order?
SELECT o.customer_id, c.customer_name, COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) = 1;

-- Task 4: Which customers have above-average sales?
WITH Summary AS (
    SELECT customer_id, SUM(sales) AS total_sales FROM orders GROUP BY customer_id
)
SELECT s.customer_id, c.customer_name, s.total_sales
FROM Summary s
JOIN customers c ON s.customer_id = c.customer_id
WHERE s.total_sales > (SELECT AVG(total_sales) FROM Summary);

-- Task 5: What is the highest order value per customer?
WITH OrderTotals AS (
    SELECT customer_id, order_id, SUM(sales) AS order_value
    FROM orders
    GROUP BY customer_id, order_id
)
SELECT ot.customer_id, c.customer_name, MAX(ot.order_value) AS peak_order_value
FROM OrderTotals ot
JOIN customers c ON ot.customer_id = c.customer_id
GROUP BY ot.customer_id, c.customer_name;
