# QuickBite Express – Business Objectives & KPI Definition

## 1. Business Context

QuickBite Express is a Bengaluru-based food-tech startup that faced a major crisis in June 2025.  
A viral incident involving food safety violations and a week-long delivery outage led to a sharp decline in orders, customer trust, and restaurant partnerships.  
Competitors such as **Swiggy** and **Zomato** capitalized on the situation with aggressive campaigns.

The company has since invested in rebuilding food safety and delivery systems.  
Our role as data analysts (Peter Pandey) is to uncover **where, how, and why performance dropped**, and to recommend **data-driven recovery strategies.**

---

## 2. Business Objectives

1. Quantify the impact of the crisis on orders, revenue, and ratings.  
2. Identify which cities, restaurants, and customer groups were most affected.  
3. Measure delivery performance and SLA compliance before vs. during the crisis.  
4. Understand how customer sentiment changed through reviews and ratings.  
5. Recommend strategies to rebuild loyalty and restaurant relationships.

---

## 3. Key Business Questions (from Challenge Brief)

1. How did total orders change pre-crisis vs. crisis?  
2. Which city groups and restaurants saw the steepest decline?  
3. How did cancellations and delivery times change?  
4. What was the trend in customer ratings and sentiments?  
5. How much revenue loss occurred?  
6. Which loyal or high-value customers stopped ordering?  

---

## 4. KPIs (Key Performance Indicators)

| Area | KPI | Description / Formula | Business Purpose |
|------|-----|------------------------|------------------|
| Orders | **Total Orders** | COUNT(order_id) | Measure demand trend |
| Orders | **Order Decline %** | (Crisis – Pre)/Pre | Quantify impact |
| Revenue | **Total Revenue** | SUM(subtotal – discount + delivery_fee) | Measure financial performance |
| Cancellations | **Cancellation Rate** | cancelled_orders / total_orders | Track reliability |
| Delivery | **Avg Delivery Time** | AVG(actual_delivery_time_mins) | SLA compliance |
| Delivery | **SLA Deviation %** | (Actual – Expected)/Expected | Identify inefficiency |
| Ratings | **Avg Rating per Month** | AVG(rating) | Track satisfaction |
| Sentiment | **Avg Sentiment Score** | AVG(sentiment_score) | Track perception |
| Loyalty | **Loyal Customers Lost** | Customers ≥ 5 pre-orders who 0 crisis orders | Loyalty erosion |
| High-Value | **Top 5% Customer Spend** | Based on total_amount | Identify retention priority |

---

## 5. Hypotheses to Validate

- H1: Orders dropped by > 40% during crisis months (Jun–Sep 2025).  
- H2: Tier-1 cities experienced a sharper decline than Tier-2.  
- H3: Restaurants with lower pre-crisis ratings saw higher order loss.  
- H4: Increased delivery time correlates with lower customer ratings.  
- H5: High-rating loyal customers disengaged due to trust concerns.

---

## 6. Expected Deliverables

- SQL / Python queries for each question  
- Power BI dashboard visualizing KPIs  
- Insight summary and strategic recommendations  
