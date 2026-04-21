---step 1: Append all monthly sales tables together

CREATE OR REPLACE TABLE rfm1001.sales.sales_2026
AS
SELECT OrderID, CustomerID, OrderDate, ProductType, OrderValue
FROM rfm1001.sales.sales202601
UNION ALL
SELECT OrderID, CustomerID, OrderDate, ProductType, OrderValue
FROM rfm1001.sales.sales202602
UNION ALL
SELECT OrderID, CustomerID, OrderDate, ProductType, OrderValue
FROM rfm1001.sales.sales202603
UNION ALL
SELECT OrderID, CustomerID, OrderDate, ProductType, OrderValue
FROM rfm1001.sales.sales202604
UNION ALL
SELECT OrderID, CustomerID, OrderDate, ProductType, OrderValue
FROM rfm1001.sales.sales202605
UNION ALL
SELECT OrderID, CustomerID, OrderDate, ProductType, OrderValue
FROM rfm1001.sales.sales202606
UNION ALL
SELECT OrderID, CustomerID, OrderDate, ProductType, OrderValue
FROM rfm1001.sales.sales202607
UNION ALL
SELECT OrderID, CustomerID, OrderDate, ProductType, OrderValue
FROM rfm1001.sales.sales202608
UNION ALL
SELECT OrderID, CustomerID, OrderDate, ProductType, OrderValue
FROM rfm1001.sales.sales202609
UNION ALL
SELECT OrderID, CustomerID, OrderDate, ProductType, OrderValue
FROM rfm1001.sales.sales202610
UNION ALL
SELECT OrderID, CustomerID, OrderDate, ProductType, OrderValue
FROM rfm1001.sales.sales202611
UNION ALL
SELECT OrderID, CustomerID, OrderDate, ProductType, OrderValue
FROM rfm1001.sales.sales202612;


--- Step 2: calculate recency, frequency, monetary, r, f, m ranks
--- Combine views and CTEs

CREATE OR REPLACE VIEW rfm1001.sales.rfm_metrics AS
WITH current_date AS (
  SELECT DATE ('2026-04-20') AS analysis_date
),
rfm AS(
  SELECT
  CustomerID,
  MAX(OrderDate) AS last_order_date,
  date_diff((SELECT analysis_date FROM current_date), MAX(OrderDate), DAY) AS Recency,
  COUNT(*) AS Frequency,
  SUM(OrderValue) AS Monetary
  FROM rfm1001.sales.sales202606
  GROUP BY CustomerID
)
SELECT
rfm.*,
ROW_NUMBER() OVER(ORDER BY Recency ASC) AS r_rank,
ROW_NUMBER() OVER(ORDER BY Frequency DESC) AS f_rank,
ROW_NUMBER() OVER(ORDER BY Monetary DESC) AS m_rank
FROM rfm;


--- Step 3: Assign Deciles (10=best, 1=worst)

CREATE OR REPLACE VIEW rfm1001.sales.rfm_scores AS
SELECT  *,
NTILE(10) OVER(order by r_rank DESC) AS r_score,
NTILE(10) OVER(order by f_rank DESC) AS f_score,
NTILE(10) OVER(order by m_rank DESC) AS m_score
FROM
rfm1001.sales.rfm_metrics;


--- Step 4: Total score

CREATE OR REPLACE VIEW rfm1001.sales.rfm_total_scores
AS
SELECT
CustomerID,
Recency,
Frequency,
Monetary,
r_score,
f_score,
m_score,
(r_score + f_score + m_score) AS rfm_total_score
FROM rfm1001.sales.rfm_scores
ORDER BY rfm_total_score DESC;


--- Step 5: Create BI rfm ready segment table

CREATE OR REPLACE VIEW rfm1001.sales.rfm_segment_final
AS
SELECT
CustomerID,
Recency,
Frequency,
Monetary,
r_score,
f_score,
m_score,
rfm_total_score,
CASE
WHEN rfm_total_score >= 28 THEN 'Champions"'
WHEN rfm_total_score >= 24 THEN 'Loyal VIPs'
WHEN rfm_total_score >= 20 THEN 'Potential Loyalists'
WHEN rfm_total_score >= 16 THEN 'Promising'
WHEN rfm_total_score >= 12 THEN 'Engaged'
WHEN rfm_total_score >= 8 THEN 'Requires Attention'
WHEN rfm_total_score >= 4 THEN 'At Risk'
ELSE 'Lost/Inactive'
END AS rfm_segment
FROM rfm1001.sales.rfm_total_scores;