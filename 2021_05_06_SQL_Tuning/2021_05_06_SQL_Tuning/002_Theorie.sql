

/*

	Hardware
	Blockierungen
	Indizes
	TSQL-Code; Ausführungsreihenfolge
	Datenbank-Design!
	I/O Vorgänge minimieren

*/




-- Planung

-- page

/*

	insgesamt 8192 Byte

	Page Header ...... 96 Byte

	Row Offset ....... 2 Byte pro Zeile
	Overhead ......... 7 Byte pro Zeile


	8 pages = 1 block (~64kb)


*/



CREATE DATABASE Test


CREATE TABLE Test0(Testtext char(4039))

INSERT INTO Test0(Testtext)
VALUES ('ABC'), ('DEF')



DBCC TRACEON(3604)

DBCC IND('Test', 'Test0', -1)

-- page ID? 
-- 264

DBCC PAGE('Test', 1, 264)


DBCC TRACEOFF(3604)



DBCC SHOWCONTIG('Test0')






-- Datentypen


/*

	-- String Datentypen

			char(50)
			varchar(50)


			-- UNICODE -> doppelt so viel Speicherplatz
			nchar
			nvarchar

	-- numerische Datentypen
			-- ganzzahlig
				
				bit       0, 1, NULL
				int
					tinyint, smallint, bigint

			-- mit Nachkommastellen
				decimal
				float
				money


	-- Datumsdatentypen

			datetime (auf ~ 3-4 ms genau) 8 byte
			datetime2 ( ~ 100 ns genau)

			date 3 byte
			time


			boolean, bool  true, false


*/



/*

		varchar(10)   Berg         _ _ _ _ _ _  (restliche ungenutzte Zeichen werden nicht verwendet)
		char(10)      Berg_ _ _ _ _ _ (mit Leerzeichen aufgefüllt)


		-- Änderung --> Bergmann

		varchar(10)  BergXXXX    ---> Information wird ausgelagert --->    mann
		char(10)     Bergmann_ _  Name geht sich auf derselben page aus




*/


SELECT Country, LEN(Country) AS [Len], DATALENGTH(Country) AS [Datalength]
FROM Customers



SELECT CustomerID, LEN(CustomerID) AS [Len], DATALENGTH(CustomerID) AS [Datalength]
FROM Customers





SELECT HireDate
FROM Employees






-- Normalformen


-- Redundanz vermeiden
-- sollen Inkonsistenzen vermeiden
-- Kunde soll nicht weggelöscht werden, wenn wir eine Bestellung weglöschen (oder umgekehrt)


-- SELECT *
-- FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID



-- aber: Normalformen können auch bewusst gebrochen werden, um Abfragen schneller zu machen (weil dann weniger Datensätze angesehen werden müssen)


/*

		1 MIO Kunden .............. jeder im Durchschnitt 3 Bestellungen


		3 MIO Bestellungen ........ jeder 4 Rechnungsposten im Durchschnitt


		12 MIO Rechnungsposten (Order Details)




		1 .... JOIN   3 ..... JOIN 12  --> 16 MIO DS




		1 extra Spalte "Rechnungssumme" in Orders


		stattt 16 MIO DS nur noch 4!


*/





-- Ausführungsreihenfolge

/*
	-- so schreiben wir die Abfrage:

	SELECT
	FROM
	WHERE
	GROUP BY
	HAVING
	ORDER BY




	-- in dieser Reihenfolge wird ausgeführt:

	FROM (JOIN)
	WHERE
	GROUP BY
	HAVING
	SELECT
	ORDER BY


	-- WHERE ist schneller als HAVING, weil die Datenmenge vor dem Gruppieren schon eingeschränkt wird


*/


SELECT AVG(Freight) AS Frachtkosten
		, CustomerID AS Kunde
FROM Orders
WHERE CustomerID LIKE 'A%'
GROUP BY CustomerID
ORDER BY Frachtkosten






-- Optimierer

-- erstellt Plan

-- wie soll die Abfrage ausgeführt werden?


-- Pläne

-- estimated (geschätzten) oder actual (tatsächlichen) execution plan (Ausführungsplan)



-- trivialen Plan
-- wenn nur ein Plan möglich ist
-- z.B. SELECT Spalte FROM Tabelle
-- der Plan kann nicht optimiert werden; es werden alle Einträge dieser Spalte ausgegeben



-- anderes Beispiel
-- SELECT Spalte X FROM Tabelle WHERE Spalte Y IS NULL
-- wenn für Spalte Y mit CHECK CONSTRAINT NOT NULL deklariert wurde, dann muss hier keine Überprüfung stattfinden
-- Optimierer weiß schon, dass da nirgends NULL drin stehen kann



-- Optimierer kann auch OUTER JOIN durch INNER JOIN ersetzen, wenn das günstiger ist
-- z.B. wenn in der WHERE-Bedingung etwas weggekürzt wird, das erst durch den OUTER JOIN im Ergebnis aufscheinen würde



-- Optimierer stellt auch Kostenvergleich an
-- erster Plan, dessen Kosten < 0.2 wird ausgeführt
-- wenn Kosten höher sind, wird weitergesucht; erster Plan, wo Kosten < 1 wird ausgeführt
-- Ende der Optimierung: wenn alle möglichen Pläne untersucht wurden



















