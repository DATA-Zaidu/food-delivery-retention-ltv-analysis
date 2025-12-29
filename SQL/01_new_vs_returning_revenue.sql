-- Revenue Contribution: New vs Returning Customers

WITH delivered_orders AS (
  SELECT
    customer_id,
    order_date,
    net_revenue
  FROM `project.food_delivery.orders`
  WHERE order_status = 'Delivered'
),

ranked_orders AS (
  SELECT
    customer_id,
    order_date,
    net_revenue,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY order_date
    ) AS order_rank
  FROM delivered_orders
)

SELECT
  CASE
    WHEN order_rank = 1 THEN 'new_customers_revenue'
    ELSE 'returning_customers_revenue'
  END AS revenue_type,
  ROUND(SUM(net_revenue), 2) AS total_revenue,
  COUNT(DISTINCT customer_id) AS customers
FROM ranked_orders
GROUP BY revenue_type;

