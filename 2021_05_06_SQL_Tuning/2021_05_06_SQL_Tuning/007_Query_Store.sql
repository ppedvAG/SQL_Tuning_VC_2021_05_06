-- Query Store

-- Kompatibilitätslevel überprüfen!

SELECT @@VERSION




SELECT *
INTO K4
FROM KundenUmsatz




dbcc showcontig('K4')
-- 84284


ALTER TABLE K4
ADD ID int identity



SET STATISTICS IO, TIME ON

SELECT *
FROM K4
WHERE ID = 100
-- 90578 logical reads



SELECT page_count, record_count, forwarded_record_count
FROM sys.dm_db_index_physical_stats(db_id(), object_id('K4'), NULL, NULL, 'detailed')


-- würden wir wollen, dass die ID nicht mehr ausgelagert wird, könnten wir die Daten mit einem clustered Index zusammenführen!



SELECT *
FROM K4
WHERE ID < 2
-- logical reads 90578
-- table scan




SELECT *
FROM K4
WHERE ID < 1000000
-- logical reads 90578
-- table scan


-- NIX auf id


SELECT *
FROM K4
WHERE ID < 2
-- logical reads 4
-- index seek



SELECT *
FROM K4
WHERE ID < 1000000
-- logical reads 90578
-- table scan


-- tipping point
SELECT *
FROM K4
WHERE ID < 16000
-- index seek


SELECT *
FROM K4
WHERE ID < 50000
-- table scan


-- Tipping Point für diese Abfrage liegt irgendwo zwischen 17000 und 50000; der Optimizer entscheidet hier: seek (mit Lookup) zahlt sich nicht mehr aus, hier wären wir mit scan schneller




CREATE PROC p_id @pid int
AS
SELECT *
FROM K4
WHERE ID < @pid
GO



EXEC p_id 300000
-- table scan


EXEC p_id 2
-- table scan!!!




DBCC freeproccache    -- Vorsicht: löscht alle!




EXEC p_id 2
-- seek (mit lookup)


EXEC p_id 300000
-- index seek (mit lookup!)



-- kommen mehr hohe oder mehr niedrige Werte vor?
-- in diesem Fall wäre der table scan sogar günstiger!
-- Tipping hilft bei der Entscheidung
-- brauchen keinen exakten Tipping Point
-- Tipping Point liegt häufig bei ca. 25%-30% (nicht zuverlässig! Richtwert!)


-- RML Utilities: Abfragen von mehreren Usern simulieren

	-- ostress
	-- -S.       .............Server
	-- -Q        .............Query
	-- -d        ............. Datenbank
	-- -n        ............. Anzahl User
	-- -r        ............. Anzahl Wiederholungen der Abfrage
	-- -q        ............. quiet (weniger Info)

-- ohne Abstände hinter den Buchstaben
















