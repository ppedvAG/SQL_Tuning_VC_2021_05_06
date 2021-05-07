

/*

	Hardware
	Blockierungen
	Indizes
	TSQL-Code; Ausf�hrungsreihenfolge
	Datenbank-Design!
	I/O Vorg�nge minimieren

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
		char(10)      Berg_ _ _ _ _ _ (mit Leerzeichen aufgef�llt)


		-- �nderung --> Bergmann

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
-- Kunde soll nicht weggel�scht werden, wenn wir eine Bestellung wegl�schen (oder umgekehrt)


-- SELECT *
-- FROM Customers c INNER JOIN Orders o ON c.CustomerID = o.CustomerID



-- aber: Normalformen k�nnen auch bewusst gebrochen werden, um Abfragen schneller zu machen (weil dann weniger Datens�tze angesehen werden m�ssen)


/*

		1 MIO Kunden .............. jeder im Durchschnitt 3 Bestellungen


		3 MIO Bestellungen ........ jeder 4 Rechnungsposten im Durchschnitt


		12 MIO Rechnungsposten (Order Details)




		1 .... JOIN   3 ..... JOIN 12  --> 16 MIO DS




		1 extra Spalte "Rechnungssumme" in Orders


		stattt 16 MIO DS nur noch 4!


*/





-- Ausf�hrungsreihenfolge

/*
	-- so schreiben wir die Abfrage:

	SELECT
	FROM
	WHERE
	GROUP BY
	HAVING
	ORDER BY




	-- in dieser Reihenfolge wird ausgef�hrt:

	FROM (JOIN)
	WHERE
	GROUP BY
	HAVING
	SELECT
	ORDER BY


	-- WHERE ist schneller als HAVING, weil die Datenmenge vor dem Gruppieren schon eingeschr�nkt wird


*/


SELECT AVG(Freight) AS Frachtkosten
		, CustomerID AS Kunde
FROM Orders
WHERE CustomerID LIKE 'A%'
GROUP BY CustomerID
ORDER BY Frachtkosten






-- Optimierer

-- erstellt Plan

-- wie soll die Abfrage ausgef�hrt werden?


-- Pl�ne

-- estimated (gesch�tzten) oder actual (tats�chlichen) execution plan (Ausf�hrungsplan)



-- trivialen Plan
-- wenn nur ein Plan m�glich ist
-- z.B. SELECT Spalte FROM Tabelle
-- der Plan kann nicht optimiert werden; es werden alle Eintr�ge dieser Spalte ausgegeben



-- anderes Beispiel
-- SELECT Spalte X FROM Tabelle WHERE Spalte Y IS NULL
-- wenn f�r Spalte Y mit CHECK CONSTRAINT NOT NULL deklariert wurde, dann muss hier keine �berpr�fung stattfinden
-- Optimierer wei� schon, dass da nirgends NULL drin stehen kann



-- Optimierer kann auch OUTER JOIN durch INNER JOIN ersetzen, wenn das g�nstiger ist
-- z.B. wenn in der WHERE-Bedingung etwas weggek�rzt wird, das erst durch den OUTER JOIN im Ergebnis aufscheinen w�rde



-- Optimierer stellt auch Kostenvergleich an
-- erster Plan, dessen Kosten < 0.2 wird ausgef�hrt
-- wenn Kosten h�her sind, wird weitergesucht; erster Plan, wo Kosten < 1 wird ausgef�hrt
-- Ende der Optimierung: wenn alle m�glichen Pl�ne untersucht wurden



















