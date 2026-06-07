-- ==============================================================================
-- ASSIGNMENT: SQL Basics, Filtering, Aggregation, Joins & Advanced Concepts
-- Dataset Context: Ecommerce / Superstore Schema
-- File: sql_assignment_solutions.sql
-- ==============================================================================

-- ==============================================================================
-- SECTION A — SQL Basics (SELECT, Constraints, Primary Keys)
-- These questions test understanding of basic data retrieval, table structure, 
-- and database constraints.
-- ==============================================================================

-- Q1. Write a query to display all columns and rows from the customer's table.
SELECT * FROM customers;

-- Q2. Retrieve only the first_name, last_name, and city of all customers.
SELECT first_name, last_name, city 
FROM customers;

-- Q3. List all unique categories available in the products table.
SELECT DISTINCT category 
FROM products;

-- Q4. Identify the Primary Key of each table in the schema. Explain why a 
--     Primary Key must be unique and NOT NULL.
/*
Answer:
Based on standard relational database configurations for ecommerce/superstore datasets:
  - Table 'customers'   -> Primary Key: customer_id
  - Table 'products'    -> Primary Key: product_id
  - Table 'orders'      -> Primary Key: order_id
  - Table 'order_items' -> Primary Key: order_item_id (or composite key: order_id, product_id)

Explanation:
  - UNIQUE Constraint: Ensures that every row in the table has a distinct identity. 
    Without uniqueness, duplicate records could exist, making data modification (updates/deletions) 
    ambiguous and unreliable.
  - NOT NULL Constraint: A Primary Key serves as a reliable locator and identifier. 
    A NULL value indicates missing or unknown information. An identifier cannot be unknown, 
    otherwise, the system cannot verify or enforce entity integrity.
*/

-- Q5. What constraints are applied to the email column in the customers table? 
--     What would happen if you tried to insert a duplicate email?
/*
Answer:
The 'email' column typically carries BOTH the 'NOT NULL' and 'UNIQUE' constraints.

Behavior on Duplicate Insertion:
If an INSERT statement attempts to supply an email address that already exists in the 
table, the Relational Database Management System (RDBMS) will intercept the command, 
prevent execution, and throw a "Unique Constraint Violation Error" (e.g., Error 1062 
in MySQL: Duplicate entry for key 'email'). No data will be written to the database.
*/

-- Q6. Try inserting a product with unit_price = -50. What happens and which 
--     constraint prevents it? Write both the INSERT statement and explain the error.

-- INSERT Statement:
INSERT INTO products (product_id, product_name, category, unit_price, stock_qty)
VALUES (999, 'Invalid Price Item', 'Electronics', -50.00, 10);

/*
Explanation of Error:
Execution of this query will fail due to a CHECK constraint Violation 
(e.g., CHECK (unit_price >= 0)). Relational databases utilize CHECK constraints 
to govern domain integrity, confirming that numeric values fall within logical, 
real-world business parameters. The database engine rejects the entry with an error 
such as: "Check constraint 'chk_unit_price' is violated."
*/


-- ==============================================================================
-- SECTION B — Filtering & Optimization (WHERE, Indexes)
-- These questions test your ability to filter data effectively and understand 
-- how indexes improve query performance.
-- ==============================================================================

-- Q7. Retrieve all orders with status = 'Delivered'.
SELECT * FROM orders 
WHERE status = 'Delivered';

-- Q8. Find all products in the 'Electronics' category with a unit_price greater than ₹2000.
SELECT * FROM products 
WHERE category = 'Electronics' 
  AND unit_price > 2000;

-- Q9. List all customers who joined in the year 2024 and belong to the state 'Maharashtra'.
SELECT * FROM customers 
WHERE join_date >= '2024-01-01' 
  AND join_date <= '2024-12-31' 
  AND state = 'Maharashtra';

-- Q10. Find all orders placed between '2024-08-10' and '2024-08-25' (inclusive) that are NOT cancelled.
SELECT * FROM orders 
WHERE order_date BETWEEN '2024-08-10' AND '2024-08-25'
  AND status <> 'Cancelled';

-- Q11. Explain what the index idx_orders_date does. How would it improve the 
--     performance of a query that filters orders by order_date? Write a sample query.
/*
Explanation:
The index 'idx_orders_date' establishes a sorted B-Tree structure of 'order_date' values linked 
to their physical row identifiers. Instead of performing a "Full Table Scan" (reading every data block 
from disk to identify matching dates), the query planner navigates the tree logarithmically. 
This dramatically lowers disk I/O operations and speeds up calculation.
*/

-- Sample Query benefiting from idx_orders_date:
SELECT order_id, customer_id, total_amount 
FROM orders 
WHERE order_date = '2024-08-15';


-- Q12. If you run: SELECT * FROM customers WHERE YEAR(join_date) = 2024; 
--     — would the index on join_date be used? Explain why or why not, 
--     and rewrite the query to be index-friendly (SARGable).
/*
Explanation:
No, the index will NOT be effectively used. Wrapping the 'join_date' column inside a 
scalar function like YEAR() prevents the query planner from performing an index seek. The engine must 
evaluate the function for every row in the table, resulting in a full table scan. This makes the expression 
Non-SARGable (Search Argument Able).
*/

-- Index-friendly (SARGable) Rewrite:
SELECT * FROM customers 
WHERE join_date >= '2024-01-01' 
  AND join_date < '2025-01-01';


-- ==============================================================================
-- SECTION C — Aggregation (GROUP BY, SUM, COUNT, AVG, MIN, MAX)
-- These questions test your ability to summarize and aggregate data.
-- ==============================================================================

-- Q13. Count the total number of orders in the orders table.
SELECT COUNT(order_id) AS total_orders 
FROM orders;

-- Q14. Find the total revenue (SUM of total_amount) from all 'Delivered' orders.
SELECT SUM(total_amount) AS total_revenue 
FROM orders 
WHERE status = 'Delivered';

-- Q15. Calculate the average unit_price of products in each category.
SELECT category, AVG(unit_price) AS avg_unit_price 
FROM products 
GROUP BY category;

-- Q16. For each order status, find the count of orders and the total revenue. 
--      Sort the result by total revenue in descending order.
SELECT 
    status, 
    COUNT(order_id) AS order_count, 
    SUM(total_amount) AS total_revenue
FROM orders 
GROUP BY status
ORDER BY total_revenue DESC;

-- Q17. Find the most expensive (MAX) and cheapest (MIN) product in each category.
SELECT 
    category, 
    MAX(unit_price) AS most_expensive_price, 
    MIN(unit_price) AS cheapest_price
FROM products 
GROUP BY category;

-- Q18. List all product categories where the average unit_price is greater than ₹2000.
SELECT category, AVG(unit_price) AS avg_unit_price 
FROM products 
GROUP BY category
HAVING AVG(unit_price) > 2000;


-- ==============================================================================
-- SECTION D — Joins & Relationships
-- These questions test your ability to combine data from multiple tables using 
-- different types of JOINs.
-- ==============================================================================

-- Q19. Write an INNER JOIN query to display each order along with the customer's 
--      first_name and last_name. Show: order_id, order_date, first_name, last_name, total_amount.
SELECT 
    o.order_id, 
    o.order_date, 
    c.first_name, 
    c.last_name, 
    o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;

-- Q20. Using a LEFT JOIN, list ALL customers and their orders (if any). 
--      Customers with no orders should still appear with NULL values for order columns.
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    o.order_id, 
    o.order_date, 
    o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Q21. Write a query using JOINs across three tables (orders → order_items → products) 
--      to show: order_id, product_name, quantity, unit_price, and discount_pct.
SELECT 
    oi.order_id, 
    p.product_name, 
    oi.quantity, 
    oi.unit_price, 
    oi.discount_pct
FROM order_items oi
INNER JOIN orders o ON oi.order_id = o.order_id
INNER JOIN products p ON oi.product_id = p.product_id;

-- Q22. Explain the difference between LEFT JOIN and RIGHT JOIN with an example from this schema. 
--      When would you use a FULL OUTER JOIN?
/*
Explanation:
  - LEFT JOIN: Preserves all records from the "Left" table, attempting to map matching rows from 
    the "Right" table. If no match exists, NULLs populate the right side.
    Example: `FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id` 
    Includes EVERY customer, even those without purchases.
  - RIGHT JOIN: Preserves all records from the "Right" table, matching from the "Left". 
    Example: `FROM customers c RIGHT JOIN orders o ON c.customer_id = o.customer_id`
    Guarantees every order row appears, even if structural mutations left an unmapped customer.
  - FULL OUTER JOIN usage: Utilized when you must compile a complete landscape of both datasets 
    regardless of common links—such as analyzing a master inventory list against an active promotion campaign 
    to see unlinked items on both ends.
*/

-- Q23. Identify all Foreign Key relationships in the schema. Explain what would happen 
--      if you tried to insert an order with customer_id = 999 (which doesn't exist).
/*
Identified Foreign Keys:
  - orders.customer_id references customers.customer_id
  - order_items.order_id references orders.order_id
  - order_items.product_id references products.product_id

Behavior on inserting customer_id = 999:
The insertion will fail. The relational engine strictly monitors Referential Integrity via Foreign Key 
constraints. It prevents an entity creation that references a non-existent corporate parent anchor. 
The database will halt execution and emit a "Foreign Key Constraint Violation Error".
*/


-- ==============================================================================
-- SECTION E — Advanced Concepts (CASE, ACID, Transactions)
-- These questions test understanding of conditional logic, database reliability 
-- principles, and transaction management.
-- ==============================================================================

-- Q24. Write a query using CASE to classify products into price tiers:
--   • 'Budget'    → unit_price < 1000
--   • 'Mid-Range' → unit_price BETWEEN 1000 AND 3000
--   • 'Premium'   → unit_price > 3000
SELECT 
    product_name, 
    unit_price,
    CASE 
        WHEN unit_price < 1000 THEN 'Budget'
        WHEN unit_price BETWEEN 1000 AND 3000 THEN 'Mid-Range'
        WHEN unit_price > 3000 THEN 'Premium'
    END AS price_tier
FROM products;

-- Q25. Using a CASE statement inside an aggregate function, count how many orders 
--      are 'Delivered' vs 'Not Delivered' (all other statuses). Display in a single row.
SELECT 
    COUNT(CASE WHEN status = 'Delivered' THEN 1 END) AS delivered_count,
    COUNT(CASE WHEN status <> 'Delivered' THEN 1 END) AS not_delivered_count
FROM orders;

-- Q26. Explain each letter of ACID using a real-world bank transfer example.
/*
Bank Transfer Example: Sending ₹1,000 from Account A to Account B.
  - A (Atomicity): "All-or-Nothing". The deduction from Account A and the credit to Account B 
    must succeed together. If the database crashes mid-execution, the step rolls back entirely 
    so money does not disappear into a vacuum.
  - C (Consistency): The system must transit from one valid state to another, upholding all constraints. 
    The total combined funds of A and B must match before and after the transfer process.
  - I (Isolation): Independent execution. If multiple users execute transactions at the exact same instant, 
    their computations remain completely isolated. Account A's state mid-transfer won't taint 
    unrelated operations.
  - D (Durability): Absolute permanence. Once the client receives a "Transaction Complete" notification, 
    the financial statements are physically persisted. Even an abrupt hardware or power crash 
    immediately after won't wipe out the record.
*/

-- Q27. Write a SQL transaction that does the following atomically:
--   1. Insert a new order (order_id=1011, customer_id=102, today's date, 'Pending', 1598.00)
--   2. Insert two order items for that order
--   3. Update the stock_qty of the purchased products
--   4. If any step fails, ROLLBACK the entire transaction. Otherwise, COMMIT.

-- Implementation using robust TRY...CATCH block control flow (Standard T-SQL syntax)
BEGIN TRANSACTION;

BEGIN TRY
    -- 1. Insert a new order record
    INSERT INTO orders (order_id, customer_id, order_date, status, total_amount)
    VALUES (1011, 102, CAST(GETDATE() AS DATE), 'Pending', 1598.00);

    -- 2. Insert two order items associated with order 1011
    INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct)
    VALUES (1011, 15, 1, 999.00, 0.0),
           (1011, 22, 1, 599.00, 0.0);

    -- 3. Update the stock quantity configurations of the purchased items
    UPDATE products 
    SET stock_qty = stock_qty - 1 
    WHERE product_id = 15;

    UPDATE products 
    SET stock_qty = stock_qty - 1 
    WHERE product_id = 22;

    -- 4. If all operations execute seamlessly, finalize changes
    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully.';
END TRY
BEGIN CATCH
    -- On any procedural error, rollback database states completely
    ROLLBACK TRANSACTION;
    PRINT 'Transaction failed and rolled back.';
    
    -- Rethrow error back to caller
    THROW;
END CATCH;
-- ==============================================================================
