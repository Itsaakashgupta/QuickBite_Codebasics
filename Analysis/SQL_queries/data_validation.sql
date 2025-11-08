-- stg_fact_orders checks
SELECT * FROM stg_fact_orders LIMIT 20;

-- Check for duplicate order_id values
SELECT order_id, COUNT(*)
FROM stg_fact_orders
GROUP BY 1
HAVING COUNT(*) > 1;

-- Check for orders with customer_id not present in stg_dim_customer
SELECT DISTINCT f.customer_id
FROM stg_fact_orders f
LEFT JOIN stg_dim_customer c ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check for orders with restaurant_id not present in stg_dim_restaurant
SELECT DISTINCT f.restaurant_id
FROM stg_fact_orders f
LEFT JOIN stg_dim_restaurant r ON f.restaurant_id = r.restaurant_id
WHERE r.restaurant_id IS NULL;

-- Check for not recorded order_timestamp values
SELECT order_timestamp
FROM stg_fact_orders
WHERE order_timestamp NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}';

-- Check for negative total_amount values
SELECT COUNT(*)
FROM stg_fact_orders
WHERE CAST(total_amount AS DECIMAL(10, 2)) < 0;

-- Check for total_amount not equal to subtotal_amount - discount_amount + delivery_fee
SELECT COUNT(*) FROM stg_fact_orders
WHERE ABS(CAST(total_amount AS DECIMAL(10, 2)) - 
      (CAST(subtotal_amount AS DECIMAL(10, 2)) - CAST(discount_amount AS DECIMAL(10, 2)) +
      CAST(delivery_fee AS DECIMAL(10, 2)))) > 0.01;

-- Check for missing order_id values
SELECT COUNT(*) FROM stg_fact_orders
WHERE order_id IS NULL OR order_id = '';

-- Check for invalid values in is_code and is_cancelled columns
SELECT COUNT(*)
FROM stg_fact_orders
WHERE (is_code NOT IN ('Y','N') OR is_code IS NULL)
AND (is_cancelled NOT IN ('Y','N') OR is_cancelled IS NULL);


-- stg_fact_order_items checks
SELECT * FROM stg_fact_order_items LIMIT 20;

-- Check for duplicate records in fact_order_items
SELECT order_id, item_id, COUNT(*) AS item_count
FROM stg_fact_order_items
GROUP BY order_id, item_id
HAVING item_count > 1;

-- Check for order_id values not present in stg_fact_orders
SELECT f.order_id
FROM stg_fact_order_items f
LEFT JOIN stg_fact_orders o ON f.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Check for quantity values less than or equal to zero
SELECT COUNT(*)
FROM stg_fact_order_items
WHERE CAST(quantity AS SIGNED) <= 0;

-- Check for (quantity * unit_price) - item_discount not equal to line_total
SELECT COUNT(*)
FROM stg_fact_order_items
WHERE ABS(CAST(line_total AS DECIMAL(10, 2)) - 
        (CAST(quantity AS SIGNED) * CAST(unit_price AS DECIMAL(10, 2))) - 
        CAST(item_discount AS DECIMAL(10, 2))) > 0.01;
      

-- Check for quantity values with non-numeric characters
SELECT COUNT(*) 
FROM stg_fact_order_items 
WHERE quantity NOT REGEXP '^[0-9]+$';

-- Check for line_total values less than or equal to zero
SELECT COUNT(*)
FROM stg_fact_order_items
WHERE CAST(line_total AS DECIMAL(10, 2)) <= 0;

-- Check for menu_item_id values not present in stg_dim_menu_item
SELECT f.menu_item_id
FROM stg_fact_order_items f
LEFT JOIN stg_dim_menu_item m ON f.menu_item_id = m.menu_item_id
WHERE m.menu_item_id IS NULL;


-- stg_fact_ratings checks
SELECT * FROM stg_fact_ratings LIMIT 20;

-- Check for order_id which are more than once.
SELECT order_id, COUNT(*)   
FROM stg_fact_ratings
WHERE order_id IS NOT NULL
GROUP BY 1
HAVING COUNT(*) > 1;

-- Remove records with empty order_id values
DELETE FROM stg_fact_ratings
WHERE order_id IS NOT NULL
AND TRIM(order_id) = '';

-- Check for order_id values not present in fact_orders
SELECT r.order_id
FROM stg_fact_ratings r
LEFT JOIN fact_orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL AND r.order_id IS NOT NULL;

-- Check for invalid review_timestamp values
SELECT COUNT(*)
FROM stg_fact_ratings
WHERE STR_TO_DATE(review_timestamp, '%d-%m-%Y %H:%i') IS NULL AND review_timestamp IS NOT NULL;

-- Check for rating values not between 1.0 and 5.0
SELECT COUNT(*)
FROM stg_fact_ratings
WHERE CAST(rating AS DECIMAL(2, 1)) NOT BETWEEN 1.0 AND 5.0;

-- Check for sentiment_score values not between -1.0 and 1.0
SELECT COUNT(*)
FROM stg_fact_ratings
WHERE CAST(sentiment_score AS DECIMAL(2, 1)) NOT BETWEEN -1.0 AND 1.0;


-- stg_fact_delivery_performance checks
SELECT * FROM stg_fact_delivery_performance LIMIT 20;

-- Check for duplicate order_id values
SELECT order_id, COUNT(*)
FROM stg_fact_delivery_performance
GROUP BY 1
HAVING COUNT(*) > 1;

-- Check for order_id values not present in fact_orders
SELECT p.order_id
FROM stg_fact_delivery_performance p
LEFT JOIN fact_orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Check for invalid scheduled_delivery_time values
SELECT COUNT(*)
FROM stg_fact_delivery_performance
WHERE CAST(actual_delivery_time_mins AS SIGNED) < 0;

-- Check for negative distance_km values
SELECT COUNT(*)
FROM stg_fact_delivery_performance
WHERE CAST(distance_km AS DECIMAL(4, 2)) < 0;


-- stg_dim_customer checks
SELECT * FROM stg_dim_customer LIMIT 20;

-- Check for duplicate customer_id values
SELECT customer_id, COUNT(*)
FROM stg_dim_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Check for missing or invalid signup_date values
SELECT COUNT(*) FROM stg_dim_customer
WHERE STR_TO_DATE(signup_date, '%d-%m-%Y') IS NULL;

-- Check for different acquisition_channel values from the predefined list
SELECT DISTINCT acquisition_channel
FROM stg_dim_customer
WHERE acquisition_channel NOT IN ('Organic', 'Referral', 'Paid', 'Social');


-- stg_dim_restaurant checks
SELECT * FROM stg_dim_restaurant LIMIT 20;

-- Check for duplicate restaurant_id values
SELECT restaurant_id, COUNT(*)
FROM stg_dim_restaurant
GROUP BY restaurant_id
HAVING COUNT(*) > 1;

-- Check for missing restaurant_name values
SELECT COUNT(*)
FROM stg_dim_restaurant
WHERE restaurant_name IS NULL OR restaurant_name = '';

-- Check for different cuisine_type values from the predefined list
SELECT DISTINCT cuisine_type
FROM stg_dim_restaurant
WHERE cuisine_type NOT IN ('Chinese', 'Fast Food', 'North Indian', 'Pizza', 'Healthy', 'South Indian', 'Biryani', 'Desserts');

-- Check for different partner_type values from the predefined list
SELECT partner_type, COUNT(*)
FROM stg_dim_restaurant
GROUP BY partner_type;

-- Check for avg_prep_time_mins values from the predefined list
SELECT avg_prep_time_mins, COUNT(*)
FROM stg_dim_restaurant
GROUP BY avg_prep_time_mins;

-- Check for truncated is_active values
SELECT DISTINCT is_active
FROM stg_dim_restaurant
WHERE is_active NOT IN ('Y','N') OR is_active IS NULL;


-- stg_dim_delivery_partner checks
SELECT * FROM stg_dim_delivery_partner LIMIT 20;

-- Check for duplicate delivery_partner_id values
SELECT delivery_partner_id, COUNT(*)
FROM stg_dim_delivery_partner
GROUP BY delivery_partner_id
HAVING COUNT(*) > 1;

-- Check for any incorrect avg_rating values
SELECT avg_rating
FROM stg_dim_delivery_partner
WHERE CAST(avg_rating AS DECIMAL(2, 1)) NOT BETWEEN 1.0 AND 5.0;

-- Check for different vehicle_type values from the predefined list
SELECT DISTINCT vehicle_type
FROM stg_dim_delivery_partner
WHERE vehicle_type NOT IN ('Bike', 'Car', 'Scooter', 'Cycle');

-- Check for missing partner_name values
SELECT *
FROM stg_dim_delivery_partner
WHERE partner_name IS NULL OR partner_name = '';

-- Check for truncated is_active values
SELECT DISTINCT is_active
FROM stg_dim_delivery_partner
WHERE is_active NOT IN ('Y','N') OR is_active IS NULL;

-- Check for different employment_type values from the predefined list
SELECT DISTINCT employment_type
FROM stg_dim_delivery_partner
WHERE employment_type NOT IN ('Full-time', 'Part-time', 'Contract');


-- stg_dim_menu_item checks
SELECT * FROM stg_dim_menu_item LIMIT 20;

-- Check for duplicate menu_item_id values
SELECT menu_item_id, COUNT(*)
FROM stg_dim_menu_item
GROUP BY menu_item_id
HAVING COUNT(*) > 1;

-- Check for restaurant_id values not present in stg_dim_restaurant
SELECT i.restaurant_id
FROM stg_dim_menu_item i
LEFT JOIN stg_dim_restaurant r ON i.restaurant_id = r.restaurant_id
WHERE r.restaurant_id IS NULL;

-- Check for negative or zero price values
SELECT COUNT(*)
FROM stg_dim_menu_item
WHERE CAST(price AS DECIMAL(7, 2)) <= 0;

-- Check for category values from the predefined list
SELECT DISTINCT category 
FROM stg_dim_menu_item;


