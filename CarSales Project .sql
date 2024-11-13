--Data Cleaning

SELECT *
FROM `boxing-quest-1234-2005.CarSales_dataset.CarSales`;

--1.Remove Duplicates
--2.Standardize Data
--3.Null Values or Blank values
--4.Remove Any Columns

CREATE TABLE CarSales_dataset.CarSales_staging
LIKE `CarSales_dataset.CarSales`;

SELECT *
FROM `boxing-quest-1234-2005.CarSales_dataset.CarSales_staging`;

INSERT `boxing-quest-1234-2005.CarSales_dataset.CarSales_staging`
SELECT *
FROM `boxing-quest-1234-2005.CarSales_dataset.CarSales`;

--Creating a table to remove duplicates

CREATE OR REPLACE TABLE boxing-quest-1234-2005.CarSales_dataset.CarSales_staging AS
SELECT *
FROM boxing-quest-1234-2005.CarSales_dataset.CarSales_staging
WHERE CONCAT(Year, Month, `Date`, `Model`, `Dealer ID`, `Quantity Sold`, Profit) NOT IN (
    SELECT CONCAT(Year, Month, `Date`, `Model`, `Dealer ID`, `Quantity Sold`, Profit)
    FROM boxing-quest-1234-2005.CarSales_dataset.CarSales_staging
    GROUP BY Year, Month, `Date`, `Model`, `Dealer ID`, `Quantity Sold`, Profit
    HAVING COUNT(*) > 1
);

--checking if there are any duplicates left

SELECT Year, Month, `Date`, `Model`, `Dealer ID`, `Quantity Sold`, Profit, COUNT(*)
FROM boxing-quest-1234-2005.CarSales_dataset.CarSales_staging
GROUP BY Year, Month, `Date`, `Model`, `Dealer ID`, `Quantity Sold`, Profit
HAVING COUNT(*) > 1;

--Standardizing Data

SELECT Month, TRIM(Month) AS Trimmed_Month
FROM `boxing-quest-1234-2005.CarSales_dataset.CarSales_staging`;

UPDATE `boxing-quest-1234-2005.CarSales_dataset.CarSales_staging`
SET Month = TRIM(Month)
WHERE Month IS NOT NULL;

ALTER TABLE `boxing-quest-1234-2005.CarSales_dataset.CarSales_staging`
ADD COLUMN Formatted_Profit STRING;

UPDATE `boxing-quest-1234-2005.CarSales_dataset.CarSales_staging`
SET Formatted_Profit = FORMAT('$%.2f', Profit)
WHERE Profit IS NOT NULL;

SELECT *
FROM `boxing-quest-1234-2005.CarSales_dataset.CarSales_staging`;

ALTER TABLE `boxing-quest-1234-2005.CarSales_dataset.CarSales_staging`
DROP COLUMN Profit;

SELECT `date`,
       DATE(CAST(`date` AS TIMESTAMP)) AS parsed_date
FROM `boxing-quest-1234-2005.CarSales_dataset.CarSales_staging`;

UPDATE `boxing-quest-1234-2005.CarSales_dataset.CarSales_staging`
SET `date` = CAST(DATE(CAST(`date` AS TIMESTAMP)) AS STRING)
WHERE TRUE;

ALTER TABLE `boxing-quest-1234-2005.CarSales_dataset.CarSales_staging`
  RENAME COLUMN Formatted_Profit TO Profit;

SELECT 
  COUNTIF(Year IS NULL) AS Year_nulls,
  COUNTIF(Month IS NULL) AS Month_nulls,
  COUNTIF(`Model` IS NULL) AS `Model_nulls`,
  COUNTIF(`Dealer ID` IS NULL) AS `Dealer ID_nulls`,
  COUNTIF(`Quantity Sold` IS NULL) AS `Quantity Sold_nulls`,
  COUNTIF(Profit IS NULL) AS Profit_nulls,
  COUNTIF(`date` IS NULL) AS `date_nulls`
FROM `boxing-quest-1234-2005.CarSales_dataset.CarSales_staging`;

SELECT * FROM `boxing-quest-1234-2005.CarSales_dataset.CarSales_staging`