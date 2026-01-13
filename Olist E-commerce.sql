USE olist_store_analysis;

select count(review_id) from reviews;

-- 1) Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics

SELECT Kpi1.`Day type`,
CONCAT(ROUND(
Kpi1.total_payments / (SELECT SUM(payment_value) FROM order_payments) * 100,2),' %') AS `Payment Values (%)`
FROM (SELECT ord.`Day type`, SUM(pmt.payment_value) AS total_payments
FROM order_payments AS pmt
JOIN (SELECT DISTINCT order_id, CASE
WHEN WEEKDAY(order_purchase_timestamp) IN (5,6) 
THEN 'Weekend'ELSE 'Weekday'
END AS `Day type`
FROM orders ) AS ord ON ord.order_id = pmt.order_id
GROUP BY ord.`Day type`) AS Kpi1;

-- 2) Number of Orders with review score 5 and payment type as credit card.

SELECT FORMAT(COUNT(pmt.order_id), 0) AS `Total Orders`
FROM order_payments pmt
INNER JOIN reviews rev
ON pmt.order_id = rev.order_id
WHERE rev.review_score = 5
AND pmt.payment_type = 'Credit_Card';

-- 3) Average number of days taken for order_delivered_customer_date for pet_shop

SELECT p.product_category_name AS `Product category name`,
CONCAT(ROUND(AVG(DATEDIFF(ord.order_delivered_customer_date,ord.order_purchase_timestamp))),' Days') AS `Avg delivery days`
FROM orders ord
JOIN order_items oi
ON ord.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
WHERE p.product_category_name = 'pet_shop'
AND ord.order_delivered_customer_date IS NOT NULL
GROUP BY p.product_category_name;

-- 4) Average price and payment values from customers of sao paulo city

SELECT
ROUND(AVG(oi.price)) AS `Avg order item price`,
ROUND(AVG(pmt.payment_value)) AS `Avg payment value`
FROM orders ord
JOIN customers c
ON ord.customer_id = c.customer_id
JOIN order_items oi
ON ord.order_id = oi.order_id
JOIN order_payments pmt
ON ord.order_id = pmt.order_id
WHERE c.customer_city = 'sao paulo';

-- 5) Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores

SELECT CONCAT(REPEAT('★', r.review_score),' (',r.review_score,')') AS `Review Stars`,
ROUND(AVG(DATEDIFF(ord.order_delivered_customer_date, ord.order_purchase_timestamp)),0) AS `Avg shipping days`
FROM orders ord
JOIN reviews r
ON r.order_id = ord.order_id
WHERE ord.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;
