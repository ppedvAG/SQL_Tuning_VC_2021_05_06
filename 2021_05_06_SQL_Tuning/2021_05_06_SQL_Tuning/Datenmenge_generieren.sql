



SELECT Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Customers.Address, Customers.City, Customers.Country, Customers.Phone, Orders.OrderID, Orders.OrderDate, Orders.ShipVia, Orders.ShippedDate, Orders.Freight, Employees.EmployeeID, 
             Employees.LastName, Employees.FirstName, Employees.Title, Employees.BirthDate, Employees.HireDate, Employees.Address AS Expr1, Employees.City AS Expr2, Employees.Region, Employees.PostalCode, Employees.Country AS Expr3, Products.ProductID, Products.ProductName, 
             Products.SupplierID, Products.CategoryID, Products.UnitPrice, [Order Details].Quantity, [Order Details].Discount, Shippers.ShipperID, Shippers.CompanyName AS Expr4, Suppliers.SupplierID AS Expr5, Suppliers.ContactName AS Expr6, Suppliers.ContactTitle, 
             Suppliers.Phone AS Expr7
INTO Test.dbo.KundenUmsatz
FROM   Northwind.dbo.Customers INNER JOIN
             Northwind.dbo.Orders ON Customers.CustomerID = Orders.CustomerID INNER JOIN
             Northwind.dbo.Employees ON Orders.EmployeeID = Employees.EmployeeID INNER JOIN
             Northwind.dbo.[Order Details] ON Orders.OrderID = [Order Details].OrderID INNER JOIN
             Northwind.dbo.Products ON [Order Details].ProductID = Products.ProductID INNER JOIN
             Northwind.dbo.Shippers ON Orders.ShipVia = Shippers.ShipperID INNER JOIN
             Northwind.dbo.Suppliers ON Products.SupplierID = Suppliers.SupplierID




INSERT INTO KundenUmsatz
SELECT * FROM KundenUmsatz
GO 9



DBCC showcontig('Kundenumsatz')
-- 84287 pages
-- 10538 extents


-- Zeilenanzahl pro Tabelle?
SELECT DISTINCT t.name AS TableName
		, p.rows AS Zeilenanzahl
FROM sys.tables t
		INNER JOIN
			sys.partitions p
					ON t.object_id = p.object_id





-- Info zu Tabellen:

EXEC sp_help 'KundenUmsatz'

SELECT *
INTO KU1
FROM KundenUmsatz



ALTER TABLE KU1
ADD ID int identity


DBCC showcontig('KU1')
-- 84811
-- 10603

