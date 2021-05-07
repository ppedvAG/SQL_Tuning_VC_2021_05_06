-- Komprimierung (compression)


-- Zeilenkomprimierung (row compression)
		-- fixe Formate (char) : keine Leerzeichen mehr

-- Seitenkomprimierung (page compression)
		-- Zeilenkomprimierung
		-- Präfixkomprimierung (Verweise im page header)


-- komplette DB nicht komprimierbar, aber für:

		-- Benutzer-Tabellen (Heap, Clustered Index)
		-- Non-Clustered Indexes
		-- Indexed Views

		-- Komprimierung möglich für einzelne Partitionen (bei horizontaler Partitionierung)




-- Ziele:
	-- bessere Ausnutzung des Hauptspeichers
	-- Einsparung I/O Operationen
	-- Einsparung logischer Lesevorgänge, weil Daten in komprimierter Form in den Datencache übertragen werden



-- Nachteil:
	-- CPU-Zeit wird höher




SELECT *
INTO KU2
FROM KU1



-- auf wie vielen pages abgespeichert?
DBCC showcontig('KU2')
-- 84568


SET STATISTICS IO, TIME ON


DBCC dropcleanbuffers



SELECT count(*)*8/1024 AS 'Data Cache Size(MB)'
	, CASE database_id
		WHEN 32767 THEN 'RESOURCEDB'
		ELSE db_name(database_id)
		END AS 'DatabaseName'
FROM sys.dm_os_buffer_descriptors
GROUP BY db_name(database_id) ,database_id
ORDER BY 'Data Cache Size(MB)' DESC




SELECT OrderID, CustomerID, CompanyName, Freight, OrderDate, EmployeeID, FirstName, LastName
FROM KU2
WHERE YEAR(OrderDate) = 1997 AND CompanyName LIKE 'A%'
ORDER BY OrderID



SELECT count(*)*8/1024 AS 'Data Cache Size(MB)'
	, CASE database_id
		WHEN 32767 THEN 'RESOURCEDB'
		ELSE db_name(database_id)
		END AS 'DatabaseName'
FROM sys.dm_os_buffer_descriptors
GROUP BY db_name(database_id) ,database_id
ORDER BY 'Data Cache Size(MB)' DESC




--> page compression
-- auf wie vielen pages abgespeichert?
DBCC showcontig('KU2')

-- 5770  -- vor Komprimierung: -- 84568 




