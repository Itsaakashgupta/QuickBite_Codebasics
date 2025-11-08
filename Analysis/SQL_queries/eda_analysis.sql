-- Goal: Analyze order trends across phases (Pre-Crisis & Crisis).

-- Monthly Orders trend.
SELECT
   order_month,
   COUNT(order_id) AS total_orders,
   ROUND(SUM(total_amount), 2) AS total_revenue
FROM fact_orders
GROUP BY order_month
ORDER BY order_month;

-- phase Comparison.
SELECT
   phase,
   COUNT(order_id) AS total_orders,
   ROUND(SUM(total_amount), 2) AS total_revenue,
   ROUND(AVG(total_amount), 2) AS avg_order_value
FROM fact_orders
GROUP BY phase
ORDER BY phase;

-- Top 5 declining cities.
WITH city_phase AS (
    SELECT
      c.city,
      f.phase,
      COUNT(f.order_id) AS total_orders
    FROM fact_orders f
    JOIN dim_customer c ON f.customer_id = c.customer_id
    GROUP BY c.city, f.phase
)
SELECT 
   city,
   ROUND(((MAX(CASE WHEN phase = 'Pre-Crisis' THEN total_orders END) - 
          MAX(CASE WHEN phase = 'Crisis' THEN total_orders END)) / 
          MAX(CASE WHEN phase = 'Pre-Crisis' THEN total_orders END)) * 100, 2) AS order_declining_pct
FROM city_phase
GROUP BY city
ORDER BY order_declining_pct DESC
LIMIT 5;

-- High Volume Restaurants Decline.
WITH restaurant_pivot AS (
    SELECT
       restaurant_id,
       SUM(CASE WHEN phase = 'Pre-Crisis' THEN 1 ELSE 0 END) AS pre_crisis_orders,
       SUM(CASE WHEN phase = 'Crisis' THEN 1 ELSE 0 END) AS crisis_orders
    FROM fact_orders
    GROUP BY restaurant_id
)
SELECT
   p.restaurant_id,
   r.restaurant_name,
   r.cuisine_type,
   r.partner_type,
   r.avg_prep_time_mins,
   p.pre_crisis_orders,
   p.crisis_orders,
   ROUND(((p.pre_crisis_orders - p.crisis_orders)/p.pre_crisis_orders)*100, 2) AS decline_pct
FROM restaurant_pivot p
JOIN dim_restaurant r ON p.restaurant_id = r.restaurant_id
WHERE p.pre_crisis_orders >=10
ORDER BY decline_pct DESC;

-- Goal: Assess operational bottlenecks in delivery flow.

-- Average Delivery Time in Every Phase
SELECT
   f.phase,
   AVG(d.actual_delivery_time_mins)
FROM fact_orders f
LEFT JOIN fact_delivery_performance d ON f.order_id = d.order_id 
GROUP BY phase;

-- Cancellation Trend.
SELECT
   phase,
   COUNT(order_id) AS total_orders,
   SUM(CASE WHEN is_cancelled = 'Y' THEN 1 ELSE 0 END) AS cancelled_orders,
   ROUND(SUM(CASE WHEN is_cancelled = 'Y' THEN 1 ELSE 0 END)/COUNT(*)* 100, 2) AS cancel_pct
FROM fact_orders
GROUP BY phase; 

-- Cancellation by City and Phase.
WITH city_phase_metrics AS (
    SELECT
      c.city,
      f.phase,
      COUNT(f.order_id) AS total_orders,
      SUM(CASE WHEN f.is_cancelled = 'Y' THEN 1 ELSE 0 END) AS cancelled_orders
    FROM fact_orders f
    JOIN dim_customer c ON f.customer_id = c.customer_id
    GROUP BY c.city, f.phase
)
SELECT
   city,
   MAX(CASE WHEN phase = 'Pre-Crisis' THEN cancelled_orders END) AS pre_crisis_cancellations,
   MAX(CASE WHEN phase = 'Crisis' THEN cancelled_orders END) AS crisis_cancellations,
   MAX(CASE WHEN phase = 'Pre-Crisis' THEN total_orders END) AS pre_crisis_orders,
   MAX(CASE WHEN phase = 'Crisis' THEN total_orders END) AS crisis_orders,
   ROUND((MAX(CASE WHEN phase = 'Pre-Crisis' THEN cancelled_orders END)/
         MAX(CASE WHEN phase = 'Pre-Crisis' THEN total_orders END))*100, 2) AS pre_crisis_cancel_pct,
   ROUND((MAX(CASE WHEN phase = 'Crisis' THEN cancelled_orders END)/
         MAX(CASE WHEN phase = 'Crisis' THEN total_orders END))*100, 2) AS crisis_cancel_pct
FROM city_phase_metrics
GROUP BY city
ORDER BY crisis_cancel_pct DESC;

-- SLA Performance by Phase.
SELECT
   f.phase,
   ROUND(AVG(p.sla_diff), 2) AS avg_delay_mins,
   ROUND(SUM(CASE WHEN p.sla_diff <= 0 THEN 1 ELSE 0 END)/COUNT(*)*100, 2) AS sla_met_pct
FROM fact_orders f
JOIN fact_delivery_performance p ON f.order_id = p.order_id
GROUP BY f.phase;


-- Goal: Use ratings and sentiment to guide recovery.

-- Average Ratings by Phase.
SELECT
   f.phase,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM fact_orders f
JOIN fact_ratings r ON f.order_id = r.order_id
GROUP BY f.phase;

-- Monthly Ratings Trend.
SELECT
   f.order_month,
    ROUND(AVG(r.rating), 2) AS avg_monthly_rating
FROM fact_orders f
JOIN fact_ratings r ON f.order_id = r.order_id
GROUP BY f.order_month;

-- Negative Reviews during Crisis.(Later Visualize in PowerBI)
SELECT
    r.review_text
FROM fact_ratings r
JOIN fact_orders f ON r.order_id = f.order_id
WHERE f.phase = 'Crisis';


-- Goal: Revenue impact Pre-Crisis vs Crisis

-- Revenue Loss by phase.
SELECT
   phase,
   ROUND(SUM(subtotal_amount - discount_amount + delivery_fee), 2) AS total_revenue
FROM fact_orders
GROUP BY phase;

-- Percentage Revenue Loss.
WITH rev AS (
    SELECT phase, SUM(subtotal_amount - discount_amount + delivery_fee) AS revenue
    FROM fact_orders
    GROUP BY phase
)
SELECT 
    MAX(CASE WHEN phase = 'Pre-Crisis' THEN revenue END) AS pre_crisis_revenue,
    MAX(CASE WHEN phase = 'Crisis' THEN revenue END) AS Crisis_revenue,
    ROUND(((MAX(CASE WHEN phase='Pre-Crisis' THEN revenue END) -
            MAX(CASE WHEN phase='Crisis' THEN revenue END))
            / MAX(CASE WHEN phase='Pre-Crisis' THEN revenue END)) * 100, 2) AS revenue_drop_pct
FROM rev;


-- Goal: Identify which customer groups can be recovered vs. need new strategies.

-- Repeat vs One-time Customers by Phase
SELECT
    phase,
    customer_segment,
    COUNT(customer_id) AS customer_count,
    SUM(COUNT(customer_id)) OVER (PARTITION BY phase) AS total_customers_in_phase,
    ROUND((COUNT(customer_id) * 100.0) / SUM(COUNT(customer_id)) OVER (PARTITION BY phase), 2) AS segment_pct
FROM (
    SELECT 
        customer_id, 
        phase,
        CASE WHEN COUNT(*) = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_segment
    FROM fact_orders
    GROUP BY customer_id, phase
) t
GROUP BY phase, customer_segment
ORDER BY phase, customer_segment DESC;

-- Among customers who placed 4 or more orders before the crisis, 
-- determine how many stopped ordering during the crisis, and out of those, how many had an average rating above 4.5.
WITH pre_orders AS (
    SELECT customer_id, 
    COUNT(order_id) AS pre_order_count
    FROM fact_orders
    WHERE phase = 'Pre-Crisis'
    GROUP BY customer_id
    HAVING COUNT(order_id) >= 4
),
crisis_orders AS (
    SELECT DISTINCT customer_id
    FROM fact_orders
    WHERE phase = 'Crisis'
),
high_rated AS (
    SELECT f.customer_id, ROUND(AVG(r.rating), 2) AS avg_rating
    FROM fact_ratings r
    JOIN fact_orders f USING(order_id)
    WHERE f.phase = 'Pre-Crisis'
    GROUP BY f.customer_id
)
SELECT 
    COUNT(p.customer_id) AS pre_frequent_customers, -- order more than or equal to 4 times before Crisis
    COUNT(DISTINCT CASE WHEN c.customer_id IS NULL THEN p.customer_id END) AS churned_customers, -- Customers who place orders in pre crisis period but not in crisis
    COUNT(DISTINCT CASE WHEN c.customer_id IS NULL AND h.avg_rating > 4.5 THEN p.customer_id END) AS churned_with_high_rating -- Customers who place orders in pre crisis period but not in crisis also gave average rating 4.5
FROM pre_orders p
LEFT JOIN crisis_orders c ON p.customer_id = c.customer_id
LEFT JOIN high_rated h ON p.customer_id = h.customer_id;

-- Find the high-value customers and compute their pre vs crisis order/rating drop.
--CREATE VIEW hv_customers AS (
WITH customer_spend AS ( -- Total amount spend by Per customer in Pre-Crisis phase
    SELECT
        customer_id,
        ROUND(SUM(total_amount), 2) AS pre_total
    FROM fact_orders
    WHERE phase = 'Pre-Crisis'
    GROUP BY customer_id
),
ranked_customer AS ( -- Grouping total customers in 100 ranks who spend in Pre-Crisis phase
    SELECT
       customer_id,
       pre_total,
       NTILE(100) OVER (ORDER BY pre_total DESC) AS pct_rank
    FROM customer_spend
),
top_5 AS ( -- Filtering out Top 5% customer who spend most in Pre-Crisis phase
    SELECT
       customer_id,
       pre_total
    FROM ranked_customer
    WHERE pct_rank <= 5
),
phase_metrics AS ( -- Number of Orders & their average rating by each customer in both phase
    SELECT
       f.customer_id,
       f.phase,
       COUNT(f.order_id) AS order_count,
       ROUND(AVG(r.rating), 2) AS avg_rating
    FROM fact_orders f
    LEFT JOIN fact_ratings r USING(order_id)
    GROUP BY f.customer_id, f.phase
)
SELECT 
   t.customer_id,
   t.pre_total,
   MAX(CASE WHEN p.phase = 'Pre-Crisis' THEN p.order_count END) AS pre_orders, -- No. of Orders by Top 5% customers in Pre-Crisis
   MAX(CASE WHEN p.phase = 'Crisis' THEN p.order_count END) AS crisis_orders, -- No. of Orders by Top 5% customers in Crisis
   MAX(CASE WHEN p.phase = 'Pre-Crisis' THEN p.avg_rating END) AS avg_pre_rating, -- Avg. Ratings by Top 5% customers in Pre-Crisis
   MAX(CASE WHEN p.phase = 'Crisis' THEN p.avg_rating END) AS avg_crisis_rating, -- Avg. Ratings by Top 5% customers in Crisis
   ROUND(((COALESCE(MAX(CASE WHEN p.phase='Crisis' THEN p.order_count END),0) -
        COALESCE(MAX(CASE WHEN p.phase='Pre-Crisis' THEN p.order_count END),0))/
        NULLIF(MAX(CASE WHEN p.phase='Pre-Crisis' THEN p.order_count END),0)
      ) * 100, 2) AS order_drop_pct, -- Percent of orders drop from Pre-Crisis to Crisis by Top 5% customers  
   ROUND(COALESCE(MAX(CASE WHEN p.phase='Crisis' THEN p.avg_rating END),0) -
        COALESCE(MAX(CASE WHEN p.phase='Pre-Crisis' THEN p.avg_rating END),0)
    , 2) AS rating_change -- Drop of Average rating from Pre-Crisis to Crisis by Top 5% customers.
FROM top_5 t
LEFT JOIN phase_metrics p ON t.customer_id = p.customer_id
GROUP BY t.customer_id
ORDER BY pre_total DESC, order_drop_pct DESC, rating_change DESC; -- sorted by Total amount spend by Top 5% customers in Pre-Crisis
--);
    
-- Top 5% Customers who stopped ordering in Crisis phase(Group By cities)
WITH top_listed AS (
    SELECT
       c.city,
       t.customer_id,
       t.pre_total,
       t.order_drop_pct
    FROM dim_customer c
    LEFT JOIN hv_customers t ON c.customer_id = t.customer_id
    WHERE t.order_drop_pct = -100
    ORDER BY pre_total DESC 
)
SELECT 
   city,
   COUNT(customer_id) AS customer_count,
   ROUND((COUNT(customer_id) / SUM(COUNT(customer_id)) OVER ())* 100, 2) pct_customer
FROM top_listed
GROUP BY city
ORDER BY pct_customer DESC;

-- Top 5% Customer Preference Cuisine Type who stopped ordering during Crisis.
WITH top_cust AS (
SELECT
   t.customer_id,
   f.order_id,
   r.cuisine_type
FROM hv_customers t 
LEFT JOIN fact_orders f ON t.customer_id = f.customer_id
LEFT JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
WHERE t.order_drop_pct = -100
)
SELECT
   cuisine_type,
   COUNT(customer_id) AS customer_count,
   ROUND(COUNT(customer_id) * 100 / SUM(COUNT(customer_id)) OVER (), 2) AS pct_customer
FROM top_cust
GROUP BY cuisine_type
ORDER BY pct_customer DESC;

-- Secondary Analysis

-- Paid Channel Customer by Phases
SELECT
    f.phase,
    COUNT(f.order_id) AS total_orders,
    SUM(f.total_amount) AS total_revenue 
FROM fact_orders f
JOIN dim_customer d ON f.customer_id = d.customer_id
WHERE d.acquisition_channel = 'Paid'
GROUP BY phase;

-- CHURN RATE BY PARTNER TYPE
WITH RestaurantOrders AS (
    SELECT
        restaurant_id,
        MAX(CASE WHEN phase = 'Pre-Crisis' THEN order_count ELSE 0 END) AS pre_crisis_orders,
        MAX(CASE WHEN phase = 'Crisis' THEN order_count ELSE 0 END) AS crisis_orders
    FROM (
        SELECT
            restaurant_id,
            phase,
            COUNT(order_id) AS order_count
        FROM fact_orders
        GROUP BY 1, 2
    ) AS OrderCounts
    GROUP BY 1
),
RestaurantBase AS (
    SELECT
        r.restaurant_id,
        r.pre_crisis_orders,
        r.crisis_orders,
        d.partner_type,
        d.avg_prep_time_mins,
        CASE
            WHEN r.crisis_orders = 0 THEN 1
            ELSE 0
        END AS is_churned_100pct
    FROM RestaurantOrders r
    JOIN dim_restaurant d ON r.restaurant_id = d.restaurant_id
    WHERE r.pre_crisis_orders >= 10 -- High-Volume Filter
)
SELECT
    partner_type,
    COUNT(restaurant_id) AS total_hv_restaurants,
    SUM(is_churned_100pct) AS churned_100pct_count,
    ROUND((SUM(is_churned_100pct) / COUNT(restaurant_id)) * 100, 2) AS churn_rate_pct
FROM RestaurantBase
GROUP BY partner_type
ORDER BY churn_rate_pct DESC;


-- CHURN RATE BY AVERAGE PREP TIME (EFFICIENCY)
WITH RestaurantOrders AS (
    SELECT
        restaurant_id,
        MAX(CASE WHEN phase = 'Pre-Crisis' THEN order_count ELSE 0 END) AS pre_crisis_orders,
        MAX(CASE WHEN phase = 'Crisis' THEN order_count ELSE 0 END) AS crisis_orders
    FROM (
        SELECT
            restaurant_id,
            phase,
            COUNT(order_id) AS order_count
        FROM fact_orders
        GROUP BY 1, 2
    ) AS OrderCounts
    GROUP BY 1
),
RestaurantBase AS (
    SELECT
        r.restaurant_id,
        r.pre_crisis_orders,
        r.crisis_orders,
        d.partner_type,
        d.avg_prep_time_mins,
        CASE
            WHEN r.crisis_orders = 0 THEN 1
            ELSE 0
        END AS is_churned_100pct
    FROM RestaurantOrders r
    JOIN dim_restaurant d ON r.restaurant_id = d.restaurant_id
    WHERE r.pre_crisis_orders >= 10 -- High-Volume Filter
)
SELECT
    avg_prep_time_mins,
    COUNT(restaurant_id) AS total_hv_restaurants,
    SUM(is_churned_100pct) AS churned_100pct_count,
    ROUND((SUM(is_churned_100pct) / COUNT(restaurant_id)) * 100, 2) AS churn_rate_pct
FROM RestaurantBase
GROUP BY avg_prep_time_mins
ORDER BY churn_rate_pct DESC;


