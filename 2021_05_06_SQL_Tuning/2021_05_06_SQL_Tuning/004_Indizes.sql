-- idexes
-- Indices, Indizes, (Indexe)


-- Datenbank speichert im HEAP



-- clustered Index (gruppierter Index)
	-- 1 pro Tabelle
	-- verantwortlich für die physische Speicherung der Daten auf dem Datenträger


-- non-clustered Index (nicht gruppierter Index)
	-- unique index (eindeutiger Index)
		--> Werte in der Spalte dürfen nur ein einziges Mal vorkommen
	-- multicolumn index (zusammengesetzter Index)
	-- index with included columns (Index mit eingeschlossenen Spalten)
	-- covering index (abdeckender Index)
	-- filtered index (gefilterter Index)
	-- hypothetischer Index/missing Index



-- COLUMNSTORE INDEX --> Big Data; Data Warehouse; Archivdaten (an denen sich nichts mehr ändert)
	-- CI wartet mit Update/Komprimierung, bis 1MIO Datensätze erreicht sind (oder bis 400000 am Stück hereinkommen)
	-- dadurch werden Abfragen immer langsamer, weil ausgelagerte Daten gefunden werden müssen
	


SET STATISTICS IO, TIME ON




SELECT ID
FROM KU1
WHERE ID = 1000
-- logical reads 90590

-- Table Scan = ALLE pages mussten gelesen werden




ALTER TABLE KU1
ADD CONSTRAINT PK_KU1 PRIMARY KEY (ID)



-- CREATE CLUSTERED INDEX IX_Test ON Tabelle (Spalte)


CREATE CLUSTERED INDEX PK_KU1 ON KU1 (ID)

SELECT ID
FROM KU1
WHERE ID = 1000
-- logical reads 3 -- statt vorher 90590
-- Clustered Index Seek!


-- ix gelöscht...
-- Execution Plan angesehen:
-- Index wird vorgeschlagen:


CREATE NONCLUSTERED INDEX NIX_KU1_ID
ON [dbo].[KU1] ([ID])




SELECT *
FROM KU1
WHERE Freight < 1  -- 50%
-- 22016 Zeilen gelesen

SELECT *
FROM KU1
WHERE Freight > 100 -- 50%
-- 317440 Zeilen gelesen


-- ein Batch (= alles, was wir auf einmal ausführen) "kostet" immer 100%
-- 100% wird verteilt auf alle Abfragen innerhalb des Batches und deren einzelne Aktionen





SELECT *
FROM KU1
WHERE Freight < 1  -- 94%

SELECT TOP 22016 *
FROM KU1
WHERE Freight > 100 -- 6%  --> wenn kein Index vorhanden ist, "gewinnt" der TOP-Befehl (ressourcensparender)


--> Vorschlag vom Optimizer:

CREATE NONCLUSTERED INDEX NIX_Freight_incl_all
ON [dbo].[KU1] ([Freight])
INCLUDE ([CustomerID],[CompanyName],[ContactName],[Address],[City],[Country],[Phone],[OrderID],[OrderDate],[ShipVia],[ShippedDate],[EmployeeID],[LastName],[FirstName],[Title],[BirthDate],[HireDate],[Expr1],[Expr2],[Region],[PostalCode],[Expr3],[ProductID],[ProductName],[SupplierID],[CategoryID],[UnitPrice],[Quantity],[Discount],[ShipperID],[Expr4],[Expr5],[Expr6],[ContactTitle],[Expr7],[ID])




SELECT *
FROM KU1
WHERE Freight < 1  -- 6%
-- 21426 Zeilen gelesen

SELECT *
FROM KU1
WHERE Freight > 100 -- 94%
-- 315469 Zeilen gelesen






SELECT *
FROM KU1
WHERE Freight < 1  -- 50%

SELECT TOP 21426 *
FROM KU1
WHERE Freight > 100 -- 50%  





SELECT Country, City
FROM KU1
WHERE Country = 'Germany' AND City = 'Berlin'


-- Vorschlag vom Optimizer:
-- NCL Index auf Country und City
-- in SELECT stehen nur Country und City!

CREATE NONCLUSTERED INDEX NIX_City_Country
ON [dbo].[KU1] ([City],[Country])




SELECT Country, City
FROM KU1
WHERE Country = 'Germany' AND City = 'Berlin'
-- logical reads 36
-- ~300ms




SELECT OrderId, CompanyName, Freight, Country, City
FROM KU1
WHERE Country = 'Germany' AND City = 'Berlin'
-- Execution Plan sagt: hier wurde ein Key Lookup gemacht 


-- Vorschlag vom Optimizer:
CREATE NONCLUSTERED INDEX NIX_Country_City_incl_ID_CompName_Freight
ON [dbo].[KU1] ([City],[Country])
INCLUDE ([CompanyName],[OrderID],[Freight])




SELECT OrderId, CompanyName, Freight, Country, City
FROM KU1
WHERE Country = 'Germany' AND City = 'Berlin'





-- indizierte Sicht (indexed View)

	-- muss deterministisch sein
		--> https://docs.microsoft.com/de-de/sql/relational-databases/user-defined-functions/deterministic-and-nondeterministic-functions?view=sql-server-ver15 (Microsoft-Dokumentation)

		--> darf bestimmte Datentypen nicht enthalten (z.B. KEIN text, image,...)
		--> darf bestimmte Aggregatfunktionen nicht verwenden (COUNT(), MIN(), MAX() )

		--> muss WITH SCHEMABINDING verwenden



CREATE TABLE Test03(id int, spalte varchar(30))


CREATE VIEW dbo.v_Test03
WITH SCHEMABINDING
AS
SELECT ID
FROM dbo.Test03


DROP TABLE Test03

-- Fehlermeldung:
-- Cannot DROP TABLE 'Test03' because it is being referenced by object 'v_Test03'.




ALTER VIEW dbo.v_Test03
AS
SELECT ID
FROM dbo.Test03



DROP TABLE Test03

--> wenn kein Schemabinding kann Tabelle gelöscht werden, obwohl es die View noch gibt




-- Informationen??

SELECT index_id, index_depth, index_level, page_count
FROM sys.dm_db_index_physical_stats(db_id(), object_id('KU1'), NULL, NULL, 'limited')




-- Indizes anschauen (welche wie oft und wann zuletzt verwendet)
select    iu.object_id
		, type_desc
		, name
		, iu.index_id
		, user_seeks
		, user_scans
		, last_user_scan
		, last_user_seek		
from sys.indexes si Inner join sys.dm_db_index_usage_stats iu on si.index_id = iu.index_id
where name like '%ix%'



