-- MAXDOP
-- Max Degree of Parallelism
-- Parallelismus

-- Daumenregel:
-- nicht mehr CPUs als in einem NumaNode (bei mehreren NumaNodes)
-- nicht mehr als die Hälfte der CPUs bei 1NumaNode
-- Kostenschwellwert setzen (cost threshold)



SET STATISTICS IO, TIME ON

SELECT OrderID, CustomerID, CompanyName, Freight, OrderDate, EmployeeID, FirstName, LastName
FROM KU1
WHERE YEAR(OrderDate) = 1997 AND CompanyName LIKE 'A%'
ORDER BY OrderID

-- ~821ms



CREATE NONCLUSTERED INDEX NIX_CompName_incl
ON [dbo].[KU1] ([CompanyName])
INCLUDE ([CustomerID],[OrderID],[OrderDate],[Freight],[EmployeeID],[LastName],[FirstName])



SELECT OrderID, CustomerID, CompanyName, Freight, OrderDate, EmployeeID, FirstName, LastName
FROM KU1
WHERE YEAR(OrderDate) = 1997 AND CompanyName LIKE 'A%'
ORDER BY OrderID
OPTION (MAXDOP 2)
-- ~536ms






