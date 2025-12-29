-- Cohort Retention Analysis
-- Measures monthly customer retention based on first delivered order



WITH delivered_orders AS (
  SELECT
    customer_id,
    DATE(order_date) AS order_date
  FROM `vaulted-epigram-475613-g4.food_delivery.orders`
  WHERE order_status = 'Delivered'
),

first_order AS (
  SELECT
    customer_id,
    DATE_TRUNC(MIN(order_date), MONTH) AS cohort_month
  FROM delivered_orders
  GROUP BY customer_id
),

monthly_activity AS (
  SELECT
    customer_id,
    DATE_TRUNC(order_date, MONTH) AS order_month
  FROM delivered_orders
  GROUP BY customer_id, order_month
),

cohort_activity AS (
  SELECT
    f.customer_id,
    f.cohort_month,
    m.order_month,
    DATE_DIFF(m.order_month, f.cohort_month, MONTH) AS month_since_cohort
  FROM first_order f
  JOIN monthly_activity m
    ON f.customer_id = m.customer_id
),

cohort_counts AS (
  SELECT
    cohort_month,
    month_since_cohort,
    COUNT(DISTINCT customer_id) AS retained_customers
  FROM cohort_activity
  GROUP BY cohort_month, month_since_cohort
),

cohort_size AS (
  SELECT
    cohort_month,
    COUNT(DISTINCT customer_id) AS cohort_users
  FROM cohort_activity
  WHERE month_since_cohort = 0
  GROUP BY cohort_month
)

SELECT
  c.cohort_month,
  c.month_since_cohort,
  c.retained_customers,
  s.cohort_users,
  ROUND(100 * c.retained_customers / s.cohort_users, 2) AS retention_pct
FROM cohort_counts c
JOIN cohort_size s
  ON c.cohort_month = s.cohort_month
ORDER BY c.cohort_month, c.month_since_cohort;
