-- Count the rows (= orders) that match the conditions below
SELECT COUNT(*) AS late_orders          -- COUNT(*) counts rows; AS gives the result column a name
FROM olist_orders_dataset               -- the table with one row per order
WHERE order_delivered_customer_date <> ''   -- keep only orders that were actually delivered (empty = never delivered)
  AND order_delivered_customer_date > order_estimated_delivery_date;  -- delivered AFTER the promised date = late
  
    -- Label each order as 'late' or 'on time' and compare the average star rating
SELECT CASE                                          -- CASE works like if/else in R
         WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
         THEN 'late'                                 -- delivered after the promised date
         ELSE 'on time'                              -- otherwise on time
       END AS delivery,                              -- name the new column "delivery"
       ROUND(AVG(r.review_score), 2) AS avg_score,   -- average stars (1-5), rounded to 2 decimals
       COUNT(*) AS n                                 -- how many orders are in each group
FROM olist_orders_dataset o                          -- orders table, short name "o"
JOIN olist_order_reviews_dataset r                   -- reviews table, short name "r"
  ON o.order_id = r.order_id                         -- connect each order to its review via order_id
WHERE o.order_delivered_customer_date <> ''          -- only delivered orders
GROUP BY delivery;                                   -- one result row per group (like group_by() in dplyr)

-- Percentage of late orders per Brazilian state
SELECT c.customer_state,                             -- state abbreviation, e.g. SP = São Paulo
       ROUND(100.0 * AVG(
         o.order_delivered_customer_date > o.order_estimated_delivery_date
       ), 1) AS late_pct,                            -- the comparison gives 1 (late) or 0 (on time);
                                                     -- the average of 0/1 values = share of late orders; x100 = percent
       COUNT(*) AS n                                 -- number of orders per state
FROM olist_orders_dataset o
JOIN olist_customers_dataset c                       -- customers table holds the state
  ON o.customer_id = c.customer_id                   -- connect order to customer
WHERE o.order_delivered_customer_date <> ''          -- only delivered orders
GROUP BY c.customer_state                            -- one row per state
ORDER BY late_pct DESC;                              -- sort: highest late share first (like arrange(desc()))
