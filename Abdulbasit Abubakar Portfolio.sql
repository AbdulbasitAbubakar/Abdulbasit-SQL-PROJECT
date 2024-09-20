--1. List the orders placed by employees who have sold more than $1 million orth of products.
Select sh.SalesOrderID, sh.SalespersonID as EmployeeID, sh. OrderDate, sh.CustomerID 
From Sales.SalesOrderHeader sh
Where sh.SalesPersonID IN (Select SalesPersonID
From sales.SalesOrderHeader soh_inner
Inner Join Sales.SalesOrderDetail sd 
On soh_inner.salesOrderID=sd.SalesorderID
Group By SalesPersonID
Having Sum (sd.LineTotal)>1000000)
Order By sh.SalesOrderID;

--2. Find the names of products that have been ordered more than once.
SELECT Name
FROM Production.Product
WHERE ProductID IN (
 SELECT ProductID
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING COUNT(*) > 1);

--3.Generate the details of customers who have placed orders in the year 2013
select*
FROM Sales.Customer
WHERE CustomerID IN (
SELECT CustomerID
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '2013-01-01' AND '2013-12-31');

--4. Find the average unit price of products that belong to the 'Bikes' product category.
SELECT AVG(UnitPrice)
FROM Sales.SalesOrderDetail
WHERE ProductID IN (
SELECT ProductID
FROM Production.Product
WHERE ProductSubCategoryID = 1);

--5. Provide the details of products that have never been ordered.
SELECT*
FROM Production.Product
WHERE ProductID NOT IN (
 SELECT ProductID
FROM Sales.SalesOrderDetail);

--6 Find the details of customers who have purchased products from the 'Bikes' category.
SELECT*
FROM Sales.Customer c
INNER JOIN Sales.SalesOrderDetail sod ON c.CustomerID = sod.CustomerID
INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
INNER JOIN Production.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes';

--7. Retrieve which departments have more than 5 employees and list them in descending order based on the number of employees
SELECT hd.Name, COUNT(he.BusinessEntityID)AS TotalEmployees
FROM HumanResources.Employee he
INNER JOIN HumanResources.EmployeeDepartmentHistory hed
ON he.BusinessEntityID = hed.BusinessEntityID
INNER JOIN HumanResources.Department hd
ON hed.DepartmentID = hd.DepartmentID
GROUP BY hd.Name
HAVING COUNT(he.BusinessEntityID) >5
ORDER BY TotalEmployees DESC;

--8. retrieve a list of all employees' full names (which should combine the first name, last name, and middle name with a space
--between the names and a full stop before the middle name), email addresses, and phone numbers.
SELECT CONCAT(pp.FirstName, ' ', pp.LastName, ' ', pp.MiddleName, '.') AS Full_Name, pe.EmailAddress, pph.PhoneNumber
FROM Person.Person pp
INNER JOIN Person.EmailAddress pe
ON pp.BusinessEntityID = pe.BusinessEntityID
INNER JOIN Person.PersonPhone pph
ON pe.BusinessEntityID = pph.BusinessEntityID
WHERE pp.PersonType IN ('EM');

--9. Determine the total sales amount for each product within each territory and rank them in descending order of sales
SELECT pp.Name, sst.Name, SUM(sod.LineTotal) AS TotalSalesAmount   
FROM Sales.SalesOrderDetail sod
INNER JOIN Production.Product pp
ON sod.ProductID = pp.ProductID
INNER JOIN Sales.SalesOrderHeader soh
ON sod.SalesOrderID = soh.SalesOrderID
INNER JOIN Sales.SalesTerritory sst
ON soh.TerritoryID = sst.TerritoryID
WHERE soh.OrderDate LIKE '%2011%'
GROUP BY pp.Name,sst.Name
ORDER BY TotalSalesAmount DESC;

--10. From Production.Product table, get a list of products that have never been sold.
SELECT Name
FROM Production.Product AS p
WHERE p.ProductID NOT IN (
 SELECT DISTINCT ProductID
FROM Sales.SalesOrderDetail);

--11. Find the average order value for each customer who has placed at least 5 orders, and list their names along with the average order value
WITH CustomerOrderCount AS (
    SELECT 
        oh.CustomerID,
        p.FirstName + ' ' + p.LastName AS CustomerName,
        COUNT(oh.SalesOrderID) AS OrderCount,
        AVG(oh.TotalDue) AS AverageOrderValue
    FROM 
        Sales.SalesOrderHeader oh
    JOIN 
        Person.Person p ON oh.CustomerID = p.BusinessEntityID
    GROUP BY 
        oh.CustomerID, p.FirstName, p.LastName)
SELECT 
    CustomerName, 
    AverageOrderValue
FROM 
    CustomerOrderCount
WHERE 
    OrderCount >= 5;

--12. Calculate total sales amount for each year from Sales.SalesOrderHeader table
WITH YearlySales AS (
    SELECT 
        YEAR(OrderDate) AS SalesYear,
        SUM(TotalDue) AS TotalSales
    FROM 
        Sales.SalesOrderHeader
    GROUP BY 
        YEAR(OrderDate))
SELECT 
    SalesYear, 
    TotalSales 
FROM 
    YearlySales
ORDER BY 
    SalesYear;

--13. Calculate the total sales for each product and return products with total sales greater than $10,000 
--using the Sales.SalesOrderDetail and Production.Product tables.
WITH ProductSales AS (
SELECT p.Name AS ProductName,
SUM(sod.LineTotal) AS TotalSales
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name)
SELECT ProductName, TotalSales
FROM ProductSales
WHERE TotalSales > 10000;

--14. Calculate the total sales amount for each product from Sales.SalesOrderHeader and Sales.SalesOrderDetail tables. 
--Display the product name alongside its total sales amount.
WITH TotalSales AS (
    SELECT 
        p.ProductID, 
        SUM(soh.TotalDue) AS TotalSales
    FROM 
        Sales.SalesOrderHeader AS soh
    JOIN 
        Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN 
        Production.Product AS p ON sod.ProductID = p.ProductID
    GROUP BY 
        p.ProductID)
SELECT 
    p.Name, 
    ts.TotalSales
FROM 
    TotalSales ts
JOIN 
    Production.Product AS p ON ts.ProductID = p.ProductID
ORDER BY 
    ts.TotalSales DESC;

--15. Arrange in decreasing order the month name from the startdate column that occurs the most (e.g January etc)
SELECT DATENAME(month, StartDate)  AS MONTH, COUNT(StartDate) Total_Occurence
FROM Production.BillOfMaterials
GROUP BY DATENAME(month, StartDate)
ORDER BY COUNT(StartDate) DESC;

