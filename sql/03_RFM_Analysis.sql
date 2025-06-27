/*=====================================================================================================================================
Filename: 03_RFM_Analysis.sql
Project: Credit Card Analytics
Purpose:
- Perform RFM (Recency, Frequency, Monetary) Analysis to identify and segment customers
- Assign RFM scores to help marketing, loyalty, and fraud-risk teams prioritize segments
- Build a reusable RFM view for Power BI and advanced queries
- Extend with loyalty, CLV, and cross-segmentation metrics

Author: Saharsh Nagisetty
Notes:
- RFM Scoring:
	Recency Score: 5 (most recent) -> 1 (least recent).
	Frequency Score: 5 (most transactions) -> 1 (least).
	Monetary Score: 5 (highest spend) -> 1 (lowest spend).
- Queries in this file are designed to support downstream Power BI dashboards and portfolio insights
- Complements 02_Core_Analysis.sql and 01_ETL_Data_Preparation.sql
======================================================================================================================================*/

/*===================================================================
📊 Phase 1: RFM Segmentation and Customer Metrics
===================================================================
Objective:
Perform advanced segmentation on customer transactions using RFM logic
and extend the analysis with loyalty indicators, customer lifetime value,
and cross-dimensional slices (age, education, credit limits).

Focus Areas:
🔹 1. Build and store the RFM scoring model
🔹 2. Loyalty and longevity metrics
🔹 3. Lifetime Value (CLV) estimation
🔹 4. Cross-segmentation patterns (optional in Power BI)
==================================================================*/


/* ----------------------------------------------------------
1.1 Analysis: RFM View Creation and Scoring
----------------------------------------------------------
Purpose:
- Build a reusable customer RFM segmentation view.
- Assign Recency, Frequency, and Monetary scores to each customer.

Business Questions:
- Who are the most valuable customers (Premium segment)?
- Who are low-engagement customers (At Risk segment)?
- How can we prioritize loyalty campaigns or risk controls?

Suggested Use:
- Power BI slicers for segment selection
- Advanced segment-level performance reporting
- Marketing targeting and fraud-risk profiling

Technical Notes:
- Recency calculated as days since most recent transaction
- Frequency as total transactions
- Monetary as total spend rounded to whole dollars
- Scores are mapped 5–1 based on business rules
---------------------------------------------------------- */
/*=================================================================
Create or Replace the RFM View
==================================================================*/
CREATE OR REPLACE VIEW vw_CreditCard_RFM AS

/*------------------------------------------------------------------
Step A: customer_transactions
------------------------------------------------------------------
Aggregate raw transaction data (`transactions_fraud`) to get:
- Latest transaction date
- Total transaction count
- Total spend
------------------------------------------------------------------*/
WITH customer_transactions AS (
    SELECT
        cc_num AS customer_id,
        MAX(trans_date_trans_time) AS last_transaction_date,
        COUNT(*) AS total_transactions,
        SUM(amt) AS total_spend
    FROM transactions_fraud
    GROUP BY cc_num
),
/*------------------------------------------------------------------
Step B: recency_calculation
------------------------------------------------------------------
Calculate Recency for each customer:
- Recency (in days): Difference between CURRENT_DATE and their LAST transaction
------------------------------------------------------------------*/
recency_calculation AS (
    SELECT 
        customer_id,
        total_transactions AS frequency,
        ROUND(total_spend) AS monetary,
        DATEDIFF("2020-12-01", MAX(last_transaction_date)) AS recency_days
    FROM customer_transactions
    GROUP BY customer_id
),
/*------------------------------------------------------------------
Step C: scored_rfm
------------------------------------------------------------------
Assign RFM Scores:
- Recency Score: 
    <= 30d = 5, <= 90d = 4, <= 150d = 3, <= 210d = 2, > 270d = 1
- Frequency Score:
    >=1000 = 5, >=500 = 4, >=200 = 3, >=50 = 2, <50 = 1
- Monetary Score:
    >= $100000 = 5, >= $50000 = 4, >= $25000 = 3, >= $10000 = 2, < $10000 = 1
------------------------------------------------------------------*/
scored_rfm AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        CASE
            WHEN recency_days <= 30 THEN 5
            WHEN recency_days <= 90 THEN 4
            WHEN recency_days <= 150 THEN 3
            WHEN recency_days <= 210 THEN 2
            ELSE 1
        END AS recency_score,
        CASE
            WHEN frequency >= 1000 THEN 5
            WHEN frequency >= 500 THEN 4
            WHEN frequency >= 200 THEN 3
            WHEN frequency >= 50 THEN 2
            ELSE 1
        END AS frequency_score,
        CASE
            WHEN monetary >= 100000 THEN 5
            WHEN monetary >= 50000 THEN 4
            WHEN monetary >= 25000 THEN 3
            WHEN monetary >= 10000 THEN 2
            ELSE 1
        END AS monetary_score
    FROM recency_calculation
)
/*------------------------------------------------------------------
Step D: Final View Output
------------------------------------------------------------------
Combination of:
- recency_days, frequency, monetary
- RFM scores
- Final RFM Segment labeling
------------------------------------------------------------------*/
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS RFM_Total,
    CASE
        WHEN (recency_score + frequency_score + monetary_score) >= 11 THEN 'Premium'
        WHEN (recency_score + frequency_score + monetary_score) >= 9 THEN 'Loyal'
        WHEN (recency_score + frequency_score + monetary_score) >= 6 THEN 'Potential'
        ELSE 'At Risk'
    END AS RFM_Segment
FROM
    scored_rfm;
  
SELECT * FROM vw_CreditCard_RFM;  
  
/* ----------------------------------------------------------
1.2 Analysis: Segment Size Distribution
----------------------------------------------------------
Purpose:
- Understand the distribution of customers across RFM segments.
- Measure concentration of high-value (Premium) vs. low-value (At Risk) customers.

Business Questions:
- What proportion of our customers are Premium vs Loyal vs At Risk?
- Do we need to grow or protect certain segments?
- Is our customer portfolio balanced?

Suggested Use:
- Pie or donut charts in Power BI showing segment share
- Executive summaries on customer base health
- Campaign budget allocation based on segment volumes
---------------------------------------------------------- */
SELECT
    RFM_Segment,
    COUNT(*) AS Number_of_Customers
FROM vw_CreditCard_RFM
GROUP BY RFM_Segment
ORDER BY Number_of_Customers DESC;

/* ----------------------------------------------------------
1.3 Analysis: Top Premium Customers by Spend
----------------------------------------------------------
Purpose:
- Identify the most valuable customers based on RFM scoring.
- Focus on high-spend, frequent, and recent customers with strong loyalty potential.

Business Questions:
- Who are our top Premium customers by total spend?
- Can we design retention or loyalty programs specifically for these customers?
- Should account managers prioritize outreach to these individuals?

Suggested Use:
- VIP lists for retention marketing or personal outreach
- Customer advisory boards or testimonial programs
- Power BI tables or drill-throughs for individual analysis
---------------------------------------------------------- */
SELECT *
FROM vw_CreditCard_RFM
WHERE RFM_Segment = 'Premium'
ORDER BY Monetary DESC
LIMIT 10;

/* ----------------------------------------------------------
1.4 Analysis: At-Risk Customers
----------------------------------------------------------
Purpose:
- Identify customers with low frequency, low spend, and long recency.
- Proactively flag potential churn or disengaged customers.

Business Questions:
- Which customers are showing early warning signals of churn?
- Should we run win-back or reactivation campaigns for these customers?
- Are there patterns in their transaction histories that indicate dissatisfaction?

Suggested Use:
- Reactivation campaigns or targeted retention offers
- Power BI drill-through visuals for churn risk
- Segment monitoring for early intervention
---------------------------------------------------------- */
SELECT *
FROM vw_CreditCard_RFM
WHERE RFM_Segment = 'At Risk'
ORDER BY Recency_days DESC
LIMIT 10;


/* ----------------------------------------------------------
1.5 Analysis: Frequency Band Distribution
----------------------------------------------------------
Purpose:
- Understand how customers distribute across frequency scoring bands.
- Identify segments with high or low transaction frequency for deeper analysis.

Business Questions:
- What proportion of customers transact very frequently vs. rarely?
- Do frequent customers overlap with high-value segments?
- Should frequency drive marketing or customer service priorities?

Suggested Use:
- Power BI bar charts showing frequency bands
- Tailor loyalty incentives for very frequent segments
- Spot low-engagement customers for reactivation
---------------------------------------------------------- */
SELECT 
    CASE
        WHEN frequency_score = 5 THEN 'Very Frequent'
        WHEN frequency_score = 4 THEN 'Frequent'
        WHEN frequency_score = 3 THEN 'Moderate'
        WHEN frequency_score = 2 THEN 'Low'
        ELSE 'Very Low'
    END AS Frequency_Band,
    COUNT(*) AS Customer_Count
FROM vw_CreditCard_RFM
GROUP BY Frequency_Band;



/* ----------------------------------------------------------
1.6 Analysis: Recency Band Distribution
----------------------------------------------------------
Purpose:
- Classify customers based on how recently they transacted.
- Reveal recency patterns to support re-engagement or churn prevention.

Business Questions:
- What is the recency profile of our customer base?
- Are there large dormant or stale customer segments?
- How can reactivation campaigns be targeted by recency band?

Suggested Use:
- Bar charts in Power BI for recency distribution
- Drive re-engagement campaigns for dormant or stale segments
- Prioritize customer check-ins based on recency
---------------------------------------------------------- */
SELECT
    CASE
        WHEN recency_score = 5 THEN 'Active (<30d)'
        WHEN recency_score = 4 THEN 'Recent (30–90d)'
        WHEN recency_score = 3 THEN 'Moderate (90–150d)'
        WHEN recency_score = 2 THEN 'Stale (150–210d)'
        ELSE 'Dormant (>270d)'
    END AS Recency_Band,
    COUNT(*) AS Customer_Count
FROM vw_CreditCard_RFM
GROUP BY Recency_Band;


/* ----------------------------------------------------------
1.7 Analysis: Monetary Band Distribution
----------------------------------------------------------
Purpose:
- Classify customers based on their overall monetary value to the business.
- Highlight spend patterns across the portfolio for strategic focus.

Business Questions:
- What is the monetary distribution of our customer base?
- Are there high spenders concentrated in a small segment?
- Can we prioritize high-value segments for loyalty or retention programs?

Suggested Use:
- Power BI bar charts by spend bands
- Segmentation to identify high CLV opportunities
- Cross-sell and upsell strategy design
---------------------------------------------------------- */
SELECT
    CASE
        WHEN monetary_score = 5 THEN 'High Spend (>100000)'
        WHEN monetary_score = 4 THEN 'Mid-High Spend (50000–10000)'
        WHEN monetary_score = 3 THEN 'Mid Spend (25000–50000)'
        WHEN monetary_score = 2 THEN 'Low Spend (10000–25000)'
        ELSE 'Very Low Spend (<10000)'
    END AS Spend_Band,
    COUNT(*) AS Customer_Count
FROM vw_CreditCard_RFM
GROUP BY Spend_Band;


/* ----------------------------------------------------------
1.8 Analysis: Segmentation Insights (RFM Summary)
----------------------------------------------------------
Purpose:
- Summarize behavioral metrics for each RFM-based segment.
- Understand average spending, recency, and frequency within segments.

Business Questions:
- How do Premium, Loyal, Potential, and At Risk segments behave differently?
- Which segments have the highest spend per customer?
- Which segments are most actively transacting?

Suggested Use:
- Power BI segment-level bar/heatmap
- Inform loyalty campaigns or risk-mitigation strategies
---------------------------------------------------------- */
SELECT
    CASE
        WHEN (recency_score + frequency_score + monetary_score) >= 11 THEN 'Premium'
        WHEN (recency_score + frequency_score + monetary_score) >= 9 THEN 'Loyal'
        WHEN (recency_score + frequency_score + monetary_score) >= 6 THEN 'Potential'
        ELSE 'At Risk'
    END AS RFM_Segment,
    ROUND(AVG(frequency), 2) AS Avg_Transactions,
    ROUND(AVG(monetary), 2) AS Avg_Spend,
    ROUND(AVG(recency_days), 2) AS Avg_Recency_Days
FROM vw_CreditCard_RFM
GROUP BY RFM_Segment
ORDER BY RFM_Segment;

/* ----------------------------------------------------------
1.9 Analysis: Export Full RFM Segmentation
----------------------------------------------------------
Purpose:
- Provide a ready-to-use table of all customers with their RFM labels.
- Allow downstream tools (Power BI, CRM systems) to import segmentation data.
- Enable data analysts to join with other datasets for further enrichment.

Business Questions:
- What is each customer’s RFM score and segment label?
- How many customers are premium vs. loyal vs. potential vs. at risk?
- Can this be tracked over time for cohort analysis?

Suggested Use:
- Power BI slicers to filter customers by RFM segment
- CSV export for marketing automation tools
- Base table for tracking changes in segmentation
---------------------------------------------------------- */
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    RFM_Total,
    RFM_Segment
FROM vw_CreditCard_RFM
ORDER BY RFM_Total DESC;

/* ------------------------------------------------------------
2.1 Analysis: Customer Active Years
------------------------------------------------------------
Purpose:
- Measure the longevity of customers in the dataset.
- Identify which customers have the longest continuous engagement.

Business Questions:
- How many years has each customer been active?
- Are loyal customers active for more years than at-risk customers?
- Should retention campaigns prioritize long-tenure customers?

Suggested Use:
- Power BI visual showing active years distribution
- Filter for customer loyalty segmentation
------------------------------------------------------------ */

WITH longevity AS (
	SELECT 
		cc_num AS customer_id,
		MIN(trans_date_trans_time) AS first_transaction,
		MAX(trans_date_trans_time) AS recent_transaction
	FROM
		transactions_fraud
	GROUP BY cc_num
),
customer_active_years AS (
	SELECT 
		customer_id,
		first_transaction,
		YEAR(first_transaction),
		YEAR(recent_transaction),
		recent_transaction,
		YEAR(recent_transaction) - YEAR(first_transaction) AS active_years
	FROM
		longevity
)
SELECT 
    *
FROM
    customer_active_years;

/* ------------------------------------------------------------
2.2 Analysis: Average Transaction Value Trend Over Years
------------------------------------------------------------
Purpose:
- Track how average transaction amounts have changed year over year.
- Identify whether customers are spending more or less over time.

Business Questions:
- Is the average transaction size increasing or decreasing?
- Should pricing or marketing be adapted to changing spend patterns?
- Are higher-value customers increasing their average purchase size?

Suggested Use:
- Power BI line or column chart by year
- Trend analysis for pricing, loyalty, or promotions
------------------------------------------------------------ */
SELECT 
    YEAR(trans_date_trans_time) AS txn_year,
    ROUND(AVG(amt), 2) AS avg_transaction_value,
    COUNT(*) AS num_transactions
FROM transactions_fraud
GROUP BY txn_year
ORDER BY txn_year ASC;

/* ------------------------------------------------------------
2.3 Analysis: Loyal Customer Candidates
------------------------------------------------------------
Purpose:
- Identify customers with both high transaction frequency and long active history.
- Spot potential candidates for loyalty programs or tier upgrades.

Business Questions:
- Which customers have repeatedly transacted over multiple years?
- Do they show consistent engagement that can be rewarded?
- Are there customers worth prioritizing for relationship-building?

Suggested Use:
- Power BI table with top loyal customers
- Loyalty program targeting lists
------------------------------------------------------------ */
SELECT 
    cc_num AS customer_id,
    COUNT(*) AS total_transactions,
    MIN(YEAR(trans_date_trans_time)) AS first_year,
    MAX(YEAR(trans_date_trans_time)) AS last_year,
    (MAX(YEAR(trans_date_trans_time)) - MIN(YEAR(trans_date_trans_time)) + 1) AS active_years
FROM transactions_fraud
GROUP BY cc_num
HAVING total_transactions > 100
   AND active_years >= 2
ORDER BY total_transactions DESC;

/* ------------------------------------------------------------
3.1 Analysis: Customer Lifetime Value (CLV)
------------------------------------------------------------
Purpose:
- Estimate the total revenue contribution of each customer over their lifetime.
- Support customer valuation models and retention prioritization.

Business Questions:
- Who are our most valuable customers?
- What is their average revenue per transaction?
- Are there high-value customers we should proactively engage?

Suggested Use:
- Power BI leaderboard table
- Executive summary for top contributors
------------------------------------------------------------ */
SELECT 
    cc_num AS customer_id,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amt),2) AS total_revenue,
    ROUND(AVG(amt),2) AS avg_revenue_per_txn,
    ROUND(SUM(amt) / COUNT(*), 2) AS avg_revenue_per_order
FROM transactions_fraud
GROUP BY cc_num
ORDER BY total_revenue DESC
LIMIT 10;


/* ------------------------------------------------------------
3.2 Analysis: Average Revenue per Order by RFM Segment
------------------------------------------------------------
Purpose:
- Understand how average revenue per order varies across RFM segments.
- Spot high-value segments for upselling or retention initiatives.

Business Questions:
- Do premium or loyal customers generate higher average revenue?
- Should pricing or rewards be adjusted based on segment?

Suggested Use:
- Heatmap or bar chart by RFM segment in Power BI
- Cross-segmentation opportunity with demographics
------------------------------------------------------------ */

SELECT
    RFM_Segment,
    ROUND(AVG(monetary), 2) AS avg_spend,
    ROUND(AVG(frequency), 2) AS avg_txn_count,
    ROUND(AVG(monetary) / NULLIF(AVG(frequency), 0), 2) AS avg_revenue_per_order
FROM vw_CreditCard_RFM
GROUP BY RFM_Segment
ORDER BY avg_spend DESC;

/*
---------------------------------------------------------------
End of File — 03_RFM_Analysis.sql
Project: Credit Card Analytics
Summary:
- Developed an end-to-end RFM segmentation model including recency, frequency, and monetary scoring.
- Created a permanent view (`vw_CreditCard_RFM`) for future use in dashboards or analysis.
- Generated loyalty queries (active years, transaction value trends) to supplement RFM findings.
- Built a customer lifetime value (CLV) leaderboard to identify top contributors.

Next Steps:
- Incorporate these insights into Power BI as slicers or additional visuals.
- Schedule regular RFM recalculation with data refreshes.
- Explore cross-segmentation joins once consistent unique keys are aligned across datasets.

Author: Saharsh Nagisetty
---------------------------------------------------------------
*/

