-- DDL for the final fact_orders table
CREATE TABLE fact_orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    restaurant_id VARCHAR(20) NOT NULL,
    delivery_partner_id VARCHAR(20) NULL, -- Allow NULL, as per data inspection (some rows are missing a DP)
    order_timestamp DATETIME NOT NULL,
    -- Numeric/Monetary Columns
    subtotal_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    delivery_fee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    -- Flag Columns
    is_code ENUM('Y', 'N') NOT NULL DEFAULT 'N',
    is_cancelled ENUM('Y', 'N') NOT NULL DEFAULT 'N',
    -- Indexes (for query performance and Joins)
    INDEX idx_customer (customer_id),
    INDEX idx_restaurant (restaurant_id),
    INDEX idx_delivery_partner (delivery_partner_id),
    INDEX idx_order_ts (order_timestamp)
)
-- ALTER TABLE fact_orders ADD FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id);

INSERT INTO fact_orders (order_id, customer_id, restaurant_id, delivery_partner_id, order_timestamp, subtotal_amount, discount_amount, delivery_fee, total_amount, is_code, is_cancelled)
SELECT
    order_id,
    customer_id,
    restaurant_id,
    delivery_partner_id,
    STR_TO_DATE(order_timestamp, '%Y-%m-%d %H:%i:%s') AS order_timestamp,
    CAST(subtotal_amount AS DECIMAL(10, 2)) AS subtotal_amount,
    CAST(discount_amount AS DECIMAL(10, 2)) AS discount_amount,
    CAST(delivery_fee AS DECIMAL(10, 2)) AS delivery_fee,
    CAST(total_amount AS DECIMAL(10, 2)) AS total_amount,
    is_code,
    is_cancelled
FROM stg_fact_orders;


-- DDL for the final fact_order_items table
CREATE TABLE fact_order_items (
    order_id VARCHAR(20) NOT NULL,
    item_id VARCHAR(10) NOT NULL,
    menu_item_id VARCHAR(30) NOT NULL,
    restaurant_id VARCHAR(20) NOT NULL,
    -- Numerical Fields
    quantity SMALLINT NOT NULL DEFAULT 1, -- Using SMALLINT for smaller integer values
    unit_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    item_discount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    line_total DECIMAL(10, 2) NOT NULL,
    -- Define the Composite Primary Key
    PRIMARY KEY (order_id, item_id),
    -- Indexes (for Joins and Lookups)
    INDEX idx_menuitem (menu_item_id),
    INDEX idx_restaurant (restaurant_id)
);

INSERT INTO fact_order_items (order_id, item_id, menu_item_id, restaurant_id, quantity, unit_price, item_discount, line_total)
SELECT
    order_id,
    item_id,
    menu_item_id,
    restaurant_id,
    CAST(quantity AS UNSIGNED) AS quantity,
    CAST(unit_price AS DECIMAL(10, 2)) AS unit_price,
    CAST(item_discount AS DECIMAL(10, 2)) AS item_discount,
    CAST(line_total AS DECIMAL(10, 2)) AS line_total
FROM stg_fact_order_items;
-- ALTER TABLE fact_order_items ADD FOREIGN KEY (order_id) REFERENCES fact_orders(order_id);
-- ALTER TABLE fact_order_items ADD FOREIGN KEY (menu_item_id) REFERENCES dim_menu_item(menu_item_id);


-- DDL for the final fact_ratings table
DROP TABLE IF EXISTS fact_ratings;
CREATE TABLE fact_ratings (
    order_id VARCHAR(20) PRIMARY KEY,
    -- Foreign Keys
    customer_id VARCHAR(20) NOT NULL,
    restaurant_id VARCHAR(20) NOT NULL,
    rating DECIMAL(3, 1) NOT NULL,      
    review_text VARCHAR(100) NULL, 
    review_timestamp DATETIME NOT NULL,
    sentiment_score DECIMAL(3, 2) NULL, 
    -- Indexes
    INDEX idx_customer (customer_id),
    INDEX idx_restaurant (restaurant_id),
    INDEX idx_review_ts (review_timestamp)
);

INSERT INTO fact_ratings (order_id, customer_id, restaurant_id, rating, review_text, review_timestamp, sentiment_score)
SELECT
    order_id,
    customer_id,
    restaurant_id,
    CAST(rating AS DECIMAL(3, 1)),
    review_text,
    CASE WHEN review_timestamp REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4} [0-9]{2}:[0-9]{2}$' 
         THEN STR_TO_DATE(review_timestamp, '%d-%m-%Y %H:%i')
         WHEN review_timestamp REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}$' 
         THEN STR_TO_DATE(review_timestamp, '%Y/%m/%d %H:%i')
         ELSE NULL
    END AS review_timestamp,
    CAST(sentiment_score AS DECIMAL(3, 2)) AS sentiment_score
FROM stg_fact_ratings;
-- ALTER TABLE fact_ratings ADD FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id);


-- DDL for the final fact_delivery_performance table

CREATE TABLE fact_delivery_performance (
    order_id VARCHAR(20) PRIMARY KEY,
    actual_delivery_time_mins SMALLINT UNSIGNED NOT NULL, -- UNSIGNED ensures non-negative storage
    expected_delivery_time_mins SMALLINT UNSIGNED NOT NULL,
    -- Distance Metric
    distance_km DECIMAL(4, 1) NOT NULL, -- e.g., 999.9 km maximum
    -- Indexes
    INDEX idx_actual_time (actual_delivery_time_mins),
    INDEX idx_expected_time (expected_delivery_time_mins)
    -- Note: Foreign Key constraint is critical here
    -- FOREIGN KEY (order_id) REFERENCES fact_orders(order_id)
);

INSERT INTO fact_delivery_performance (order_id, actual_delivery_time_mins, expected_delivery_time_mins, distance_km)
SELECT
    order_id,
    CAST(actual_delivery_time_mins AS UNSIGNED) AS actual_delivery_time_mins,
    CAST(expected_delivery_time_mins AS UNSIGNED) AS expected_delivery_time_mins,
    CAST(distance_km AS DECIMAL(4, 1)) AS distance_km
FROM stg_fact_delivery_performance;
-- ALTER TABLE fact_delivery_performance ADD FOREIGN KEY (order_id) REFERENCES fact_orders(order_id);


-- DDL for the final dim_customer table

CREATE TABLE dim_customer (
    customer_id VARCHAR(20) PRIMARY KEY,
    signup_date DATE NOT NULL,
    city VARCHAR(20) NOT NULL,
    -- Using ENUM for strict control over categorical data
    acquisition_channel ENUM('Organic', 'Referral', 'Paid', 'Social') NOT NULL, 
    -- Indexes
    INDEX idx_city (city),
    INDEX idx_signup_date (signup_date) 
);

INSERT INTO dim_customer (customer_id, signup_date, city, acquisition_channel)
SELECT
   customer_id,
   STR_TO_DATE(signup_date, '%d-%m-%Y') AS signup_date,
   city,
   CASE 
        WHEN TRIM(REPLACE(REPLACE(acquisition_channel, '\r', ''), '\n', '')) = 'Organic' THEN 'Organic'
        WHEN TRIM(REPLACE(REPLACE(acquisition_channel, '\r', ''), '\n', '')) = 'Referral' THEN 'Referral'
        WHEN TRIM(REPLACE(REPLACE(acquisition_channel, '\r', ''), '\n', '')) = 'Paid' THEN 'Paid'
        WHEN TRIM(REPLACE(REPLACE(acquisition_channel, '\r', ''), '\n', '')) = 'Social' THEN 'Social'
        ELSE NULL -- If it's still none of the above, set to NULL (assuming the column allows NULL, or handle as an error)
    END AS acquisition_channel
FROM stg_dim_customer;


-- DDL for the final dim_restaurant table
DROP TABLE IF EXISTS dim_restaurant;
CREATE TABLE dim_restaurant (
    restaurant_id VARCHAR(20) PRIMARY KEY,
    restaurant_name VARCHAR(50) NOT NULL,
    city VARCHAR(20) NOT NULL,
    -- Using ENUM for strict control over categorical data
    cuisine_type ENUM('Chinese', 'Fast Food', 'North Indian', 'Pizza', 'Healthy', 'South Indian', 'Biryani', 'Desserts') NOT NULL,
    partner_type ENUM('Restaurant', 'Cloud Kitchen') NOT NULL,
    avg_prep_time_mins ENUM('26-40', '16-25', '>40', '<=15') NOT NULL,
    is_active ENUM('Y', 'N') NOT NULL,
    -- Indexes
    INDEX idx_city (city),
    INDEX idx_cuisine (cuisine_type)
);

INSERT INTO dim_restaurant (restaurant_id, restaurant_name, city, cuisine_type, partner_type, avg_prep_time_mins, is_active)
SELECT
   restaurant_id,
   restaurant_name,
   city,
   cuisine_type,
   partner_type,
   avg_prep_time_mins,
   CASE TRIM(REPLACE(REPLACE(is_active, '\r', ''), '\n', ''))
        WHEN 'Y' THEN 'Y'
        WHEN 'N' THEN 'N'
        ELSE NULL
    END AS is_active
FROM stg_dim_restaurant;


-- DDL for the final dim_delivery_partner table
CREATE TABLE dim_delivery_partner (
    delivery_partner_id VARCHAR(20) PRIMARY KEY,
    partner_name VARCHAR(50) NOT NULL,
    city VARCHAR(20) NOT NULL,
    vehicle_type ENUM('Scooter', 'Bike', 'Cycle', 'Car') NOT NULL,
    employment_type ENUM('Full-time', 'Part-time', 'Contract') NOT NULL,
    avg_rating DECIMAL(3, 2) NOT NULL, 
    is_active ENUM('Y', 'N') NOT NULL,
    INDEX idx_city (city),
    INDEX idx_vehicle (vehicle_type)   
);

INSERT INTO dim_delivery_partner (delivery_partner_id, partner_name, city, vehicle_type, employment_type, avg_rating, is_active)
SELECT
   delivery_partner_id,
   partner_name,
   city,
   vehicle_type,
   employment_type,
   CAST(avg_rating AS DECIMAL(3, 2)) AS avg_rating,
   is_active
FROM stg_dim_delivery_partner;


-- DDL for the final dim_menu_item table

-- DDL for the final dim_menu_item table

CREATE TABLE dim_menu_item (
    menu_item_id VARCHAR(20) PRIMARY KEY,
    restaurant_id VARCHAR(20) NOT NULL,
    item_name VARCHAR(30) NOT NULL,
    category ENUM('Pizza', 'Fried Rice', 'Starters', 'Curries', 'Beverages', 
                  'Snacks', 'Noodles', 'Burgers', 'Desserts', 'Sides', 
                  'Biryani', 'Idli', 'Fries', 'Dosa', 'Rice', 'Breads', 
                  'Wraps', 'Salads', 'Bowls', 'Juices') NOT NULL,  
    is_veg ENUM('Y', 'N') NOT NULL,
    price DECIMAL(7, 2) NOT NULL, 
    INDEX idx_restaurant_id (restaurant_id),
    INDEX idx_category (category),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id)
);

INSERT INTO dim_menu_item (menu_item_id, restaurant_id, item_name, category, is_veg, price)
SELECT
    menu_item_id,
    restaurant_id,
    item_name,
    category,
    is_veg,
    CAST(price AS DECIMAL(7, 2)) AS price
FROM stg_dim_menu_item;
