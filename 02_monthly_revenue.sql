-- Monthly revenue and growth compared to the previous month
WITH monthly AS (                                    -- WITH = CTE: a temporary helper table
  SELECT substr(o.order_purchase_timestamp, 1, 7) AS month,   -- first 7 characters = "2017-05"
         ROUND(SUM(p.payment_value), 0) AS revenue            -- total paid per month
  FROM olist_orders_dataset o
  JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
  GROUP BY month
  HAVING month BETWEEN '2017-01' AND '2018-08'   -- keep only months with complete data
)
SELECT month,
       revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month,      -- LAG = value from the previous row
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 1) AS growth_pct  -- % change vs. previous month
FROM monthly
ORDER BY month;