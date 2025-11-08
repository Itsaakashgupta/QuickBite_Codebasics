CREATE TABLE stg_fact_orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    restaurant_id VARCHAR(50),
    delivery_partner_id VARCHAR(50),
    order_timestamp VARCHAR(50),
    subtotal_amount VARCHAR(50),
    discount_amount VARCHAR(50),
    delivery_fee VARCHAR(50),
    total_amount VARCHAR(50),
    is_code VARCHAR(50),
    is_cancelled VARCHAR(50)
);

LOAD DATA INFILE 'D:\\akash\\Quickbite_Express\\Data\\raw\\fact_orders.csv'
INTO TABLE stg_fact_orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, restaurant_id, delivery_partner_id, order_timestamp, subtotal_amount, discount_amount, delivery_fee, total_amount, is_code, is_cancelled);


CREATE TABLE stg_fact_order_items (
    order_id VARCHAR(50),
    item_id VARCHAR(50),
    menu_item_id VARCHAR(50),
    restaurant_id VARCHAR(50),
    quantity VARCHAR(50),
    unit_price VARCHAR(50),
    item_discount VARCHAR(50),
    line_total VARCHAR(50)
);

LOAD DATA INFILE 'D:\\akash\\Quickbite_Express\\Data\\raw\\fact_order_items.csv'
INTO TABLE stg_fact_order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, item_id, menu_item_id, restaurant_id, quantity, unit_price, item_discount, line_total);


CREATE TABLE stg_fact_ratings (
     order_id VARCHAR(50),
     customer_id VARCHAR(50),
     restaurant_id VARCHAR(50),
     rating VARCHAR(50),
     review_text VARCHAR(255),
     review_timestamp VARCHAR(50),
     sentiment_score VARCHAR(50)
);

LOAD DATA INFILE 'D:\\akash\\Quickbite_Express\\Data\\raw\\fact_ratings.csv'
INTO TABLE stg_fact_ratings
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, restaurant_id, rating, review_text, review_timestamp, sentiment_score);


CREATE TABLE stg_fact_delivery_performance (
    order_id VARCHAR(50),
    actual_delivery_time_mins VARCHAR(50),
    expected_delivery_time_mins VARCHAR(50),
    distance_km VARCHAR(50)
);

LOAD DATA INFILE 'D:\\akash\\Quickbite_Express\\Data\\raw\\fact_delivery_performance.csv'
INTO TABLE stg_fact_delivery_performance
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, actual_delivery_time_mins, expected_delivery_time_mins, distance_km);


CREATE TABLE stg_dim_customer (
    customer_id VARCHAR(50),
    signup_date VARCHAR(50),
    city VARCHAR(50),
    acquisition_channel VARCHAR(50)
);

LOAD DATA INFILE 'D:\\akash\\Quickbite_Express\\Data\\raw\\dim_customer.csv'
INTO TABLE stg_dim_customer
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, signup_date, city, acquisition_channel);

SELECT * FROM stg_dim_customer;


CREATE TABLE stg_dim_restaurant (
    restaurant_id VARCHAR(50),
    restaurant_name VARCHAR(100),
    city VARCHAR(50),
    cuisine_type VARCHAR(50),
    partner_type VARCHAR(50),
    avg_prep_time_mins VARCHAR(50),
    is_active VARCHAR(50)
);

LOAD DATA INFILE 'D:\\akash\\Quickbite_Express\\Data\\raw\\dim_restaurant.csv'
INTO TABLE stg_dim_restaurant
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(restaurant_id, restaurant_name, city, cuisine_type, partner_type, avg_prep_time_mins, is_active);



CREATE TABLE stg_dim_delivery_partner (
    delivery_partner_id VARCHAR(50),
    partner_name VARCHAR(50),
    city VARCHAR(50),
    vehicle_type VARCHAR(50),
    employment_type VARCHAR(50),
    avg_rating VARCHAR(50),
    is_active VARCHAR(50)
);

LOAD DATA INFILE 'D:\\akash\\Quickbite_Express\\Data\\raw\\dim_delivery_partner.csv'
INTO TABLE stg_dim_delivery_partner
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(delivery_partner_id, partner_name, city, vehicle_type, employment_type, avg_rating, is_active);


CREATE TABLE stg_dim_menu_item (
    menu_item_id VARCHAR(50),
    restaurant_id VARCHAR(50),
    item_name VARCHAR(50),
    category VARCHAR(50),
    is_veg VARCHAR(50),
    price VARCHAR(50)
);

LOAD DATA INFILE 'D:\\akash\\Quickbite_Express\\Data\\raw\\dim_menu_item.csv'
INTO TABLE stg_dim_menu_item
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(menu_item_id, restaurant_id, item_name, category, is_veg, price);
