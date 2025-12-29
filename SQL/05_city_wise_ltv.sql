-- City-wise 90-Day Customer Lifetime Value

WITH delivered_orders AS (
  SELECT
    customer_id,
    order_date,
    net_revenue
  FROM `project.food_delivery.orders`
  WHERE order_status = 'Delivered'
),

first_order AS (
  SELECT
    customer_id,
    MIN(order_date) AS first_order_date
  FROM delivered_orders
  GROUP BY customer_id
),

customer_ltv AS (
  SELECT
    d.customer_id,
    SUM(d.net_revenue) AS ltv_90
  FROM delivered_orders d
  JOIN first_order f
    ON d.customer_id = f.customer_id
  WHERE DATE_DIFF(d.order_date, f.first_order_date, DAY) BETWEEN 0 AND 90
  GROUP BY d.customer_id
)

SELECT
  c.city,
  COUNT(l.customer_id) AS customers,
  ROUND(AVG(l.ltv_90), 2) AS avg_ltv_90
FROM customer_ltv l
JOIN `project.food_delivery.customers` c USING (customer_id)
GROUP BY c.city
ORDER BY avg_ltv_90 DESC;
