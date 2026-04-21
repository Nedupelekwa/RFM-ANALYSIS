# Customer RFM Segmentation Analysis in BigQuery

Project Overview
This project performs an RFM Analysis (Recency, Frequency, Monetary) on a year's worth of sales data. RFM is a marketing technique used to quantitatively rank and group customers based on the recency, frequency, and monetary total of their recent transactions to identify the best customers and perform targeted marketing campaigns.

Workflow & Architecture
1. Data Consolidation
The project begins by aggregating 12 individual monthly sales tables (sales202601 through sales202612) into a single centralized table: sales_2026. This ensures a unified view of customer behavior for the entire year.

2. RFM Metrics Calculation
We calculate the three core metrics for each unique CustomerID:

Recency: Days since the customer's last purchase (relative to a fixed analysis date).
Frequency: Total number of orders placed.
Monetary: Total value spent across all orders.
3. Statistical Scoring (Deciles)
Using BigQuery's NTILE(10) window function, customers are assigned a score from 1 to 10 for each metric.

A score of 10 represents the "best" behavior (e.g., most recent, most frequent, or highest spend).
A score of 1 represents the "worst" behavior.
4. Final Segmentation
Customers are assigned a final segment based on their rfm_total_score (the sum of R, F, and M scores), ranging from 3 to 30.

Segment	Score Range	Description
Champions	28+	Best customers, recent and frequent big spenders.
Loyal VIPs	24 - 27	Consistent customers with high value.
Potential Loyalists	20 - 23	Recent customers with average frequency.
At Risk	4 - 7	Haven't purchased in a while; need re-engagement.
Lost/Inactive	< 4	Lowest scores across all metrics.

SQL Implementation Details
Dialect: GoogleSQL (BigQuery)
Features Used:
UNION ALL for data ingestion.
Common Table Expressions (CTEs) for modular logic.
Window Functions (ROW_NUMBER, NTILE) for ranking.
Views for modular reporting layers (Metrics -> Scores -> Segments).

How to Use
Ingestion: Run Step 1 to consolidate your monthly source tables.
Analysis: Execute the View creation scripts (Steps 2–5).
Visualization: Connect the final view rfm_segment_final to Looker Studio, Tableau, or Power BI to visualize customer distribution.

Summary of the SQL Logic
Step 1: Consolidates data.
Step 2: Creates rfm_metrics view (Calculates raw R, F, M values).
Step 3: Creates rfm_scores view (Ranks customers 1-10).
Step 4: Creates rfm_total_scores (Aggregates the total score).
Step 5: Creates rfm_segment_final (Applies business logic labels for BI tools like BI).
