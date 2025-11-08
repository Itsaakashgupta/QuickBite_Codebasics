SELECT * FROM fact_orders LIMIT 25;
SELECT * FROM fact_order_items LIMIT 25;
SELECT * FROM fact_ratings LIMIT 25;
SELECT * FROM fact_delivery_performance LIMIT 25;
SELECT * FROM dim_restaurant LIMIT 25;
SELECT * FROM dim_customer LIMIT 25;
SELECT * FROM dim_menu_item LIMIT 25;
SELECT * FROM dim_delivery_partner LIMIT 25;


-- Delete records from fact_orders where customer_id does not exist in dim_customer
-- or where total_amount is zero
DELETE f
FROM fact_orders f
LEFT JOIN dim_customer c ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Delete records from fact_order_items where order_id does not exist in fact_orders
DELETE foi
FROM fact_order_items foi
LEFT JOIN fact_orders fo ON foi.order_id = fo.order_id
WHERE fo.order_id IS NULL;


-- Add a new column 'phase' to fact_orders and populate it based on order_timestamp
ALTER TABLE fact_orders ADD COLUMN phase VARCHAR(20);

UPDATE fact_orders
SET phase = CASE
               WHEN order_timestamp BETWEEN '2025-01-01' AND '2025-05-31 23:59:59' THEN 'Pre-Crisis'
               WHEN order_timestamp BETWEEN '2025-06-01' AND '2025-09-30 23:59:59' THEN 'Crisis'
               ELSE 'Post-Crisis'
END;


-- Add a new column 'order_month' to fact_orders and populate it with the month and year.
ALTER TABLE fact_orders
ADD COLUMN order_month VARCHAR(7) NOT NULL;

UPDATE fact_orders
SET order_month = DATE_FORMAT(order_timestamp, '%Y-%m');


-- Add a new column 'sla_diff' to fact_delivery_performance and populate it with the difference
ALTER TABLE fact_delivery_performance
ADD COLUMN sla_diff SMALLINT;

UPDATE fact_delivery_performance
SET sla_diff = CAST(actual_delivery_time_mins AS SIGNED) - CAST(expected_delivery_time_mins AS SIGNED);

