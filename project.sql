
CREATE TABLE online_retail_ii (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,2),
    CustomerID INT,
    Country VARCHAR(50)
);
-- Cleaned data
CREATE TABLE Cleaned_Retail AS
SELECT *
FROM online_retail_ii
WHERE InvoiceNo IS NOT NULL
  AND StockCode IS NOT NULL
  AND Description IS NOT NULL
  AND Quantity IS NOT NULL
  AND InvoiceDate IS NOT NULL
  AND UnitPrice IS NOT NULL
  AND CustomerID IS NOT NULL;
CREATE TABLE Enriched_Retail AS
SELECT *,
       Quantity * UnitPrice AS TotalSales,
       Quantity * UnitPrice * 0.30 AS Profit,
       0.30 AS ProfitMargin
FROM Cleaned_Retail;
CREATE TABLE Seasonal_Retail AS
SELECT *,
       CASE 
           WHEN MONTH(InvoiceDate) IN (12, 1, 2) THEN 'Winter'
           WHEN MONTH(InvoiceDate) IN (3, 4, 5) THEN 'Spring'
           WHEN MONTH(InvoiceDate) IN (6, 7, 8) THEN 'Summer'
           ELSE 'Autumn'
       END AS Season
FROM Enriched_Retail;
SELECT Description,
       SUM(Quantity) AS TotalQuantity,
       SUM(TotalSales) AS TotalSales,
       SUM(Profit) AS TotalProfit,
       ROUND(SUM(Profit) / NULLIF(SUM(TotalSales), 0), 2) AS ProfitMargin
FROM Seasonal_Retail
GROUP BY Description
ORDER BY TotalProfit ASC;
SELECT 
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month,
    SUM(TotalSales) AS MonthlySales,
    SUM(Profit) AS MonthlyProfit
FROM Seasonal_Retail
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY Month;
SELECT Country,
       SUM(TotalSales) AS TotalSales,
       SUM(Profit) AS TotalProfit,
       COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM Seasonal_Retail
GROUP BY Country
ORDER BY TotalProfit DESC;
SELECT Description,
       SUM(Quantity) AS TotalQuantity,
       SUM(TotalSales) AS TotalSales,
       SUM(Profit) AS TotalProfit
FROM Seasonal_Retail
GROUP BY Description
HAVING SUM(TotalSales) < 500 AND SUM(Quantity) > 1000
ORDER BY TotalSales ASC;
CREATE TABLE Dashboard_View AS
SELECT 
    Description,
    Country,
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month,
    Season,
    SUM(Quantity) AS TotalQuantity,
    SUM(TotalSales) AS TotalSales,
    SUM(Profit) AS TotalProfit
FROM Seasonal_Retail
GROUP BY 
    Description, Country, DATE_FORMAT(InvoiceDate, '%Y-%m'), Season;














