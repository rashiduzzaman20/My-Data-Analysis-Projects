-- RFM Segementation: Recency, Frequency, and Monetary information based Segmentation of Customers
-- Creating the Database
CREATE DATABASE IF NOT EXISTS RFM_SEGMENTATION;
USE RFM_SEGMENTATION;
CREATE TABLE SALES_DATA (
    ORDERNUMBER	INT,
    QUANTITYORDERED	INT,
    PRICEEACH	INT,
    ORDERLINENUMBER	INT,
    SALES	DOUBLE,
    ORDERDATE	VARCHAR(512),
    STATUS	VARCHAR(512),
    QTR_ID	INT,
    MONTH_ID	INT,
    YEAR_ID	INT,
    PRODUCTLINE	VARCHAR(512),
    MSRP	INT,
    PRODUCTCODE	VARCHAR(512),
    CUSTOMERNAME	VARCHAR(512),
    PHONE	VARCHAR(512),
    ADDRESSLINE_1	VARCHAR(512),
    ADDRESSLINE_2	VARCHAR(512),
    CITY	VARCHAR(512),
    STATE	VARCHAR(512),
    POSTALCODE VARCHAR(512),
    COUNTRY	VARCHAR(512),
    TERRITORY	VARCHAR(512),
    CONTACTLASTNAME	VARCHAR(512),
    CONTACTFIRSTNAME	VARCHAR(512),
    DEALSIZE	VARCHAR(512)
);

-- Inspecting Data
SELECT * FROM SALES_DATA LIMIT 5;
SELECT COUNT(*) AS TOTAL_ROW FROM SALES_DATA; -- Total number of records is 2823

-- Checking unique values
SELECT DISTINCT STATUS FROM SALES_DATA; 
SELECT DISTINCT YEAR_ID FROM SALES_DATA;
SELECT DISTINCT PRODUCTLINE FROM SALES_DATA;
SELECT DISTINCT COUNTRY FROM SALES_DATA;
SELECT DISTINCT DEALSIZE FROM SALES_DATA;
SELECT DISTINCT TERRITORY FROM SALES_DATA;

SELECT DISTINCT MONTH_ID
FROM SALES_DATA
WHERE YEAR_ID = 2005
ORDER BY 1;

SELECT YEAR_ID, SUM(SALES) AS REVENUE
FROM SALES_DATA
GROUP BY 1
ORDER BY 1;

-- Analysis
-- Let's start by grouping sales by productline
SELECT ORDERNUMBER, ORDERLINENUMBER, PRODUCTLINE, SALES, 
       ORDERDATE, STATUS, QTR_ID, MONTH_ID, YEAR_ID,
       MSRP, PRODUCTCODE, CUSTOMERNAME, PHONE, 
       ADDRESSLINE1, ADDRESSLINE2, CITY, STATE, 
       POSTALCODE, COUNTRY, TERRITORY, 
       CONTACTLASTNAME, CONTACTFIRSTNAME, DEALSIZE
FROM SALES_DATA
ORDER BY ORDERNUMBER, ORDERLINENUMBER
LIMIT 100;

SELECT PRODUCTLINE, ROUND(SUM(SALES),0) AS REVENUE, COUNT(DISTINCT ORDERNUMBER) AS NO_OF_ORDERS
FROM SALES_DATA
GROUP BY PRODUCTLINE
ORDER BY 3 DESC;

SELECT YEAR_ID, SUM(SALES) REVENUE
FROM SALES_DATA
GROUP BY YEAR_ID
ORDER BY 2 DESC;


SELECT  DEALSIZE, SUM(SALES) REVENUE
FROM SALES_DATA
GROUP BY DEALSIZE
ORDER BY 2 DESC;

-- November seems to be the month, what product did they sell in November, Classic I believe
SELECT  PRODUCTLINE, SUM(SALES) REVENUE, COUNT(ORDERNUMBER) FREQUENCY
FROM SALES_DATA
WHERE YEAR_ID = 2004 AND MONTH_ID = 11 -- CHANGE YEAR TO SEE THE REST
GROUP BY  MONTH_ID, PRODUCTLINE
ORDER BY REVENUE DESC;

-- What was the best month for sales in a specific year? How much was earned that month? 
SELECT  MONTH_ID, SUM(SALES) REVENUE, COUNT(ORDERNUMBER) FREQUENCY
FROM SALES_DATA
WHERE YEAR_ID = 2004 -- CHANGE YEAR TO SEE THE REST
GROUP BY  MONTH_ID
ORDER BY 2 DESC;

-- Who is our best customer (this could be best answered with RFM)
-- SELECT DATE_FORMAT(STR_TO_DATE(ORDERDATE, '%d/%m/%y'), '%Y-%m-%d') AS converted_date 
-- FROM SALES_SAMPLE_DATA;
SELECT ORDERDATE FROM SALES_DATA LIMIT 5;
SELECT STR_TO_DATE(ORDERDATE, '%d/%m/%y') AS `Date` FROM SALES_DATA LIMIT 5;

SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) AS LATESTDATE from SALES_DATA; -- 2005-05-31: Last Transaction Date
SELECT MIN(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) AS EARLIESTDATE from SALES_DATA; -- 2003-01-06 : First Transaction Date

SELECT 
    DATEDIFF(MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')), MIN(STR_TO_DATE(ORDERDATE, '%d/%m/%y'))) AS 'Range' 
    FROM SALES_DATA; -- Range of Transaction is 876 Days

-- RFM SEGMENTATION: SEGMENTING YOUR CUSTOMER BASEN ON RECENCY (R), FREQUENCY (F), AND MONETARY (M) SCORES
SELECT
    CUSTOMERNAME,
    ROUND(SUM(SALES),0) AS MonetaryValue,
    COUNT(DISTINCT ORDERNUMBER) AS Frequency,
    -- MAX(STR_TO_DATE(ORDERDATE,' %d/%m/%y')) AS EACH_CUSTOMERS_LAST_TRANSACTION_DATE,
    -- (SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) FROM SALES_SAMPLE_DATA) AS BUSINESS_LAST_TRANSACTION_DATE,
    DATEDIFF(MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')), (SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) FROM SALES_DATA))*(-1)   AS Recency
FROM SALES_DATA
GROUP BY CUSTOMERNAME;

CREATE VIEW RFM_SEGMENT AS 
WITH RFM_INITIAL_CALC AS (
   SELECT
    CUSTOMERNAME,
    ROUND(SUM(SALES),0) AS MonetaryValue,
    COUNT(DISTINCT ORDERNUMBER) AS Frequency,
    -- MAX(STR_TO_DATE(ORDERDATE,' %d/%m/%y')) AS EACH_CUSTOMERS_LAST_TRANSACTION_DATE,
    -- (SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) FROM SALES_SAMPLE_DATA) AS BUSINESS_LAST_TRANSACTION_DATE,
    DATEDIFF(MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')), (SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) FROM SALES_DATA)) * (-1) AS Recency
FROM SALES_DATA
GROUP BY CUSTOMERNAME
),
RFM_SCORE_CALC AS (
    SELECT 
        C.*,
        NTILE(5) OVER (ORDER BY C.Recency DESC) AS RFM_RECENCY_SCORE,
        NTILE(5) OVER (ORDER BY C.Frequency ASC) AS RFM_FREQUENCY_SCORE,
        NTILE(5) OVER (ORDER BY C.MonetaryValue ASC) AS RFM_MONETARY_SCORE
    FROM 
        RFM_INITIAL_CALC AS C
)
SELECT
    R.CUSTOMERNAME,
    (R.RFM_RECENCY_SCORE + R.RFM_FREQUENCY_SCORE + R.RFM_MONETARY_SCORE) AS TOTAL_RFM_SCORE,
    CONCAT_WS(
		'', R.RFM_RECENCY_SCORE, R.RFM_FREQUENCY_SCORE, R.R.RFM_MONETARY_SCORE
    ) AS RFM_CATEGORY_COMBINATION
FROM 
    RFM_SCORE_CALC AS R; 

SELECT * FROM RFM_SEGMENT as R join  RFM_SCORE_CALC as C on R.cutomername = C.customername;

SELECT DISTINCT RFM_CATEGORY_COMBINATION 
FROM RFM_SEGMENT
ORDER BY 1 DESC;

-- First digit is Recency Score, Secend digit is Frequency Score and Third digit is Monetary Score
SELECT 
    CUSTOMERNAME,
    CASE
        WHEN RFM_CATEGORY_COMBINATION IN (555, 545, 551, 552) THEN 'Champions' 
        WHEN RFM_CATEGORY_COMBINATION IN (353, 354, 355, 453, 454, 455, 553, 554, 445, 314, 324, 335, 434, 435) THEN 'Loyal Customers'
        WHEN RFM_CATEGORY_COMBINATION IN (533, 534, 543, 544, 413, 414, 423, 424, 431, 432) THEN 'Potential Loyalists'
        WHEN RFM_CATEGORY_COMBINATION IN (511, 512, 521, 522, 441, 442, 451, 452) THEN 'Recent Customers'
        WHEN RFM_CATEGORY_COMBINATION IN (315, 415, 325, 425, 531, 532, 541, 542) THEN 'Big Spenders'
        WHEN RFM_CATEGORY_COMBINATION IN (133, 134, 135, 143, 144, 145, 233, 234, 235, 243, 244, 245, 131, 132, 141, 142, 151, 152, 153, 154, 155) THEN 'At-Risk Customers'
		WHEN RFM_CATEGORY_COMBINATION IN (333, 334, 433, 343, 443, 344, 444, 341, 342, 351, 352, 535) THEN 'Need Attention'
		WHEN RFM_CATEGORY_COMBINATION IN (322, 311, 312, 321, 411, 412, 421, 422, 313, 323, 331, 332) THEN 'Promising'
		WHEN RFM_CATEGORY_COMBINATION IN (111, 112, 122, 121, 211, 212, 221, 222, 231, 232, 241, 242, 251, 252, 253, 254, 255
			) THEN 'Hibernating'
		WHEN RFM_CATEGORY_COMBINATION IN (113, 114, 115, 123, 124, 125, 213, 214, 215, 223, 224, 225, 513, 514, 515, 523, 524, 525
			) THEN 'Lost Customers'
    ELSE 'CANNOT BE DEFINED'
    END AS CUSTOMER_SEGMENT
FROM RFM_SEGMENT;

WITH CTE1 AS
(SELECT 
    CUSTOMERNAME,
    CASE
        WHEN RFM_CATEGORY_COMBINATION IN (555, 545, 551, 552) THEN 'Champions' 
        WHEN RFM_CATEGORY_COMBINATION IN (353, 354, 355, 453, 454, 455, 553, 554, 445, 314, 324, 335, 434, 435) THEN 'Loyal Customers'
        WHEN RFM_CATEGORY_COMBINATION IN (533, 534, 543, 544, 413, 414, 423, 424, 431, 432) THEN 'Potential Loyalists'
        WHEN RFM_CATEGORY_COMBINATION IN (511, 512, 521, 522, 441, 442, 451, 452) THEN 'Recent Customers'
        WHEN RFM_CATEGORY_COMBINATION IN (315, 415, 325, 425, 531, 532, 541, 542) THEN 'Big Spenders'
        WHEN RFM_CATEGORY_COMBINATION IN (133, 134, 135, 143, 144, 145, 233, 234, 235, 243, 244, 245, 131, 132, 141, 142, 151, 152, 153, 154, 155) THEN 'At-Risk Customers'
		WHEN RFM_CATEGORY_COMBINATION IN (333, 334, 433, 343, 443, 344, 444, 341, 342, 351, 352, 535) THEN 'Need Attention'
		WHEN RFM_CATEGORY_COMBINATION IN (322, 311, 312, 321, 411, 412, 421, 422, 313, 323, 331, 332) THEN 'Promising'
		WHEN RFM_CATEGORY_COMBINATION IN (111, 112, 122, 121, 211, 212, 221, 222, 231, 232, 241, 242, 251, 252, 253, 254, 255
			) THEN 'Hibernating'
		WHEN RFM_CATEGORY_COMBINATION IN (113, 114, 115, 123, 124, 125, 213, 214, 215, 223, 224, 225, 513, 514, 515, 523, 524, 525
			) THEN 'Lost Customers'
    ELSE 'CANNOT BE DEFINED'
    END AS CUSTOMER_SEGMENT
FROM RFM_SEGMENT)

-- Total Customers in each Segment
SELECT CUSTOMER_SEGMENT, COUNT(*) AS TOTAL_CUSTOMER
FROM CTE1
GROUP BY CUSTOMER_SEGMENT
ORDER BY COUNT(*) DESC;

-- WHAT TYPE OF ACTION NEEDED FOR EACH CUSTOMER ACCORDING TO THEIR BEHAVIOR(CUSTOMER_SEGMENT)
SELECT CUSTOMERNAME, CUSTOMER_SEGMENT, 
		CASE 
			WHEN CUSTOMER_SEGMENT = 'Champions' THEN 'Reward loyalty with exclusive offers and VIP treatment.'
            WHEN CUSTOMER_SEGMENT = 'Loyal Customers' THEN 'Keep engaged with personalized offers and loyalty programs.'
            WHEN CUSTOMER_SEGMENT = 'Potential Loyalists' THEN 'Build relationships with tailored engagement campaigns.'
            WHEN CUSTOMER_SEGMENT = 'Recent Customers' THEN 'Onboard with welcome emails, incentives for second purchases.'
            WHEN CUSTOMER_SEGMENT = 'Big Spenders' THEN 'Upsell and cross-sell with premium or related products.'
            WHEN CUSTOMER_SEGMENT = 'At-Risk Customers' THEN 'Re-engage with win-back campaigns and special discounts.'
            WHEN CUSTOMER_SEGMENT = 'Need Attention' THEN 'Encourage more frequent purchases with targeted offers.'
            WHEN CUSTOMER_SEGMENT = 'Promising' THEN 'Nurture interest with product recommendations and promotions.'
            WHEN CUSTOMER_SEGMENT = 'Hibernating' THEN 'Minimal investment; occasionally send reminders or low-cost incentives.'
            WHEN CUSTOMER_SEGMENT = 'Lost Customers' THEN 'Attempt to win back with exclusive or personalized offers.'
		END AS ACTION_NEEDED
FROM CTE1;
