# RFM Segmentation
RFM (Recency, Frequency, Monetary) segmentation is a method used by businesses to categorize customers based on their transactional behavior. This segmentation approach helps in understanding customer value and behavior, enabling targeted marketing and customer relationship management strategies.git 
## Why we should go through in this process
RFM segmentation involves calculating recency, frequency, and monetary scores for each customer and then categorizing them into segments based on these scores. The provided SQL script segments customers into different categories, such as 'Champions', 'Loyal Customers', 'Potential Loyalists', 'Recent Customers', 'Big Spenders', 'At-Risk Customers', 'Need Attention', 'Promising', 'Hibernating' and 'Lost Customers'.

## The meaning of that ten segments  
| **Segment Name**       | **RFM Characteristics**      | **Description**        |  
|------------------------|------------------------------|------------------------| 
|Champions|High Recency (R), High Frequency (F), High Monetary (M)|Your best customers who are highly engaged, spend the most, and purchase frequently.|  
|Loyal Customers|Medium-to-High Recency (R), High Frequency (F), Medium-to-High Monetary (M)|Regular buyers who contribute significant value over time.|  
|Potential Loyalists|High Recency (R), Medium Frequency (F), Medium Monetary (M)|Newer customers showing promise for long-term loyalty.|  
|Recent Customers|High Recency (R), Low Frequency (F), Low Monetary (M)|Customers who have made a recent purchase but are not frequent buyers.|  
|Big Spenders|Medium Recency (R), Low Frequency (F), High Monetary (M)|Customers who spend a lot in fewer transactions.|  
|At-Risk Customers|Low Recency (R), Medium-to-High Frequency (F), Medium-to-High Monetary (M)|Previously valuable customers who have not purchased recently.|  
|Need Attention|Medium Recency (R), Medium Frequency (F), Medium Monetary (M)|Customers with moderate engagement and value.|  
|Promising|Medium Recency (R), Low Frequency (F), Low Monetary (M)|Customers with moderate recency but limited spending and frequency.|  
|Hibernating|Low Recency (R), Low Frequency (F), Low Monetary (M)|Customers who haven’t purchased for a long time and have low overall value.|  
|Lost Customers|Low Recency (R), Low Frequency (F), Medium-to-High Monetary (M)|Customers who were once high-value but haven’t purchased in a long time.|  

## Database Setup
- Create a database named `RFM_SEGMENTATION`  
```SQL
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
```  
- Import wizard data  
## Dataset Exploration
```SQL
SELECT * FROM SALES_DATA LIMIT 5;
```  
### --OUTPUT--  
| ORDERNUMBER | QUANTITYORDERED | PRICEEACH | ORDERLINENUMBER | SALES   | ORDERDATE | STATUS   | QTR_ID | MONTH_ID | YEAR_ID | PRODUCTLINE   | MSRP | PRODUCTCODE | CUSTOMERNAME              | PHONE        | ADDRESSLINE1                    | ADDRESSLINE2 | CITY          | STATE | POSTALCODE | COUNTRY | TERRITORY | CONTACTLASTNAME | CONTACTFIRSTNAME | DEALSIZE |
|-------------|-----------------|-----------|-----------------|---------|-----------|----------|--------|----------|---------|---------------|------|-------------|--------------------------|--------------|--------------------------------|--------------|---------------|-------|------------|---------|-----------|------------------|------------------|----------|
| 10107       | 30.00          | 95.70     | 2               | 2871.00 | 24/2/03   | Shipped  | 1      | 2        | 2003    | Motorcycles   | 95   | S10_1678    | Land of Toys Inc.        | 2125557818   | 897 Long Airport Avenue        |              | NYC           | NY    | 10022      | USA     | NA        | Yu               | Kwai             | Small    |
| 10121       | 34.00          | 81.35     | 5               | 2765.90 | 7/5/03    | Shipped  | 2      | 5        | 2003    | Motorcycles   | 95   | S10_1678    | Reims Collectables       | 26.47.1555   | 59 rue de l'Abbaye            |              | Reims         |       | 51100      | France  | EMEA      | Henriot          | Paul             | Small    |
| 10134       | 41.00          | 94.74     | 2               | 3884.34 | 1/7/03    | Shipped  | 3      | 7        | 2003    | Motorcycles   | 95   | S10_1678    | Lyon Souveniers          | +33 1 46 62 7555 | 27 rue du Colonel Pierre Avia |              | Paris         |       | 75508      | France  | EMEA      | Da Cunha         | Daniel           | Medium   |
| 10145       | 45.00          | 83.26     | 6               | 3746.70 | 25/8/03   | Shipped  | 3      | 8        | 2003    | Motorcycles   | 95   | S10_1678    | Toys4GrownUps.com        | 6265557265   | 78934 Hillside Dr.            |              | Pasadena      | CA    | 90003      | USA     | NA        | Young            | Julie            | Medium   |
| 10159       | 49.00          | 100.00    | 14              | 5205.27 | 10/10/03  | Shipped  | 4      | 10       | 2003    | Motorcycles   | 95   | S10_1678    | Corporate Gift Ideas Co. | 6505551386   | 7734 Strong St.               |              | San Francisco | CA    |            | USA     | NA        | Brown            | Julie            | Medium   |
  
```SQL
SELECT COUNT(*) AS TOTAL_ROW FROM SALES_DATA; -- Total number of records is 2823
```  
## -- OUTPUT --  
| Metric     | Value |
|------------|-------|
| COUNT(*)   | 2823  |

## Checking unique status for order  
```SQL
SELECT DISTINCT STATUS FROM SALES_DATA; -- Unique STATUS
```
## -- OUTPUT --    
| Status       |
|--------------|
| Shipped      |
| Disputed     |
| In Process   |
| Cancelled    |
| On Hold      |
| Resolved     |
  
## How many years of data are in the database?  
```SQL
SELECT DISTINCT YEAR_ID FROM SALES_DATA;
```
## -- OUTPUT --   
| Year_ID |
|---------|
| 2003    |
| 2004    |
| 2005    |

## Unique Productline
```SQL
SELECT DISTINCT PRODUCTLINE FROM SALES_DATA;
```
## -- OUTPUT --   
| ProductLine      |
|------------------|
| Motorcycles      |
| Classic Cars     |
| Trucks and Buses |
| Vintage Cars     |
| Planes           |
| Ships            |
| Trains           |

## Unique Country
```SQL
SELECT DISTINCT COUNTRY FROM SALES_DATA;
```
## -- OUTPUT --   
| Country       |
|---------------|
| USA           |
| France        |
| Norway        |
| Australia     |
| Finland       |
| Austria       |
| UK            |
| Spain         |
| Sweden        |
| Singapore     |
| Canada        |
| Japan         |
| Italy         |
| Denmark       |
| Belgium       |
| Philippines   |
| Germany       |
| Switzerland   |
| Ireland       |

## Type of Dealsize
```SQL
SELECT DISTINCT DEALSIZE FROM SALES_DATA;
```
## -- OUTPUT --   
| DealSize |
|----------|
| Small    |
| Medium   |
| Large    |

## Territory
```SQL
SELECT DISTINCT TERRITORY FROM SALES_DATA;
```
## -- OUTPUT --    
| Territory |
|-----------|
| NA        |
| EMEA      |
| APAC      |
| Japan     |

## Analysis
This SQL query calculates the RFM (Recency, Frequency, Monetary) values for each customer in the dataset  
```SQL
SELECT
    CUSTOMERNAME,
    ROUND(SUM(SALES),0) AS MonetaryValue,
    COUNT(DISTINCT ORDERNUMBER) AS Frequency,
    -- MAX(STR_TO_DATE(ORDERDATE,' %d/%m/%y')) AS EACH_CUSTOMERS_LAST_TRANSACTION_DATE,
    -- (SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) FROM SALES_SAMPLE_DATA) AS BUSINESS_LAST_TRANSACTION_DATE,
    DATEDIFF(MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')), (SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) FROM SALES_DATA))*(-1)   AS Recency
FROM SALES_DATA
GROUP BY CUSTOMERNAME;
```
## -- OUTPUT --  
| CUSTOMERNAME                | MonetaryValue | Frequency | Recency |
|-----------------------------|---------------|-----------|---------|
| Alpha Cognac                | 70488         | 3         | 64      |
| Amica Models & Co.          | 94117         | 2         | 264     |
| Anna's Decorations, Ltd     | 153996        | 4         | 83      |
| Atelier graphique           | 24180         | 3         | 187     |
| Australian Collectables, Ltd| 64591         | 3         | 22      |
| ...                         | ...           | ...       | ...     |

This SQL code creates a view named RFM_SEGMENT, which calculates the RFM (Recency, Frequency, Monetary) scores and combines them into a single RFM category combination for each customer.  
```SQL
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

SELECT * FROM RFM_SEGMENT;
```
## -- OUTPUT --    
| CUSTOMERNAME             | TOTAL_RFM_SCORE | RFM_CATEGORY_COMBINATION |
|--------------------------|------------------|---------------------------|
| Boards & Toys Co.        | 6                | 321                       |
| Atelier graphique        | 5                | 221                       |
| Auto-Moto Classics Inc.  | 7                | 331                       |
| ...                      | ...              | ...                       |
  
```SQL
SELECT DISTINCT RFM_CATEGORY_COMBINATION 
FROM RFM_SEGMENT
ORDER BY 1 DESC;
```

## -- OUTPUT -- 
First digit is Recency Score, Secend digit is Frequency Score and Third digit is Monetary Score 
| RFM_CATEGORY_COMBINATION |
|---------------------------|
| 444                       |
| 443                       |
| 442                       |
| 433                       |
| 432                       |
| 424                       |
| ...                       |
  
This SQL code segment assigns a customer segment label based on their RFM category combination  
```SQL
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
```
## -- OUTPUT --  
| CUSTOMERNAME                       | CUSTOMER_SEGMENT  |
|------------------------------------|-------------------|
| Boards & Toys Co.                  | Promising         |
| Atelier graphique                  | Hibernating       |
| Auto-Moto Classics Inc.            | Promising         |
| Microscale Inc.                    | Hibernating       |
| Royale Belge                       | Need Attention    |
| Bavarian Collectables Imports, Co. | Hibernating       |
| ...                                | ...               |

This SQL code utilizes a common table expression (CTE) named CTE1 to assign customer segments based on their RFM category combinations. It then counts the number of customers in each segment and presents the result.  
```SQL
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

SELECT CUSTOMER_SEGMENT, COUNT(*) AS TOTAL_CUSTOMER
FROM CTE
GROUP BY CUSTOMER_SEGMENT
ORDER BY COUNT(*) DESC;
```
## -- OUTPUT --   
| CUSTOMER_SEGMENT    | TOTAL_CUSTOMER |
|---------------------|----------------|
| Hibernating         | 29             |
| Need Attention      | 29             |
| Lost Customers      | 15             |
| Promising           | 10             |
| Potential Loyalists | 6              |
| At-Risk Customers   | 2              |
| Recent Customers    | 1              |
  
#### WHAT TYPE OF ACTION NEEDED FOR EACH CUSTOMER ACCORDING TO THEIR BEHAVIOR(CUSTOMER_SEGMENT). 
```SQL
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
```
## -- OUTPUT --  
| CUSTOMERNAME                          | CUSTOMER_SEGMENT | ACTION_NEEDED                                                               |
|---------------------------------------|------------------|-------------------------------------------------------------------------------|
| Boards & Toys Co.                     | Promising        | Nurture interest with product recommendations and promotions.                 |
| Atelier graphique                     | Hibernating      | Minimal investment; occasionally send reminders or low-cost incentives.        |
| Auto-Moto Classics Inc.               | Promising        | Nurture interest with product recommendations and promotions.                 |
| Microscale Inc.                       | Hibernating      | Minimal investment; occasionally send reminders or low-cost incentives.        |
| Royale Belge                          | Need Attention   | Encourage more frequent purchases with targeted offers.                       |
| Bavarian Collectables Imports, Co.    | Hibernating      | Minimal investment; occasionally send reminders or low-cost incentives.        |
| Double Decker Gift Stores, Ltd        | Hibernating      | Minimal investment; occasionally send reminders or low-cost incentives.        |
| Cambridge Collectables Co.            | Hibernating      | Minimal investment; occasionally send reminders or low-cost incentives.        |
| West Coast Collectables Co.           | Hibernating      | Minimal investment; occasionally send reminders or low-cost incentives.        |
| Men 'R' US Retailers, Ltd.            | Hibernating      | Minimal investment; occasionally send reminders or low-cost incentives.        |
| CAF Imports                           | Hibernating      | Minimal investment; occasionally send reminders or low-cost incentives.        |
| Signal Collectibles Ltd.              | Hibernating      | Minimal investment; occasionally send reminders or low-cost incentives.        |
| Mini Auto Werke                       | Promising        | Nurture interest with product recommendations and promotions.                 |
| Iberia Gift Imports, Corp.           | Hibernating      | Minimal investment; occasionally send reminders or low-cost incentives.        |
| Online Mini Collectables              | Hibernating      | Minimal investment; occasionally send reminders or low-cost incentives.        |
| Gift Ideas Corp.                      | Promising        | Nurture interest with product recommendations and promotions.                 |
| Clover Collections, Co.               | Hibernating      | Minimal investment; occasionally send reminders or low-cost incentives.        |
| ...                                   | ...              | ...                                                                           |









