--------------------------------------------------------------------------------
-- Query 1: Kundensuche nach Vor- und Nachname (2 Punkte)
--------------------------------------------------------------------------------
-- Dauerte zu Beginn durchschnittlich zwischen 130ms und 190ms.
-- Dauert am Ende aller Verbesserungen zwischen  und

-- Hier macht es Sinn einen Index auf die Tabelle CUSTOMERS mit Vor- und Nachnamen zu machen.
-- Für eine spätere Querey und weil es wahrscheinlicher ist, dass häufiger nach dem Nachnamen
-- gesucht wird, wird dieser als erstes genannt.
CREATE INDEX CUST_LN_FN ON CUSTOMERS (LAST_NAME, FIRST_NAME);

-- Ausserdem wird ein Index auf den Foreing Key für die id vom customer gesetzt um die Joins
-- effizienter zu machen.
CREATE INDEX ADR_CUST_ID ON ADDRESSES (CUST_ID);


--------------------------------------------------------------------------------
-- Query 2: Kundensuche nach Nachname (2 Punkte)
--------------------------------------------------------------------------------
-- Dauerte zu Beginn durchschnittlich zwischen 130ms und 180ms
-- Dauert am Ende aller Verbesserungen zwischen  und

-- Hier wird der Index aus Query 1 genutzt.


--------------------------------------------------------------------------------
-- Query 3: Englischsprachige Members, die am 2.3.20 bestellt haben (3 Punkte)
--------------------------------------------------------------------------------
-- Dauerte zu Beginn durchschnittlich zwischen 800ms und 950ms
-- Dauert am Ende aller Verbesserungen zwischen  und

-- Hier macht es Sinn die Query anzupassen. Akuell wird auf jede Row TO_CHAR aufgerufen.
-- Da ORDER_DATE ein DATE ist, wäre es besser den String in ein DATE umzuwandeln.
EXPLAIN PLAN FOR
SELECT DISTINCT c.id, c.first_name, c.last_name
  FROM orders o
  JOIN customers c ON (c.id = o.cust_id)
 WHERE o.order_date = TO_DATE('02.03.2020', 'dd.mm.yyyy')
  AND c.member_flag = 'Y'
  AND c.language_code = 'en';

-- Ausserdem ist eine Partitionierung auf das Datum der Bestellung sinnvoll.
-- Mittels dem Befehl
SELECT MIN( EXTRACT(YEAR FROM order_date)) as year FROM orders;
-- Wurde das erste Jahr, in welher eine Bestellung durchgeführt wurde, herausgesucht.

-- Die Partitionierung erfolgt auf den Tag des Datums.
ALTER TABLE ORDERS
    MODIFY PARTITION BY RANGE (order_date)
        INTERVAL (NUMTODSINTERVAL(1, 'DAY'))
        (PARTITION orders_init VALUES LESS THAN (DATE'2020-01-01'));

-- Und wird auch auf die Order_Items übertragen. Damit in dieser ebenfalls schneller
-- gesucht werden kann.
ALTER TABLE ORDER_ITEMS
    MODIFY PARTITION BY REFERENCE(ORDI_ORD_FK);


--------------------------------------------------------------------------------
-- Query 4: Welche Kunden wohnen in Windisch? (4 Punkte)
--------------------------------------------------------------------------------
-- Dauerte zu Beginn durchschnittlich zwischen 120ms und 150ms
-- Dauert am Ende aller Verbesserungen zwischen  und

-- Hier macht es Sinn die Query anzupassen, so dass einzeln nach zip_code und city gesucht wird.
-- Da die Verkettung hohe Kosten verursacht.
EXPLAIN PLAN FOR
SELECT c.first_name, c.last_name, c.date_of_birth
  FROM customers c
  JOIN addresses a ON (a.cust_id = c.id)
 WHERE a.zip_code = '5210'
   AND a.city = 'Windisch'
   AND a.adr_type = 'P';

-- Dann sollte ein Index für den zip_code und die city erstellt werden.
-- In einer späteren Query wird nur nach CITY gesucht, weshalb dieses Argument als erstes
-- kommt. Jedoch sollte geklärt werden, ob es andere Abfragen gibt, die nur nach dem
-- ZIP_CODE suchen.
CREATE INDEX ADR_CI_ZI ON ADDRESSES (CITY, ZIP_CODE);


--------------------------------------------------------------------------------
-- Query 5: Was hat James Bond fŸr Hardware gekauft? (4 Punkte)
--------------------------------------------------------------------------------
-- Dauerte zu Beginn durchschnittlich zwischen 980ms und 1s 50ms
-- Dauert am Ende aller Verbesserungen zwischen  und

-- Es Könnte ein Index auf die Produktkategorie erstellt werden, jedoch verbessert dies die
-- Performance nicht, weshalb es keinen Sinn macht und ein unnötiger Index wäre.


--------------------------------------------------------------------------------
-- Query 6: Schweizer Kunden, die 2023 nichts bestellt haben (5 Punkte)
--------------------------------------------------------------------------------
-- Dauerte zu Beginn durchschnittlich zwischen 180ms und 230ms
-- Dauert am Ende aller Verbesserungen zwischen  und

-- Bei der Abfrage nach dem Label wäre es besser nach atp.ADR_TYPE zu suchen, als nach label
-- weil dies schon der Primary Key ist.

EXPLAIN PLAN FOR
SELECT *
  FROM customers
 WHERE id IN (SELECT cust_id
                FROM addresses a
                JOIN countries ctr ON (ctr.code = a.ctr_code)
                JOIN adr_types atp ON (atp.adr_type = a.adr_type)
               WHERE ctr.name = 'Switzerland'
                 AND atp.ADR_TYPE = 'D')
   AND id NOT IN (SELECT cust_id
                    FROM orders
                   WHERE order_date BETWEEN TO_DATE('01.01.2023', 'dd.mm.yyyy')
                                        AND TO_DATE('31.12.2023', 'dd.mm.yyyy'));

-- Das gleiche gilt für den Country.Name und Country.Code. Jedoch hat diese Anpassung
-- zu einer verschlechterung der performance geführt.


--------------------------------------------------------------------------------
-- Query 7: Alle Bestellungen von Harry Potter seit Anfang Jahr (5 Punkte)
--------------------------------------------------------------------------------
-- Dauerte zu Beginn durchschnittlich zwischen 210ms und 310ms
-- Dauert am Ende aller Verbesserungen zwischen  und

-- Dies ist zum einen bereits durch die Partitionierung von Query 6 schneller geworden.
-- Und in Query 4 wurde ein Index erstellt, so dass der ZIP_CODE als erstes kommt.


--------------------------------------------------------------------------------
-- Query 8: Gesamtumsatz pro Produktkategorie im ersten Quartal 2022 (5 Punkte)
--------------------------------------------------------------------------------
-- Dauerte zu Beginn durchschnittlich zwischen 2s und 3s
-- Dauert am Ende aller Verbesserungen zwischen  und

-- Es Könnte ein Index auf die Produktkategorie erstellt werden, jedoch verbessert dies die
-- Performance nicht wirklich. Nur um 1 Punkt, weshalb es keinen Sinn hier macht.