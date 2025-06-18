/*=====================================================================================================================================
Filename: 02_Core_Analysis.sql
Project: Credit Card Analytics
Purpose: Contains analytical SQL queries to explore fraud patterns, early risk prediction indicators, and payment trends.

Author: Saharsh Nagisetty
Notes:
- This file complements 01_ETL_Data_Preparation.sql, which performs initial data extraction and cleaning.
- Queries in this file are designed to discover key insights, support dashboard visuals and executive reporting.
======================================================================================================================================*/

/*===================================================================
📊 Phase 1: Exploratory Analysis — transactions_fraud Table (Fraud Dataset)
=====================================================================
Objective:
Explore fraudulent behavior patterns to support fraud detection dashboard and define key metrics for business risk alerts.

Focus Areas:
🔹 1. Basic fraud stats
🔹 2. Trends by category, amount, and time
🔹 3. Customer demographics & behavior
🔹 4. Location-based insights
🔹 5. Outlier detection and early indicators
================================================================== */

/* -----------------------------------------------
Part 1: Basic Fraud Statistics
Purpose:
- Establish overall fraud rate
- Identify fraud frequency by category, amount, and time
------------------------------------------------ */

/*
---------------------------------------------------
1.1 Analysis: Overall Fraud Rate in Transaction Dataset
---------------------------------------------------
Purpose:
- Establish a baseline understanding of fraud prevalence in the dataset.
- Calculate total volume of transactions and number of fraudulent events.

Business Questions:
- What is the overall fraud rate across all transactions?
- How many fraudulent transactions are present in the data?
---------------------------------------------------*/


SELECT 
    COUNT(*) AS Total_Transactions,
    SUM(is_fraud) AS Total_Frauds,
    ROUND((SUM(is_fraud) / COUNT(*)) * 100, 2) AS Fraud_Rate_Percent
FROM transactions_fraud;

/*
-------------------------------------------------------------
1.2 Analysis: Fraud Count and Rate by Merchant Category
-------------------------------------------------------------
Purpose:
- Identify high-risk merchant categories prone to fraudulent transactions.

Business Questions:
- Which categories have the highest fraud rates?
- Are there specific merchant types that attract more fraud?

Metrics:
- Fraud Rate = Total Frauds / Total Transactions
-------------------------------------------------------------*/

SELECT 
    category,
    COUNT(*) AS Total_Transactions,
    SUM(is_fraud) AS Total_Frauds,
    ROUND((SUM(is_fraud) / COUNT(*)) * 100, 2) AS Fraud_Rate_Percent
FROM
    transactions_fraud
GROUP BY category
ORDER BY Fraud_Rate_Percent DESC;

/*
------------------------------------------------------------------
1.3 Analysis: Fraud Rate by Transaction Amount Band
------------------------------------------------------------------
Purpose:
- Segment transactions into monetary bands to study fraud patterns.

Business Questions:
- Are high-value transactions more susceptible to fraud?
- What transaction ranges should be flagged for enhanced scrutiny?

Metrics:
- Amount Bands: < $10, $10–$50, $50–$100, $100–$500, > $500
- Fraud Rate = Total Frauds / Total Transactions (within each band)
------------------------------------------------------------------
*/

SELECT 
    CASE
        WHEN amt < 10 THEN 'tx < $10'
        WHEN amt < 50 THEN 'tx betw $10-$50'
        WHEN amt < 100 THEN 'tx betw $50-$100'
        WHEN amt < 500 THEN 'tx betw $100-$500'
        ELSE 'tx > $500'
    END AS Amount_Band,
    count(*) AS Total_Transactions,
    SUM(is_fraud) AS Total_Frauds,
    ROUND((SUM(is_fraud) / COUNT(*)) * 100, 2) AS Fraud_Rate_Percent
FROM
    transactions_fraud
group by Amount_Band
ORDER BY Fraud_Rate_Percent DESC;

/*
-------------------------------------------------------
1.4 Analysis: Hourly Trend of Fraudulent Transactions
-------------------------------------------------------
Purpose:
- Explore temporal fraud patterns to identify risk-prone time windows.

Business Questions:
- What time of day sees the highest fraud activity?
- Should anti-fraud systems focus more on certain hours?

Metrics:
- Fraud Rate by Hour (0–23)
-------------------------------------------------------
*/

SELECT 
	hour(trans_date_trans_time) AS Hour_of_day,
    count(*) AS Total_Transactions,
    SUM(is_fraud) AS Total_Frauds,
    ROUND((SUM(is_fraud) / COUNT(*)) * 100, 2) AS Fraud_Rate_Percent
FROM
    transactions_fraud
group by Hour_of_day
ORDER BY Hour_of_day;

/*
==================================================================================
🧠 Analyst Insights: Fraud Trends — Summary of Key Observations & Recommendations
==================================================================================

| Observation                                                                           | Interpretation                                                                         | Suggested Analyst Action                                   |
|---------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|------------------------------------------------------------|
| ⏰ Fraud spikes between 10 PM – 3 AM                                                  | Fraudsters are more active late at night, possibly exploiting lower monitoring levels  | Add time-of-day fraud alerts; adjust fraud scoring weights |
| 💸 Highest fraud % in `>$500` band/category                                           | High-value transactions are more lucrative targets                                     | Trigger manual review or 2FA for transactions > $500       |
| 🛍️ Fraud-prone categories: `shopping_net`, `misc_net`, `grocery_pos`, `shopping_pos`  | High-volume or lightly verified merchants may be vulnerable                            | Build category-specific fraud models or merchant risk tiers|
==================================================================================
*/

/* ------------------------------------------------------------
Part 2: Demographics & Customer Behavior
Purpose:
- Analyze customer attributes (age, gender, job) linked to fraud.
- Understand behavior patterns and segment-specific vulnerabilities.
- Support customer-level fraud scoring and segmentation strategies.

Business Questions:
- Are certain demographic segments more prone to fraud?
- How does age or gender correlate with fraud rates?
- Do specific jobs, names, or behaviors reveal risk patterns?
------------------------------------------------------------- */

/* ------------------------------------------------------------
2.1 Analysis: Gender-Based Fraud Patterns
------------------------------------------------------------
Purpose:
- Compare fraud rate across male and female customers.
- Understand gender-specific vulnerabilities or patterns.

Business Questions:
- Do males or females experience more fraud relative to their total transactions?
- Should fraud prevention strategies differ by gender?
------------------------------------------------------------ */

SELECT 
	gender,
    count(*) AS Total_Transactions,
    SUM(is_fraud) AS Total_Frauds,
    ROUND((SUM(is_fraud) / COUNT(*)) * 100, 2) AS Fraud_Rate_Percent
FROM
    transactions_fraud
group by gender
ORDER BY gender;

/* ------------------------------------------------------------
2.2 Analysis: Age-Based Fraud Patterns
------------------------------------------------------------
Purpose:
- Assess fraud rate across age bands to find vulnerable age groups.

Business Questions:
- Which age segments experience higher fraud rates?
- Do younger or older users need more fraud education or monitoring?
------------------------------------------------------------ */

SELECT 
	CASE
		WHEN (YEAR(sysdate()) - YEAR(dob)) < 20 THEN 'Under 20 years old'
        WHEN (YEAR(sysdate()) - YEAR(dob)) < 30 THEN '21-30 years old'
        WHEN (YEAR(sysdate()) - YEAR(dob)) < 40 THEN '31-40 years old'
        WHEN (YEAR(sysdate()) - YEAR(dob)) < 50 THEN '41-50 years old'
        WHEN (YEAR(sysdate()) - YEAR(dob)) < 60 THEN '51-60 years old'
        else 'Over 65 years old'
	END AS Age_bracket,
    count(*) AS Total_Transactions,
    SUM(is_fraud) AS Total_Frauds,
    ROUND((SUM(is_fraud) / COUNT(*)) * 100, 2) AS Fraud_Rate_Percent
FROM
    transactions_fraud
group by Age_bracket
ORDER BY Age_bracket;

/* ------------------------------------------------------------
2.3 Analysis: High-Risk Occupations
------------------------------------------------------------
Purpose:
- Identify customer job titles associated with high fraud rates.
- Detect fraud-prone professions and apply risk-based monitoring.

Business Questions:
- Which occupations have the highest fraud rate?
- Are job-related attributes useful for fraud scoring models?

Metric Notes:
- Only jobs with > 1000 transactions included to reduce noise.
------------------------------------------------------------ */

SELECT 
	job,
    count(*) AS Total_Transactions,
    SUM(is_fraud) AS Total_Frauds,
    ROUND((SUM(is_fraud) / COUNT(*)) * 100, 2) AS Fraud_Rate_Percent
FROM
    transactions_fraud
group by job
having count(*) > 1000 						-- to filter out noise
ORDER BY Fraud_Rate_Percent DESC
LIMIT 10;

/* ------------------------------------------------------------
2.4 Analysis: Customer Spending Behavior
------------------------------------------------------------
Purpose:
- Explore customer-level transaction volume and value.
- Understand average transaction size and identify heavy spenders.

Business Questions:
- Who are the highest spenders?
- What is the typical spend and fraud count per customer?

Metrics:
- num_of_tx = number of transactions per card
- total_spend = cumulative transaction value
- average_tx_value = mean transaction value
------------------------------------------------------------ */

SELECT 
    first AS First_Name,
    last AS Last_Name,
    COUNT(*) AS Num_of_Tx,
    ROUND(SUM(amt), 2) AS Total_Spend,
    ROUND(AVG(amt), 2) AS Average_Tx_Value,
    SUM(is_fraud) AS Total_Frauds
FROM
    transactions_fraud
GROUP BY cc_num;

/* =========================================================
🧠 Analyst Insights — Demographic & Customer Patterns
===========================================================

| Observation                                                               | Insight                                                                                      | Implication for Analysis / Business                                                          |
| ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| 🔢 983 unique customers (`cc_num`)                                        | High transaction volume per user (~1 300+ txns) → synthetic / simulation-style data          | In real life this density is rare, but pattern analysis is still valuable                    |
| 🔊 Dataset has a lot of noise                                             | Many job titles, ZIP codes, and low-volume groups                                            | Apply thresholds (e.g., jobs with >1 000 txns) to reduce noise in dashboards                 |
| 👴🧒 Fraud highest in 21–30 yrs & 65+                                      | Young adults and seniors may be less cautious or more targeted                               | Flag these age brackets for heightened monitoring / segmentation scoring                     |
| 👩‍🦰 Female customers transact more; 👨 male fraud rate higher               | Gender itself isn’t causal but correlates with behavior/spend                                | Use as a slice in visuals; don’t rely on gender alone for risk models                        |
================================================================ */

/* -----------------------------------------------
Part 3: Geographic Trends
Purpose:
- Analyze fraud distribution across states, cities, and population clusters.
- Identify geographic hotspots and high-risk regions.
- Support location-specific fraud mitigation strategies.
------------------------------------------------ */

/*
-------------------------------------------------------
3.1 Analysis: Fraud Rate by U.S. State
-------------------------------------------------------
Purpose:
- Identify which states have the highest fraud incidence.
- Support fraud prevention through geo-targeted controls or flagging.

Business Questions:
- Are certain U.S. states disproportionately affected by fraud?
- Do we see any patterns linked to state-level fraud rates?

Notes:
- May be useful to filter out low-volume states for clarity.
- Use slicers in Power BI to drill into specific state-level trends.
-------------------------------------------------------
*/

SELECT 
	state,
    count(*) AS Total_Transactions,
    SUM(is_fraud) AS Total_Frauds,
    ROUND((SUM(is_fraud) / COUNT(*)) * 100, 2) AS Fraud_Rate_Percent
FROM
    transactions_fraud
group by state
-- having count(*) > 1000 						-- Uncomment to remove low-volume states
ORDER BY Fraud_Rate_Percent DESC;

/*
---------------------------------------------------------------------------
3.2 Analysis: Merchant-Customer Location Gap (Distance Proxy)
---------------------------------------------------------------------------
Purpose:
- Identify how far transactions are happening from customers' home locations.
- Use spatial mismatch as a proxy for potentially suspicious activity.

Business Questions:
- Are fraudulent transactions happening far from customers’ homes?
- Which states show the largest average merchant-customer distance?

Metric Notes:
- Distance is approximated using abs(lat - merch_lat) + abs(long - merch_long).
- Not a true geodistance, but still highlights unusual location activity.

Suggested Use:
- Power BI map visuals or distance bands
- Fraud scoring models or manual review thresholds
---------------------------------------------------------------------------
*/

SELECT 
    state,
    ROUND(AVG(amt),2) AS Avg_Transaction,
    ROUND((SUM(is_fraud) / COUNT(*)) * 100, 2) AS Fraud_Rate_Percent,
    CONCAT(ROUND(AVG(ABS(lat - merch_lat) + ABS(transactions_fraud.long - merch_long)),4), " mile") AS Avg_Distance_Proxy
FROM transactions_fraud
GROUP BY state
ORDER BY Fraud_Rate_Percent DESC;

/*
----------------------------------------------------------
3.3 Analysis: Fraud Distribution by City Population Band
----------------------------------------------------------
Purpose:
- Investigate whether small towns or large cities experience more fraud.
- Classify cities into bands by population and compare fraud rates.

Business Questions:
- Does fraud vary based on the size of the customer’s city?
- Are fraudsters more active in less populated or more populated zones?

Suggested Use:
- Power BI slicers and bar charts by population segment
- Campaigns or alerts based on population-risk linkage
----------------------------------------------------------
*/

SELECT 
	CASE
		WHEN city_pop < 1000 THEN 'Less Than 1,000'
        WHEN city_pop < 10000 THEN '1,000-10,000'
        WHEN city_pop < 100000 THEN '10,000-100,000'
        WHEN city_pop < 1000000 THEN '100,000-1,000,000'
        else 'Over 1,000,000'
	END AS Population_Bracket,
    count(*) AS Total_Transactions,
    SUM(is_fraud) AS Total_Frauds,
    ROUND((SUM(is_fraud) / COUNT(*)) * 100, 2) AS Fraud_Rate_Percent
FROM
    transactions_fraud
group by Population_Bracket
ORDER BY Population_Bracket ASC;

/*
==================================================================================
🧠 Analyst Insights: Geographic Trends — Summary of Key Observations & Recommendations
==================================================================================
| Observation                                                     | Insight                                                          | Business/Analytical Action                                                                  |
| --------------------------------------------------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| 🔴 State **DE (Delaware)** has 100% fraud on <10 transactions   | Outlier — likely statistical noise from small sample size        | In dashboard, **filter out states with low volume (<500 txns)** to avoid misleading visuals |
| 📍 Fraud occurs mostly **within ~1 mile of customer location**  | Indicates proximity-based fraud (e.g., cloned cards used locally) | Flag suspiciously close matches for further risk scoring                                    |
| 🌆 Fraud is more frequent in **larger cities (100K–1M pop)**    | High-volume areas → more opportunity, weaker identity checks     | Visualize fraud heatmap by city size or segment large urban zones separately                |
*/

/*
===================================================================
📊 Phase 2: Exploratory Analysis — credit_risk_uci Table (Risk Dataset)
===================================================================
Objective:
Understand credit default risk by analyzing payment history, demographics, and financial behavior.

Focus Areas:
🔹 1. Overall default rate
🔹 2. Demographic impact on default
🔹 3. Credit limit vs default behavior
🔹 4. Payment history patterns (PAY_0 to PAY_6)
🔹 5. Billing vs payment trends
===================================================================
*/

/*
-------------------------------------------------------------
Part 1 - Analysis: Credit Default Rate — Overall and Demographic Trends
-------------------------------------------------------------
Purpose:
- Establish overall default rate among credit card holders.
- Understand how default likelihood varies across demographic segments.

Business Questions:
- What is the overall credit default rate in the dataset?
- Are certain genders, age groups, or marital statuses more likely to default?
- How does credit limit or education level affect default risk?

Metrics:
- Default Rate = % of customers with `default_payment_next_month = 1`
- Segmentation: Gender, Education, Marital Status, Age Bands, Credit Limit Bands
-------------------------------------------------------------
*/

/* ----------------------------------------------------------
1.1 Analysis: Overall Default Rate
-------------------------------------------------------------
Purpose:
- Measure the total number of customers and calculate what percentage defaulted on payments.

Business Questions:
- What is the baseline credit default rate in this customer portfolio?
- Is it high enough to trigger concern for credit policy?

Suggested Use:
- Power BI KPI card to track default rate
- Executive summary slide or trend baseline
------------------------------------------------------------- */
SELECT 
    COUNT(*) AS Total_customers,
    SUM(default_payment_next_month) AS Total_defaulters,
    ROUND((SUM(default_payment_next_month) / COUNT(*)) * 100,
            2) AS Overall_default_rate
FROM
    credit_risk_uci;
    

/* ----------------------------------------------------------
1.2 Analysis: Default Rate by Gender
-------------------------------------------------------------
Purpose:
- Compare credit default behavior between male and female customers.

Business Questions:
- Do male or female customers default more frequently?
- Is gender a meaningful factor in credit risk models?

Suggested Use:
- Donut chart or clustered bar chart showing default rate by gender
- Optional segmentation feature for model enrichment
------------------------------------------------------------- */

SELECT 
    Case
		WHEN SEX = 1 THEN 'Male'
        ELSE 'Female'
	END AS Gender,
    COUNT(*) AS Total_customers,
    SUM(default_payment_next_month) AS Total_defaulters,
    ROUND((SUM(default_payment_next_month) / COUNT(*)) * 100,
            2) AS Default_rate_percent
FROM
    credit_risk_uci
GROUP BY SEX;

/* ----------------------------------------------------------
1.3 Analysis: Default Rate by Education Level
-------------------------------------------------------------
Purpose:
- Examine how educational attainment correlates with payment default.

Business Questions:
- Are higher education levels associated with greater financial responsibility?
- Do less-educated segments pose higher risk?

Suggested Use:
- Bar chart sorted by default rate descending
- Filter for credit risk scoring and behavioral profiling
------------------------------------------------------------- */

SELECT 
    Case
		WHEN EDUCATION = 6 THEN 'Primary School Grad'
        WHEN EDUCATION = 5 THEN 'Middle School Grad'
        WHEN EDUCATION = 4 THEN 'High School Grad'
        WHEN EDUCATION = 3 THEN 'UnderGrad'
        WHEN EDUCATION = 2 THEN 'PostGrad'
        WHEN EDUCATION = 1 THEN 'PHD Level or higher'
        ELSE 'Uneducated'
	END AS Education_Level,
    COUNT(*) AS Total_customers,
    SUM(default_payment_next_month) AS Total_defaulters,
    ROUND((SUM(default_payment_next_month) / COUNT(*)) * 100,
            2) AS Default_rate_percent
FROM
    credit_risk_uci
GROUP BY EDUCATION
ORDER BY Default_rate_percent DESC;

/* ----------------------------------------------------------
1.4 Analysis: Default Rate by Marital Status
-------------------------------------------------------------
Purpose:
- Understand how marital status relates to credit risk and likelihood of default.

Business Questions:
- Are single or married individuals more likely to default?
- Should family structure inform credit allocation or education?

Suggested Use:
- Segmented bar chart for demographic comparison
- Optional demographic filter in dashboards
------------------------------------------------------------- */

SELECT 
    Case
		WHEN MARRIAGE = 1 THEN 'Married'
        WHEN MARRIAGE = 2 THEN 'Single'
        WHEN MARRIAGE = 3 THEN 'Divorced'
        ELSE 'Engaged'
	END AS Marital_status,
    COUNT(*) AS Total_customers,
    SUM(default_payment_next_month) AS Total_defaulters,
    ROUND((SUM(default_payment_next_month) / COUNT(*)) * 100,
            2) AS Default_rate_percent
FROM
    credit_risk_uci
GROUP BY MARRIAGE
ORDER BY Default_rate_percent DESC;

/* ----------------------------------------------------------
1.5 Analysis: Default Rate by Credit Limit Band
-------------------------------------------------------------
Purpose:
- Determine whether customers with higher credit limits are less likely to default.

Business Questions:
- Is credit limit a predictor of responsible financial behavior?
- Can limits be adjusted based on historical risk tiers?

Suggested Use:
- Histogram or bar chart by credit limit band
- Use as credit scoring or segmentation factor
------------------------------------------------------------- */

SELECT 
    Case
		WHEN LIMIT_BAL < 50000 THEN '< $50,000'
        WHEN LIMIT_BAL < 100000 THEN '$50,000 - $100,000'
        WHEN LIMIT_BAL < 250000 THEN '$100,000 - $250,000'
        WHEN LIMIT_BAL < 500000 THEN '$250,000 - $500,000'
        ELSE '> $500,000'
	END AS Credit_limit_bands,
    COUNT(*) AS Total_customers,
    SUM(default_payment_next_month) AS Total_defaulters,
    ROUND((SUM(default_payment_next_month) / COUNT(*)) * 100,
            2) AS Default_rate_percent
FROM
    credit_risk_uci
GROUP BY Credit_limit_bands
ORDER BY Default_rate_percent DESC;

/* ----------------------------------------------------------
1.6 Analysis: Default Rate by Age Band
-------------------------------------------------------------
Purpose:
- Analyze how customer age influences likelihood of default.

Business Questions:
- Are older or younger customers more prone to miss payments?
- Should age be a factor in targeted risk communication?

Suggested Use:
- Line or bar chart showing age vs default risk
- Age-based flags or reminders in customer outreach
------------------------------------------------------------- */

SELECT 
    Case
		WHEN AGE < 30 THEN '21-30 years'
        WHEN AGE < 40 THEN '31-40 years'
        WHEN AGE < 50 THEN '41-50 years'
        WHEN AGE < 60 THEN '51-60 years'
        ELSE '> 65 years'
	END AS Age_bands,
    COUNT(*) AS Total_customers,
    SUM(default_payment_next_month) AS Total_defaulters,
    ROUND((SUM(default_payment_next_month) / COUNT(*)) * 100,
            2) AS Default_rate_percent
FROM
    credit_risk_uci
GROUP BY Age_bands
ORDER BY Default_rate_percent DESC;
/*
==================================================================================
🧠 Analyst Insights: Default Rate & Demographics — Summary of Key Observations & Recommendations
==================================================================================
| Dimension                 | Your Observations                                                         | Interpretation                                                                                           |
| ------------------------- | ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| 🧑‍🤝‍🧑 Gender                | More female customers overall, but male default rate is ~4% higher        | Could reflect riskier financial behavior or overextension in male segment                                |
| 🎓 Education              | Undergrad & Postgrad segments have higher default rates                   | Possibly due to student loans or early-career financial strain; Uneducated segment may lack access       |
| 💍 Marital Status         | Divorced has highest rate, but small sample size; Married > Single        | Divorce-related financial stress likely; Married = dependents or joint obligations                       |
| 💳 Credit Limit Bands     | Default rate drops sharply as credit limit increases                      | Suggests higher-limit holders are more creditworthy and financially responsible                          |
| 📊 Age Bands              | Age 50+ groups show higher default rate                                   | May struggle with tech-based payments or face memory/health-related barriers                             |
| 📉 Default Rate Baseline | All age groups have ≥20% default rate                                     | Indicates overall risk exposure — calls for closer look at repayment behavior and transaction trends     |
*/

/*
------------------------------------------------------------
Part 2: Repayment History — PAY_0 to PAY_6 Columns
------------------------------------------------------------
Purpose:
- Analyze repayment behavior and its correlation with default.
- Identify whether payment delays in recent months predict risk.

Business Questions:
- Are delayed payments strong predictors of default?
- How does payment status trend over months for defaulters vs. non-defaulters?
- Can we use repayment patterns to flag early signs of financial distress?

Metric Notes:
- PAY_X values:
    -2 = No consumption, -1 = Paid in full, 0 = Paid on time
    1+ = Payment delayed by X months

Next:
- We’ll compute trends, compare PAY_X distributions by defaulters vs non-defaulters, and evaluate delay frequencies.
------------------------------------------------------------
*/

/* ----------------------------------------------------------
2.1 Analysis: PAY_0 Distribution vs Default Rate
-------------------------------------------------------------
Purpose:
- Assess how repayment status in PAY_0 correlates with default behavior.

Business Questions:
- Does a delay in most recent payment (PAY_0) indicate higher risk?
- Which PAY_0 values signal the highest default rates?

Suggested Use:
- Bar chart in Power BI with PAY_0 values on X-axis and default rate on Y-axis
- Risk tier grouping for credit modeling
------------------------------------------------------------- */

SELECT 
    PAY_0,
    COUNT(*) AS total_customers,
    SUM(default_payment_next_month) AS defaulters,
    ROUND(SUM(default_payment_next_month) / COUNT(*) * 100, 2) AS default_rate_percent
FROM credit_risk_uci
GROUP BY PAY_0
ORDER BY PAY_0;

/* ----------------------------------------------------------
2.2 Analysis: PAY_2 Distribution vs Default Rate
-------------------------------------------------------------
Purpose:
- Examine the impact of prior payment behavior (second most recent month).

Business Questions:
- How predictive is PAY_2 status for customer default risk?
- Are late payers in month -2 more likely to default next?

Suggested Use:
- Compare with PAY_0 chart to show decaying predictiveness
- Use as early indicator in credit scoring models
------------------------------------------------------------- */
SELECT 
    PAY_2,
    COUNT(*) AS total_customers,
    SUM(default_payment_next_month) AS defaulters,
    ROUND(SUM(default_payment_next_month) / COUNT(*) * 100, 2) AS default_rate_percent
FROM credit_risk_uci
GROUP BY PAY_2
ORDER BY PAY_2;

/* ----------------------------------------------------------
2.3 Analysis: PAY_3 Distribution vs Default Rate
-------------------------------------------------------------
Purpose:
- Understand how historical payment behavior (third most recent month) influences default risk.

Business Questions:
- Does customer reliability degrade or improve over time?
- How significant is PAY_3 in predicting future defaults?

Suggested Use:
- Create stacked bar visuals for PAY_0 to PAY_3 to show pattern over time
- Use in scoring formula weight calibration
------------------------------------------------------------- */
SELECT 
    PAY_3,
    COUNT(*) AS total_customers,
    SUM(default_payment_next_month) AS defaulters,
    ROUND(SUM(default_payment_next_month) / COUNT(*) * 100, 2) AS default_rate_percent
FROM credit_risk_uci
GROUP BY PAY_3
ORDER BY PAY_3;

/* ----------------------------------------------------------
2.4 Analysis: Payment Behavior Bands vs Default
-------------------------------------------------------------
Purpose:
- Classify customers by total missed payments and measure default risk per group.

Business Questions:
- How does cumulative payment behavior correlate with default?
- Can we categorize customers into risk tiers based on past performance?

Suggested Use:
- Heatmap or donut chart showing band-wise contribution to defaults
- Risk tier segmentation for internal credit controls
------------------------------------------------------------- */
SELECT 
    CASE
        WHEN (PAY_0 + PAY_2 + PAY_3 + PAY_4 + PAY_5 + PAY_6) <= 0 THEN 'Never Late'
        WHEN (PAY_0 + PAY_2 + PAY_3 + PAY_4 + PAY_5 + PAY_6) BETWEEN 1 AND 5 THEN 'Low Risk'
        WHEN (PAY_0 + PAY_2 + PAY_3 + PAY_4 + PAY_5 + PAY_6) BETWEEN 6 AND 15 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS payment_behavior_band,
    COUNT(*) AS total_customers,
    SUM(default_payment_next_month) AS defaulters,
    ROUND(SUM(default_payment_next_month) / COUNT(*) * 100, 2) AS default_rate_percent
FROM credit_risk_uci
GROUP BY payment_behavior_band;

/* ----------------------------------------------------------
Analysis: Average Billing vs Payment Amount
-------------------------------------------------------------
Purpose:
- Compare average billed amount with average repayment to gauge repayment ratio.

Business Questions:
- Are customers paying off their full bill, partial, or very little?
- What is the repayment-to-bill ratio trend across the population?

Suggested Use:
- KPI card in Power BI showing payment ratio %
- Contextual insight for profitability and default risk
------------------------------------------------------------- */
SELECT 
    ROUND(AVG(BILL_AMT1), 2) AS avg_bill_amt,
    ROUND(AVG(PAY_AMT1), 2) AS avg_pay_amt,
    ROUND(AVG(PAY_AMT1) / AVG(BILL_AMT1) * 100, 2) AS avg_payment_ratio_percent
FROM credit_risk_uci;

/*
| Observation                                                        | Interpretation                                             | Business Implication                                                 |
| ------------------------------------------------------------------ | ---------------------------------------------------------- | -------------------------------------------------------------------- |
| 💸 **Avg payment ratio = 10%**                                     | Most customers revolve balance → interest-bearing behavior | 📈 Positive for revenue *if* default remains controlled              |
| ✅ **76% are never late** with <15% default                         | Strong core segment                                        | 📊 Stable risk profile — ideal for upselling, increased limits       |
| 🚨 **Only 10% are Med/High Risk**, but >60% default                | Concentrated risk → big impact                             | 🛑 Target for proactive intervention, lower credit ceilings          |
| 📉 **PAY\_2: 85% good status (-2, -1, 0)** vs **PAY\_0: only 77%** | Most recent month shows **deterioration**                  | ⚠️ Early signal of rising credit risk — implement watchlist triggers |
*/

/*
---------------------------------------------------------------
End of File — 02_Core_Analysis.sql
Project: Credit Card Analysis
Summary:
- Completed core financial and fraud analysis.
- `transactions_fraud`:
  • Analyzed fraud patterns by time, amount, category.
  • Explored demographic (age, gender, job) and geographic (state, city, distance) fraud trends.
- `credit_risk_uci`:
  • Investigated default rates by demographics, credit limit, and age.
  • Assessed repayment history (PAY_0 to PAY_6) and payment behavior patterns.
  • Identified early risk indicators based on missed payment trends.

Next Steps:
- Refine Power BI dashboards based on these insights.
- Implement ongoing data quality checks and refresh pipelines.

Author: Saharsh Nagisetty
---------------------------------------------------------------
*/
