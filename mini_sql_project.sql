create database retail_store;

use retail_store;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    ncustomersame VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15),
    created_at DATETIME
);
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT,
    added_on DATE
);
-- Create Orders Table
create TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(50),
    total_amount DECIMAL(10,2)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    item_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount_paid DECIMAL(10,2) NOT NULL CHECK (amount_paid > 0),
    method VARCHAR(20) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE product_reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    customer_id INT,
    rating INT NOT NULL,
    review_text TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


-- level 1 BASICS

-- Retrieve customer names and emails for email marketing 

select name , email from customers;

-- View complete product catalog with all available details 

select * from products;

-- List all unique product categories 

select distinct category from products;

-- Show all products priced above ₹1,000 

select * from products where price > 1000;

-- Display products within a mid-range price bracket (₹2,000 to ₹5,000)

select * from products where price between 2000 and 5000;

-- Fetch data for specific customer IDs (e.g., from loyalty program list)

select * from customers where customer_id in (1,2,3);

-- Identify customers whose names start with the letter ‘A’ 

select * from customers where name like 'A%';

-- List electronics products priced under ₹3,000 

select * from products where category = 'electronics' and price < 3000;

-- Display product names and prices in descending order of price 

select name, price from products order by price desc;

-- Display product names and prices, sorted by price and then by name 

select name , price from products order by price desc , name asc;

-- LEVEL 2 FILTERING & FORMATTING

-- Retrieve orders where customer information is missing (possibly due to data migration or deletion) 

select o.* from orders o left join customers c on o.customer_id = c.customer_id where c.customer_id is null;

-- Display customer names and emails using column aliases for frontend readability 

select name as customer_name, email as customer_email from customers;

-- Calculate total value per item ordered by multiplying quantity and item price 

select order_item_id, order_id, product_id, quantity, item_price, quantity * item_price as total_item_value from order_items;

-- Combine customer name and phone number in a single column

SELECT CONCAT(name, ' - ', phone) AS customer_contact
FROM customers;

-- Extract only the date part from order timestamps for date-wise reporting

select order_id, date(order_date) as ordeer_date from orders;

 -- List products that do not have any stock left 

select * from products where stock_quantity = 0;

-- LEVEL 3 AGGREGATIONS

-- Count the total number of orders placed 

select count(*) as total_orders from orders;

--	Calculate the total revenue collected from all orders

select sum(total_amount) as total_revenue from orders;

-- Calculate the average order value 

select avg(total_amount) AS average_order_value FROM ORDERS;

-- Count the number of customers who have placed at least one order 

select count(distinct customer_id) as active_customers from orders
where customer_id is not null;

--	Find the number of orders placed by each customer 

select customer_id, count(*) as total_orders from orders
group by customer_id;

-- Find total sales amount made by each customer 

select customer_id, sum(total_amount) as total_sales from orders
group by customer_id;

--	List the number of products sold per category 

select p.category, sum(oi.quantity) as product_sold from products p
inner join order_items oi on p.product_id = oi.product_id
group by p.category;

-- Find the average item price per category 

select p.category, avg(oi.item_price) as average_item_price from products p 
inner join order_items oi on p.product_id = oi.product_id 
group by p.category;

-- Show number of orders placed per day 

select date(order_date) as order_day, count(*) as total_orders from orders
group by date(order_date)
order by order_day;

-- List total payments received per payment method 

select method, sum(amount_paid) as total_payments from payments
group by method;


-- LEVEL 4 -- JOINS

-- Retrieve order details along with the customer name (INNER JOIN) 

SELECT o.order_id, c.name as customer_name, o.order_date, o.status, o.total_amount
from orders o inner join customers c on o.customer_id =c.customer_id;

-- Get list of products that have been sold (INNER JOIN with order_items) 

select distinct p.product_id, p.name, p.category , p.price from products p inner join order_items oi on p.product_id = oi.product_id;

-- List all orders with their payment method

select o.order_id , o.order_date, o.total_amount, p.method from orders o 
inner join payments p on o.order_id = p.order_id;

-- Get list of customers and their orders 

SELECT c.customer_id,c.name AS customer_name,o.order_id,o.order_date,o.total_amount
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;

--	List all products along with order item quantity (LEFT JOIN) 

SELECT p.product_id,p.name,oi.quantity
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id;

-- List all payments including those with no matching orders 

SELECT p.payment_id,p.order_id,p.amount_paid,p.method,o.order_date
FROM orders o
RIGHT JOIN payments p
    ON o.order_id = p.order_id;

-- Combine data from three tables: customer, order, and payment 

SELECT c.customer_id,c.name AS customer_name,o.order_id,o.order_date,o.total_amount,p.payment_id,p.amount_paid,p.method
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
INNER JOIN payments p
    ON o.order_id = p.order_id;

-- Level 5: Subqueries (Inner Queries) 

-- List all products priced above the average product price

SELECT * FROM products WHERE price > (
    SELECT AVG(price)
    FROM products
);

-- Find customers who have placed at least one order 

SELECT * FROM customers c WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- Show orders whose total amount is above the average for that customer 

SELECT
    o.order_id,
    o.customer_id,
    o.total_amount
FROM orders o
WHERE o.total_amount > (
    SELECT AVG(o2.total_amount)
    FROM orders o2
    WHERE o2.customer_id = o.customer_id
);

-- Display customers who haven’t placed any orders 

SELECT * FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- Show products that were never ordered 

SELECT *
FROM products p
WHERE NOT EXISTS (SELECT 1 FROM order_items oi
    WHERE oi.product_id = p.product_id
);

-- Show highest value order per customer 

SELECT o.customer_id,o.order_id,o.total_amount FROM orders o
WHERE o.total_amount = (SELECT MAX(o2.total_amount)FROM orders o2
    WHERE o2.customer_id = o.customer_id
);

-- Highest Order Per Customer 

SELECT c.name AS customer_name,o.order_id,o.total_amount FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.total_amount = (
    SELECT MAX(o2.total_amount)
    FROM orders o2
    WHERE o2.customer_id = o.customer_id
);

-- LEVEL -- 6 Set Operations

-- List all customers who have either placed an order or written a product review.

SELECT c.customer_id,
       c.name AS customer_name,
       'Placed Order' AS activity
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id

UNION

SELECT c.customer_id,
       c.name AS customer_name,
       'Written Product Review' AS activity
FROM customers c
JOIN product_reviews pr
    ON c.customer_id = pr.customer_id;

-- 	List all customers who have placed an order as well as reviewed a product 

SELECT DISTINCT c.customer_id,
       c.name AS customer_name
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN product_reviews pr
    ON c.customer_id = pr.customer_id;