/* Restaurant Order Analysis -- A Maven Analytics Project*/
/* Analyze order data to identify the most and least popular menu items and types of cuisine */
 
USE restaurant_db;
 
 -- OBJECTIVE-1: Explore the items table
 
 -- 1. View the menu_items table and write a query to find the number of items on the menu
SELECT * FROM menu_items;
SELECT COUNT(DISTINCT item_name) AS number_of_items  FROM menu_items;

-- 2.What are the least and most expensive items on the menu?
SELECT item_name AS least_expensive_item,price
FROM menu_items
ORDER BY price;

SELECT item_name AS most_expensive_item,price
FROM menu_items
ORDER BY price DESC LIMIT 1;

-- 3.How many Italian dishes are on the menu? What are the least and most expensive Italian dishes on the menu?
SELECT COUNT(item_name) AS italian_items
FROM menu_items 
WHERE category = 'Italian';

SELECT item_name AS most_expensive_item, price
FROM menu_items
WHERE category = 'Italian'
ORDER BY price DESC LIMIT 1;

SELECT item_name AS most_expensive_item, price
FROM menu_items 
WHERE category = 'Italian'
ORDER BY price LIMIT 1;

-- 4.How many dishes are in each category? What is the average dish price within each category?
SELECT category,
	COUNT(menu_item_id) item_No,
    AVG(PRICE) avg_price
FROM menu_items
GROUP BY category;

-- OBJECTIVE 2: Explore the orders table
-- 1.View the order_details table. What is the date range of the table?
SELECT * FROM order_details;
SELECT MIN(order_date) as min_date,
	MAX(order_date) as max_date
FROM order_details;

-- 2.How many orders were made within this date range? How many items were ordered within this date range?
SELECT
	COUNT(DISTINCT order_id) orders_made,
	COUNT(item_id) items_ordered
FROM order_details;
-- There are some null item_id present in the table, thus number of rows differs from number of items ordered

-- 3.Which orders had the most number of items?
SELECT 
	order_id,
	COUNT(item_id) AS num_itmes
FROM order_details
GROUP BY order_id
ORDER BY 2 DESC;

-- 4.How many orders had more than 12 items?
SELECT COUNT(*) AS orders_w_morethan12items
FROM 
(SELECT 
	order_id,
	COUNT(item_id) AS num_itmes
FROM order_details
GROUP BY order_id
HAVING num_itmes>12) as high_item_orders;


-- OBJECTIVE 3 Analyze customer behavior

-- 1.Combine the menu_items and order_details tables into a single table
SELECT 	* FROM menu_items;
SELECT 	* FROM order_details;

SELECT 	*
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id=mi.menu_item_id;		
        
-- 2.What were the least and most ordered items? What categories were they in?
SELECT 	
	item_name,
    category,
	COUNT(DISTINCT order_details_id) num_orders
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id=mi.menu_item_id
GROUP BY item_name,category
ORDER BY num_orders DESC;	

-- 3.What were the top 5 orders that spent the most money?
SELECT 	
	order_id,
    SUM(price) as order_price
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id=mi.menu_item_id
GROUP BY order_id
ORDER BY 2 DESC LIMIT 5;

-- 4.View the details of the highest spend order. Which specific items were purchased?
 DROP TABLE IF EXISTS top_5_orders;
 CREATE TEMPORARY TABLE top_5_orders
 SELECT 	
	order_id
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id=mi.menu_item_id
GROUP BY order_id
ORDER BY SUM(price) DESC LIMIT 5;

SELECT 	* FROM top_5_orders;

SELECT 	
category,
COUNT(order_details_id) orders,
SUM(price) total_price,
SUM(price)/COUNT(order_details_id) avg_price_per_order
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id=mi.menu_item_id
WHERE order_id = 
( SELECT 	
	order_id
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id=mi.menu_item_id
GROUP BY order_id
ORDER BY SUM(price) DESC LIMIT 1)
GROUP BY category;

-- 5. View the details of the top 5 highest spend orders
SELECT 	
	order_id,
    category,
    COUNT(order_details_id) num_orders,
    SUM(price) total_price
FROM order_details od
	LEFT JOIN menu_items mi
		ON od.item_id=mi.menu_item_id
WHERE order_id IN 
(SELECT order_id FROM top_5_orders)
GROUP BY order_id,category
ORDER BY 1,3 DESC;
