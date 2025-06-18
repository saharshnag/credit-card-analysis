/* =====================================================================================================================================
Filename: 01_ETL_Data_Preparation.sql
Project: Credit Card Analytics
Purpose: Contains SQL scripts to perform data extraction, transformation, and loading (ETL) for the Credit Card Analytics dataset.

Author: Saharsh Nagisetty
Notes:
- This file prepares the raw data for analysis.
- Steps include importing CSV data, cleaning duplicates, transforming fields, and creating normalized tables.
- The output of this file is used by 02_Core_Analysis.sql for business analysis and visualization.
=======================================================================================================================================*/


-- ===================================
-- Step 1: Create and Use Schema
-- ===================================

-- Create Schema 
CREATE DATABASE IF NOT EXISTS credit_card_analytics;

-- Use the schema
USE credit_card_analytics;

-- ===================================
-- Step 2: Create Table — credit_risk_uci
-- ===================================

-- Create table with appropriate datatypes and primary key

CREATE TABLE credit_risk_uci (
    ID INT PRIMARY KEY,
    LIMIT_BAL BIGINT,
    SEX TINYINT,
    EDUCATION TINYINT,
    MARRIAGE TINYINT,
    AGE INT,
    PAY_0 TINYINT,
    PAY_2 TINYINT,
    PAY_3 TINYINT,
    PAY_4 TINYINT,
    PAY_5 TINYINT,
    PAY_6 TINYINT,
    BILL_AMT1 BIGINT,
    BILL_AMT2 BIGINT,
    BILL_AMT3 BIGINT,
    BILL_AMT4 BIGINT,
    BILL_AMT5 BIGINT,
    BILL_AMT6 BIGINT,
    PAY_AMT1 BIGINT,
    PAY_AMT2 BIGINT,
    PAY_AMT3 BIGINT,
    PAY_AMT4 BIGINT,
    PAY_AMT5 BIGINT,
    PAY_AMT6 BIGINT,
    default_payment_next_month TINYINT
);

-- ===================================
-- Step 3: Import CSV Data
-- ===================================

/* Load the dataset from credit_risk_uci file
--------------------------------------------------
Steps: 
1. Right-click your schema > Table Data Import Wizard
2. Select the CSV file (e.g., credit_risk_uci.csv)
3. Map CSV columns to table columns
4. Complete the import
*/

-- ===================================
-- Step 4: Initial Validation
-- ===================================

-- check the row count

SELECT 
    COUNT(*)
FROM
    credit_card_analytics.credit_risk_uci;
    
-- Preview first 10 rows   
 
SELECT 
    *
FROM
    credit_risk_uci
LIMIT 10;

-- View distinct values of the target variable

SELECT DISTINCT
    default_payment_next_month
FROM
    credit_risk_uci;
    
-- ===================================
-- Step 5: Create Table — transactions_fraud
-- ===================================
    
-- Create table for partly cleaned data set, designate a primary key and data types for all the columns

CREATE TABLE transactions_fraud (
    trans_date_trans_time DATETIME,
    cc_num VARCHAR(30),
    merchant VARCHAR(100),
    category VARCHAR(50),
    amt FLOAT,
    first VARCHAR(50),
    last VARCHAR(50),
    gender CHAR(1),
    street VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(5),
    zip INT,
    lat FLOAT,
    longi FLOAT,
    city_pop INT,
    job VARCHAR(100),
    dob DATE,
    trans_num VARCHAR(50),
    unix_time BIGINT,
    merch_lat FLOAT,
    merch_long FLOAT,
    is_fraud TINYINT,
    merch_zipcode VARCHAR(10)
);

-- ===================================
-- Step 6: Load Cleaned CSV Data
-- ===================================

-- Loading data using INFILE method

LOAD DATA INFILE 'C:\Users\sahar\Documents\Projects\Credit Card Analytics Project\archive(2)\credit_card_transactions_clean'
INTO TABLE transactions_fraud
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Check if secure_file_priv is restricting file access

SHOW VARIABLES LIKE 'secure_file_priv';

-- ===================================
-- Step 7: Validate Import
-- ===================================

-- Preview first 10 rows    

SELECT 
    *
FROM
    credit_card_analytics.transactions_fraud
LIMIT 10;

-- check row count

SELECT 
    COUNT(*)
FROM
    credit_card_analytics.transactions_fraud;


-- ===================================
-- Step 8: Primary Key Identification
-- ===================================
/*
Goal:
- Check if trans_num column is suitable as primary key.
- A good primary key must contain only unique, non-null values.
*/

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT trans_num) AS distinct_trans_ids
FROM transactions_fraud;

-- Since counts match, assigning PRIMARY KEY to trans_num
    
ALTER TABLE transactions_fraud
ADD PRIMARY KEY (trans_num(50));

-- Verify Index

SHOW INDEX FROM transactions_fraud;

-- ===================================
-- ETL Summary
-- ===================================
/*
Filename: 01_ETL_Data_Preparation.sql
Project: Credit Card Analytics
Summary:
- Data extraction, transformation, and loading completed.
- Raw data cleaned and normalized using Python and SQL.
- Final tables prepared for use in downstream analysis and BI dashboards.

Author: Saharsh Nagisetty
Notes:
- Maintain ETL scripts carefully if raw data source changes.
- Ensure consistency in data quality for all future analysis.
*/