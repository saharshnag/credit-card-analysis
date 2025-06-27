💳 Credit Card Customer Analytics Project
📌 Executive Summary
This project analyzes credit card transactions and customer attributes to uncover fraud trends, credit risk indicators, and customer behavioral patterns. Using SQL, Python, and Power BI, we created an end-to-end analytics pipeline—cleaning data, building analytical queries, and designing interactive dashboards—to assist fraud monitoring, customer segmentation, and credit risk management.

🌟 Project Goals
	- Prepare and clean raw credit card datasets using SQL and Python.
	- Analyze fraudulent transaction trends across time, geography, and customer profiles.
	- Profile customer credit risk using demographic, financial, and repayment data.
	- Segment customers using RFM modeling for loyalty and marketing strategies.
	- Build a Power BI dashboard that supports business decision-making.
	- Document findings for a portfolio-ready case study.

🛠️ Tools & Technologies
	- MySQL 8.0
	- Power BI Desktop
	- Python 3.10 (Pandas, SQLAlchemy)
	- GitHub (Documentation & Hosting)

📂 Data Sources
	- credit_card_transactions_clean.csv (fraud dataset — Kaggle)
	- uci_credit_risk.csv (credit risk dataset — UCI Machine Learning Repo)

🔄 ETL Process Summary
	- Cleaned both datasets in Python (removed PII, fixed column types, dropped irrelevant fields).
	- Imported cleaned data into MySQL using LOAD DATA INFILE and SQLAlchemy.
	- Built three primary tables/views:
		- transactions_fraud: Transaction-level fraud data (incl. time, location, merchant).
		- credit_risk_uci: Customer credit history and repayment attributes.
		- vw_CreditCard_RFM: Recency, Frequency, Monetary segmentation scores with segment labels.
	- Verified schema integrity, primary keys, and nulls.
	- Connected Power BI to MySQL for dashboard development.

📊 Dashboards & Outputs
Dashboard 1 — Credit Risk Overview

	- Default Rate by Gender, Education, Marital Status, Age, and Credit Limit
	- Default Rate by Risk Category (Never Late, Low, Medium and High Risk)
	- Repayment Behavior for PAY_0 
	- KPI Cards: Overall Default Rate, Avg Payment %, Avg Credit Limit, Avg Monthly Bill

Dashboard 2 — Fraud Analytics

	- Fraud by Time of Day
	- Fraud Rate by Category
	- Transaction Amount Bands
	- State-Level Fraud Heatmap
	- Fraud by Age Group, Gender, and Job
	- KPI Cards: Total Transactions, Fraud Transactions, Fraud Rate, Avg Transaction Amount

Dashboard 3 — RFM Segmentation

	- RFM segment distribution (Premium, Loyal, Potential, At Risk)
	- Customers by Monetary bands
	- Customers by Frequency bands
	- Average transaction amount by Month
	- KPI Cards: # of Customers, # of Premium Customers, # of Loyal Customers, # of Potential Customers, # of At-Risk Customers

📂 Outputs / Visuals
Available in outputs/charts/ folder:

	- Credit_Risk_Overview.png
	- Fraud Analysis.png
	- RFM_Segmentation.png
	- Full dashboard export: outputs/Credit_Card_Analytics_Dashboard.pdf

💡 Key Business Insights

	⏰ Fraud peaks at night (10 PM–3 AM) — useful for time-based flagging.
	🛍️ Highest fraud in high-value (> $500) and e-commerce categories.
	👵👦 Fraud risk higher in young adults (21–30) and seniors (65+).
	🌆 Cities with 100K–1M population are fraud hotspots.
	💳 Divorced customers show highest default rate (~30%).
	📉 Only 10% of customers are high-risk, but they account for 60% of defaults.
	💸 Avg payment ratio = 10% of bill → revolving credit behavior.
	🏆 Premium customers identified by RFM account for highest monetary value with recent engagement, ideal for retention.
	⚠️ At Risk customers show poor recency, low frequency, low monetary — target for re-engagement or credit risk alerts.


📖 Project Process & Technical Walkthrough 

Detailed walkthrough of ETL process and workflows, key queries, customer loyalty analysis, reorder behavior, and advanced business insights is documented in the following:


	- `sql/01_ETL_Data_Preparation.sql` – Import, clean, and normalize datasets.
	
	- `sql/02_Core_Analysis.sql` – Fraud analysis, risk profiling, repayment trends.

	- `sql/03_RFM_Analysis.sql` – RFM segmentation scoring, views, and segment-based analysis
	
	- `python/data_preparation.py` – Clean CSVs, transform schema, upload to MySQL.

🗃️ Project Folder Structure
_The folder structure below is the expected project layout, written for readability. The GitHub interface may display folders in a different order._

credit-card-analytics/
├── README.md
├── sql/
│   ├── 01_ETL_Data_Preparation.sql
│   ├── 02_Core_Analysis.sql
│   └── 03_RFM_Analysis.sql
├── python/
│   └── data_preparation.py
├── dashboards/
│   └── Credit_Card_Analytics_Dashboard.pbix
├── outputs/
│   ├── Credit_Card_Analytics_Dashboard.pdf
│   └── charts/
│       ├── Credit-Risk-Overview.png
│       ├── Fraud-Analysis.png
│       └── RFM_Segmentation.png
└── data/
    ├── credit_card_transactions_clean.csv
    └── uci_credit_risk.csv

🚀 How to Run
- Clone the repo.
- Set up MySQL and import data using the SQL and Python scripts.
- Open Power BI Desktop and connect to MySQL.
- Use the .pbix file or build visuals from scratch using provided queries.
- Export visuals or publish dashboard link for stakeholder use.

💌 Contact
For questions or collaboration:
Saharsh Nagisetty | www.linkedin.com/in/saharsh-nagisetty-3718009b