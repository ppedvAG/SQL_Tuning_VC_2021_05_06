-- Partitionierung


-- partitioned View (partitionierte Sicht)


-- Testtabellen erstellen:
CREATE TABLE Orders (
						OrderID int NOT NULL,
						CountryCode char(3) NOT NULL,
						OrderDate date NULL,
						OrderYear int NOT NULL,
						CONSTRAINT PK_Orders PRIMARY KEY (OrderID, OrderYear)
					)



CREATE TABLE Orders_2020 (
						OrderID int NOT NULL,
						CountryCode char(3) NOT NULL,
						OrderDate date NULL,
						OrderYear int NOT NULL,
						CONSTRAINT PK_Orders_2020 PRIMARY KEY (OrderID, OrderYear)
					)



CREATE TABLE Orders_2019 (
						OrderID int NOT NULL,
						CountryCode char(3) NOT NULL,
						OrderDate date NULL,
						OrderYear int NOT NULL,
						CONSTRAINT PK_Orders_2019 PRIMARY KEY (OrderID, OrderYear)
					)



-- Testdaten einfügen:

-- in Orders:

INSERT INTO Orders(OrderID, CountryCode, OrderDate, OrderYear)
VALUES (202101, 'AUT', '2021-04-01', 2021),
		(202102, 'AUT', '2021-05-01', 2021)



-- in Orders_2020:

INSERT INTO Orders_2020(OrderID, CountryCode, OrderDate, OrderYear)
VALUES (202001, 'AUT', '2020-04-01', 2020),
		(202002, 'AUT', '2020-05-01', 2020)




-- in Orders_2019:

INSERT INTO Orders_2019(OrderID, CountryCode, OrderDate, OrderYear)
VALUES (201901, 'AUT', '2019-04-01', 2019),
		(201902, 'AUT', '2019-05-01', 2019)



SELECT *
FROM Orders
SELECT *
FROM Orders_2020
SELECT *
FROM Orders_2019




-- VIEW erstellen, die alle 3 Tabellen abfragt

CREATE VIEW v_OrdersTest
AS
SELECT OrderID, CountryCode, OrderDate, OrderYear
FROM Orders
UNION ALL
SELECT OrderID, CountryCode, OrderDate, OrderYear
FROM Orders_2020
UNION ALL
SELECT OrderID, CountryCode, OrderDate, OrderYear
FROM Orders_2019
GO


-- hier müssen alle drei Tabellen abgesucht werden!
SELECT *
FROM v_OrdersTest
WHERE OrderYear = 2019

SELECT *
FROM v_OrdersTest

-- das sieht so aus, als wäre es schneller, weil nur eine Tabelle untersucht wird
SELECT *
FROM Orders_2019




--> Lösung: Check CONSTRAINT

ALTER TABLE Orders
ADD CONSTRAINT CK_Orders CHECK (OrderYear >= 2021)
GO

ALTER TABLE Orders_2020
ADD CONSTRAINT CK_Orders_2020 CHECK (OrderYear = 2020)
GO

ALTER TABLE Orders_2019
ADD CONSTRAINT CK_Orders_2019 CHECK (OrderYear = 2019)
GO



-- wieder mit Execution-Plan ansehen:
SELECT *
FROM Orders_2019


SELECT *
FROM v_OrdersTest
WHERE OrderYear = 2019
-- wir müssen mit der VIEW nun nur noch 1 Tabelle anschauen, nicht mehr alle 3




INSERT INTO v_OrdersTest (OrderID, CountryCode, OrderDate, OrderYear)
VALUES (202103, 'GER', GETDATE(), 2021)


INSERT INTO v_OrdersTest (OrderID, CountryCode, OrderDate, OrderYear)
VALUES (202003, 'GER', '2020-05-06', 2020)


INSERT INTO v_OrdersTest (OrderID, CountryCode, OrderDate, OrderYear)
VALUES (201903, 'GER', '2019-05-06', 2019)



SELECT *
FROM Orders


SELECT *
FROM Orders_2020


SELECT *
FROM Orders_2019


SELECT *
FROM v_OrdersTest
WHERE OrderYear = 2019





-- Nachteile partitioned view:
-- nächstes Jahr müssen wir eine neue Tabelle anlegen
-- alles anpassen
-- View umschreiben! (neue Tabelle abfragen)




-- ************************************************************************************************************
--  ********************************************** Partition **************************************************



-- welche Filegroups gibts denn?

SELECT Name FROM sys.filegroups
-- PRIMARY


-- Partitionierung funktioniert auch ohne zusätzliche filegroups (Dateigruppen)
-- aber Wahrscheinlichkeit ist hoch, dass wir welche erstellen werden


-- > Filegroups erstellen



-- Daten einteilen


------------------------ 1000] --------------------------- 5000] ------------------------------
--          1                               2                                3

--    bis1000                           bis5000                             Rest




-- welche Filegroups gibts denn?

SELECT Name FROM sys.filegroups



-- Partition Function und Partition Schema erstellen


-- Partition Function:

CREATE PARTITION FUNCTION f_zahl(int)
AS
RANGE LEFT FOR VALUES(1000, 5000)  -- RANGE RIGHT gibts auch - die Werte rechts vom Grenzwert sollen in eine Partition


-- Test: abfragen, in welcher Partition Nr. der Wert liegen würde:

SELECT $partition.f_zahl(117) -- 1
SELECT $partition.f_zahl(1000) -- 1
SELECT $partition.f_zahl(1001) -- 2
SELECT $partition.f_zahl(5000) -- 2
SELECT $partition.f_zahl(5001) -- 3




-- Partitionsschema (partition scheme)

CREATE PARTITION SCHEME sch_zahl
AS
PARTITION f_zahl TO(bis1000, bis5000, Rest)  -- Reihenfolge wichtig



-- Tabelle erstellen
-- Struktur genau einhalten (muss gleichen Spalten haben, wie die Tabelle, deren Daten wir hier einfügen wollen)
-- ID darf KEIN Identity verwenden (sonst ist die Spalte als einzige schon befüllt)
-- Partitions-Schema zuweisen ("ON sch_zahl")

CREATE TABLE [dbo].[PartitionTest](
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Country] [nvarchar](15) NULL,
	[Phone] [nvarchar](24) NULL,
	[OrderID] [int] NOT NULL,
	[OrderDate] [datetime] NULL,
	[ShipVia] [int] NULL,
	[ShippedDate] [datetime] NULL,
	[Freight] [money] NULL,
	[EmployeeID] [int] NOT NULL,
	[LastName] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](10) NOT NULL,
	[Title] [nvarchar](30) NULL,
	[BirthDate] [datetime] NULL,
	[HireDate] [datetime] NULL,
	[Expr1] [nvarchar](60) NULL,
	[Expr2] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Expr3] [nvarchar](15) NULL,
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](40) NOT NULL,
	[SupplierID] [int] NULL,
	[CategoryID] [int] NULL,
	[UnitPrice] [money] NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [real] NOT NULL,
	[ShipperID] [int] NOT NULL,
	[Expr4] [nvarchar](40) NOT NULL,
	[Expr5] [int] NOT NULL,
	[Expr6] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Expr7] [nvarchar](24) NULL,
	[ID] [int] NOT NULL
) ON sch_zahl(ID)
GO


INSERT INTO PartitionTest
SELECT * FROM KU1


-- FileName, Daten in MB, Filegroupname ausgeben:
SELECT	  sdf.name AS [FileName]
		, size*8/1024 AS [Size_in_MB]
		, fg.name AS [File_Group_Name]
FROM sys.database_files sdf INNER JOIN sys.filegroups fg ON sdf.data_space_id=fg.data_space_id



-- von wo bis wo sind die Daten auf welche Partition verteilt (in unserem Fall von welcher ID bis zu welcher ID)
SELECT    $partition.f_zahl(id) AS [Partition]
		, MIN(id) AS von
		, MAX(id) AS bis
		, COUNT(*) AS Anzahl
FROM PartitionTest
GROUP BY $partition.f_zahl(Id)



SET STATISTICS IO, TIME ON


SELECT *
FROM KU1
WHERE ID = 117
-- logical reads 90590 = wie viele pages mussten gelesen werden
-- elapsed time = 747 ms = Gesamtdauer



SELECT *
FROM PartitionTest
WHERE ID = 117
-- logical reads 77


SELECT *
FROM PartitionTest
WHERE ID = 2345
-- logical reads 308



SELECT *
FROM PartitionTest
WHERE ID = 100000
-- logical reads 84338



-- welche Filegroups gibts denn?

SELECT Name FROM sys.filegroups



--> für neue Grenze: neue filegroup (Dateigruppe) erstellen

-- neue Grenze bei 16000 eingeben

-- Partition scheme ändern!



ALTER PARTITION SCHEME sch_zahl NEXT USED bis16000



-- von wo bis wo sind die Daten auf welche Partition verteilt (in unserem Fall von welcher ID bis zu welcher ID)
SELECT    $partition.f_zahl(id) AS [Partition]
		, MIN(id) AS von
		, MAX(id) AS bis
		, COUNT(*) AS Anzahl
FROM PartitionTest
GROUP BY $partition.f_zahl(Id)

-- bis jetzt hat sich noch nichts verändert, wir haben immer noch 3 Partitionen in Verwendung...



--> neue Grenze setzen mit partition function


------------------ 1000] --------------- 5000] ------------------------ 16000] -------------------------------
--        1                      2                        3                                4


-- Daten verteilen mit partition function:

ALTER PARTITION FUNCTION f_zahl() SPLIT RANGE (16000)



-- von wo bis wo sind die Daten auf welche Partition verteilt (in unserem Fall von welcher ID bis zu welcher ID)
SELECT    $partition.f_zahl(id) AS [Partition]
		, MIN(id) AS von
		, MAX(id) AS bis
		, COUNT(*) AS Anzahl
FROM PartitionTest
GROUP BY $partition.f_zahl(Id)




-- Test: abfragen, in welcher Partition Nr. der Wert liegen würde:

SELECT $partition.f_zahl(117) -- 1
SELECT $partition.f_zahl(1000) -- 1
SELECT $partition.f_zahl(1001) -- 2
SELECT $partition.f_zahl(5000) -- 2
SELECT $partition.f_zahl(5001) -- 3
SELECT $partition.f_zahl(16000) -- 3
SELECT $partition.f_zahl(16001) -- 4





-- Grenze 1000 entfernen:


-- Dateigruppe freiräumen


---------- X1000X ------------------ 5000 ------------------- 16000 ----------------------------------------
--                      1                          2                                  3



-- dafür brauchen wir nur die Funktion anpassen!


ALTER PARTITION FUNCTION f_zahl() MERGE RANGE(1000)


-- wir müssen nur die Funktion umdefinieren - fertig!


-- von wo bis wo sind die Daten auf welche Partition verteilt (in unserem Fall von welcher ID bis zu welcher ID)
SELECT    $partition.f_zahl(id) AS [Partition]
		, MIN(id) AS von
		, MAX(id) AS bis
		, COUNT(*) AS Anzahl
FROM PartitionTest
GROUP BY $partition.f_zahl(Id)




-- FileName, Daten in MB, Filegroupname ausgeben:
SELECT	  sdf.name AS [FileName]
		, size*8/1024 AS [Size_in_MB]
		, fg.name AS [File_Group_Name]
FROM sys.database_files sdf INNER JOIN sys.filegroups fg ON sdf.data_space_id=fg.data_space_id



-- Analysen "ausborgen" und an eigene Bedürfnisse anpassen:
SELECT
    so.name as [Tabelle],
    stat.row_count AS [Rows],
    p.partition_number AS [Partition #],
    pf.name as [Partition Function],
    CASE pf.boundary_value_on_right
        WHEN 1 then 'Right / Lower'
        ELSE 'Left / Upper'
    END as [Boundary Type],
    prv.value as [Boundary Point],
    fg.name as [Filegroup]
FROM sys.partition_functions AS pf
JOIN sys.partition_schemes as ps on ps.function_id=pf.function_id
JOIN sys.indexes as si on si.data_space_id=ps.data_space_id
JOIN sys.objects as so on si.object_id = so.object_id
JOIN sys.schemas as sc on so.schema_id = sc.schema_id
JOIN sys.partitions as p on 
    si.object_id=p.object_id 
    and si.index_id=p.index_id
LEFT JOIN sys.partition_range_values as prv on prv.function_id=pf.function_id
    and p.partition_number= 
        CASE pf.boundary_value_on_right WHEN 1
            THEN prv.boundary_id + 1
        ELSE prv.boundary_id
        END
        /* For left-based functions, partition_number = boundary_id, 
           for right-based functions we need to add 1 */
JOIN sys.dm_db_partition_stats as stat on stat.object_id=p.object_id
    and stat.index_id=p.index_id
    and stat.index_id=p.index_id and stat.partition_id=p.partition_id
    and stat.partition_number=p.partition_number
JOIN sys.allocation_units as au on au.container_id = p.hobt_id
    and au.type_desc ='IN_ROW_DATA' 
        /* Avoiding double rows for columnstore indexes. */
        /* We can pick up LOB page count from partition_stats */
JOIN sys.filegroups as fg on fg.data_space_id = au.data_space_id
ORDER BY [Tabelle], [Partition Function], [Partition #];
GO




--> Archivdaten in eine Archivtabelle verschieben
--> Archivtabelle erstellen

--> wir müssen wieder weniger pages durchsuchen bei Abfrage


CREATE TABLE [dbo].[ArchivTest](
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Country] [nvarchar](15) NULL,
	[Phone] [nvarchar](24) NULL,
	[OrderID] [int] NOT NULL,
	[OrderDate] [datetime] NULL,
	[ShipVia] [int] NULL,
	[ShippedDate] [datetime] NULL,
	[Freight] [money] NULL,
	[EmployeeID] [int] NOT NULL,
	[LastName] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](10) NOT NULL,
	[Title] [nvarchar](30) NULL,
	[BirthDate] [datetime] NULL,
	[HireDate] [datetime] NULL,
	[Expr1] [nvarchar](60) NULL,
	[Expr2] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Expr3] [nvarchar](15) NULL,
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](40) NOT NULL,
	[SupplierID] [int] NULL,
	[CategoryID] [int] NULL,
	[UnitPrice] [money] NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [real] NOT NULL,
	[ShipperID] [int] NOT NULL,
	[Expr4] [nvarchar](40) NOT NULL,
	[Expr5] [int] NOT NULL,
	[Expr6] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Expr7] [nvarchar](24) NULL,
	[ID] [int] NOT NULL
) ON bis5000
GO

-- nicht Partitionsschema verwenden, sondern die Partition auswählen, auf der sich unsere Archivtabell befindet



ALTER TABLE PartitionTest SWITCH PARTITION 1 TO ArchivTest


SELECT *
FROM ArchivTest


SELECT *
FROM PartitionTest
WHERE ID = 1500





SELECT *
FROM ArchivTest
WHERE ID = 1500


INSERT INTO PartitionTest(id, CustomerID, CompanyName, OrderID, ProductID, EmployeeID, LastName, FirstName, ProductName, Quantity, Discount, ShipperID, Expr4, Expr1, Expr2, Expr3, Expr5, Expr6, Expr7)
VALUES(3, 3, 'Test', 3, 3, 3, 'Mustermann', 'Max', 'Test', 3, 0, 3, 3, 3, 3, 3, 3, 3, 3)



SELECT    $partition.f_zahl(id) AS [Partition]
		, MIN(id) AS von
		, MAX(id) AS bis
		, COUNT(*) AS Anzahl
FROM PartitionTest
GROUP BY $partition.f_zahl(Id)





-- Jahresweise aufteilen??


CREATE PARTITION FUNCTION f_year(datetime)
AS
RANGE LEFT FOR VALUES('2019-12-31 23:59:59.996')
-- Vorsicht - wo liegt die Grenze tatsächlich?
-- > Year-Spalte als int erstellen, wenn möglich



-- A---------------------------------M/N----------------------------------R/S--------------.....

-- Vorsicht bei Grenzen!


CREATE PARTITION FUNCTION f_alphabet(nvarchar(50))
AS
RANGE LEFT FOR VALUES('N', 'S')


-- MA ist größer als M und wäre nicht mehr in Partition 1, wenn wir M als Grenze angeben
-- M
-- MA > M
-- MZZZZZZZZZZZZZZZ 
--> Grenze bei N!








