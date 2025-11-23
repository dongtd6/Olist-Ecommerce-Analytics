-- This SQL query segments customers based on their total spending into quintiles.
WITH order_spend AS (
  SELECT
    o.order_id,
    c.customer_unique_id,
    SUM(p.payment_value) AS order_spend
  FROM `dwh_olist.olist_orders_dataset` o
  JOIN `dwh_olist.olist_order_payments_dataset` p
      ON o.order_id = p.order_id
  JOIN `dwh_olist.olist_customers_dataset` c
      ON o.customer_id = c.customer_id
  GROUP BY o.order_id, c.customer_unique_id
),

customer_spend AS (
  SELECT
    os.customer_unique_id,
    SUM(os.order_spend) AS total_spend
  FROM order_spend AS os
  GROUP BY os.customer_unique_id
)

SELECT
  quantiles[OFFSET(40)] AS p40,
  quantiles[OFFSET(60)] AS p60,
  quantiles[OFFSET(80)] AS p80,
  quantiles[OFFSET(95)] AS p95
FROM (
  SELECT APPROX_QUANTILES(total_spend, 100) AS quantiles
  FROM customer_spend
);



-- The resulting table 'olist_customer_segment' categorizes customers into five segments based on their total spending.
WITH order_spend AS (
  SELECT
    o.order_id,
    c.customer_unique_id,
    SUM(p.payment_value) AS order_spend
  FROM `dwh_olist.olist_orders_dataset` o
  JOIN `dwh_olist.olist_order_payments_dataset` p
    ON o.order_id = p.order_id
  JOIN `dwh_olist.olist_customers_dataset` c
    ON o.customer_id = c.customer_id
  GROUP BY o.order_id, c.customer_unique_id
),
customer_spend AS (
  SELECT
    os.customer_unique_id,
    SUM(os.order_spend) AS total_spend
  FROM order_spend AS os
  GROUP BY os.customer_unique_id
)
SELECT
  customer_unique_id,
  total_spend,
  CASE
    WHEN total_spend = 0 THEN 'No Spend'
    WHEN total_spend < 87.56 THEN 'Very Low'
    WHEN total_spend < 133.18 THEN 'Low'
    WHEN total_spend < 209.62 THEN 'Medium'
    WHEN total_spend < 475.82 THEN 'High'
    ELSE 'Very High'
  END AS segment
FROM customer_spend;
-- dwh_olist.olist_customer_segment
select segment, count(customer_unique_id) 
from dwh_olist.olist_customer_segment 
group by segment
