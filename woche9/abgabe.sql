--------------------------------------------------------------------------------
-- Generiere Löschbefehle und Lösche alte Indizes
--------------------------------------------------------------------------------
SELECT 'DROP INDEX '||index_name||';'
FROM user_indexes
MINUS
SELECT 'DROP INDEX '||constraint_name||';'
FROM user_constraints WHERE constraint_type IN ('P', 'U');


-- select partition_name, TABLE_NAME
-- from USER_TAB_PARTITIONS;
-- -- where TABLE_NAME = 'PRODUCTS';
-- -- todo wie kann man die löschen?

--------------------------------------------------------------------------------
-- Query 1: Kundensuche nach Vor- und Nachname (2 Punkte)
--------------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT a.cust_id, c.title, c.first_name, c.last_name, c.date_of_birth
     , a.zip_code, a.city, a.ctr_code, atp.label
  FROM customers c
  JOIN addresses a ON (a.cust_id = c.id)
  JOIN adr_types atp ON (atp.adr_type = a.adr_type)
  JOIN countries ctr ON (ctr.code = a.ctr_code)
 WHERE first_name = 'Susanne'
   AND last_name = 'Koenig'
ORDER BY a.cust_id, atp.label;

-- Dauerte zu Beginn durchschnittlich zwischen 130ms und 190ms.
-- Dauert am Ende aller Verbesserungen zwischen  und

-- Hier macht es Sinn einen Index auf die Tabelle CUSTOMERS mit Vor- und Nachnamen zu machen.
-- Da es wahrscheinlich ist, dass es häufiger Suchen gibt mit dem Nachnamen, sollte hier die
-- Reihenfolge sein, dass der Nachname zu erst genannt wird.
CREATE INDEX CUST_LN_FN ON CUSTOMERS (LAST_NAME, FIRST_NAME);



--------------------------------------------------------------------------------
-- Query 2: Kundensuche nach Nachname (2 Punkte)
--------------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT a.cust_id, c.title, c.first_name, c.last_name
     , a.street, a.street_no, a.zip_code, a.city, a.ctr_code, atp.label
  FROM customers c
  JOIN addresses a ON (a.cust_id = c.id)
  JOIN adr_types atp ON (atp.adr_type = a.adr_type)
  JOIN countries ctr ON (ctr.code = a.ctr_code)
 WHERE last_name = 'Moneypenny'
ORDER BY a.cust_id, atp.label;

-- Dauerte zu Beginn durchschnittlich zwischen 130ms und 180ms
-- Dauert am Ende aller Verbesserungen zwischen  und

-- Hier wird bereits der Index aus Query 1 genutzt, welchen direkt so gemacht ist, dass der
-- Nachname als erstes kommt.



--------------------------------------------------------------------------------
-- Query 3: Englischsprachige Members, die am 2.3.20 bestellt haben (3 Punkte)
--------------------------------------------------------------------------------
-- todo: index auf language_code?
-- todo: index auf member-flag
SELECT DISTINCT c.id, c.first_name, c.last_name
  FROM orders o
  JOIN customers c ON (c.id = o.cust_id)
 WHERE TO_CHAR(o.order_date, 'dd.mm.yyyy') = '02.03.2020'
   AND c.member_flag = 'Y'
   AND c.language_code = 'en';

-- Dauerte zu Beginn durchschnittlich zwischen 800ms und 950ms
-- Dauert am Ende aller Verbesserungen zwischen  und

-- Hier macht es Sinn die Query anzupassen. Akuell wird auf jede Row die TO_CHAR aufgerufen.
-- Das ORDER_DATE ist aber ein date, also wäre es besser den String in ein DATE
-- umzuwandeln.
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

-- Und wird auch auf die Order_Items übertragen.
ALTER TABLE ORDER_ITEMS
    MODIFY PARTITION BY REFERENCE(ORDI_ORD_FK);



--------------------------------------------------------------------------------
-- Query 4: Welche Kunden wohnen in Windisch? (4 Punkte)
--------------------------------------------------------------------------------
SELECT c.first_name, c.last_name, c.date_of_birth
  FROM customers c
  JOIN addresses a ON (a.cust_id = c.id)
 WHERE a.zip_code||' '||a.city = '5210 Windisch'
   AND a.adr_type = 'P';

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

-- Dann sollte ein Index für den zip_code und die city erstellt werden, da diese wahrscheinlich
-- häufiger gesucht werden könnten.
CREATE INDEX ADR_ZI_CI ON ADDRESSES (ZIP_CODE, CITY);



--------------------------------------------------------------------------------
-- Query 5: Was hat James Bond fŸr Hardware gekauft? (4 Punkte)
--------------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT o.order_date, p.prod_name
  FROM orders o
  JOIN order_items i ON (i.order_id = o.id)
  JOIN customers c ON (c.id = o.cust_id)
  JOIN products p ON (p.id = i.prod_id)
 WHERE c.last_name = 'Bond'
   AND c.first_name = 'James'
   AND p.prod_category = 'Hardware';

-- Dauerte zu Beginn durchschnittlich zwischen 980ms und 1s 50ms
-- Dauert am Ende aller Verbesserungen zwischen  und

-- Es Könnte ein Index auf die Produktkategorie erstellt werden, jedoch verbessert die die
-- Performance nicht, weshalb es keinen Sinn hier macht.
CREATE INDEX PR_CT ON PRODUCTS(PROD_CATEGORY);
DROP INDEX PR_CT;



--------------------------------------------------------------------------------
-- Query 6: Schweizer Kunden, die 2023 nichts bestellt haben (5 Punkte)
--------------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT *
  FROM customers
 WHERE id IN (SELECT cust_id
                FROM addresses a
                JOIN countries ctr ON (ctr.code = a.ctr_code)
                JOIN adr_types atp ON (atp.adr_type = a.adr_type)
               WHERE ctr.name = 'Switzerland'
                 AND atp.label = 'Delivery address')
   AND id NOT IN (SELECT cust_id
                    FROM orders
                   WHERE order_date BETWEEN TO_DATE('01.01.2023', 'dd.mm.yyyy')
                                        AND TO_DATE('31.12.2023', 'dd.mm.yyyy'));

-- Dauerte zu Beginn durchschnittlich zwischen 180ms und 230ms
-- Dauert am Ende aller Verbesserungen zwischen  und

-- todo partition auf ctr.name? oder index?



--------------------------------------------------------------------------------
-- Query 7: Alle Bestellungen von Harry Potter seit Anfang Jahr (5 Punkte)
--------------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT c.first_name, c.last_name, o.order_date, i.delivery_date, p.prod_name, i.quantity
  FROM orders      o
  JOIN order_items i ON (i.order_id = o.id)
  JOIN products    p ON (p.id = i.prod_id)
  JOIN customers   c ON (c.id = o.cust_id)
  JOIN addresses   a ON (a.cust_id = c.id)
  JOIN adr_types   t ON (t.adr_type = a.adr_type)
 WHERE o.order_date >= TO_DATE('01.01.2023', 'dd.mm.yyyy')
   AND t.adr_type IN ('D', 'DP')
   AND c.first_name = 'Harry'
   AND c.last_name = 'Potter'
   AND a.city = 'Hogwarts'
ORDER BY o.order_date, p.prod_name;

-- Dauerte zu Beginn durchschnittlich zwischen 210ms und 310ms
-- Dauert am Ende aller Verbesserungen zwischen  und

-- Dies ist zum einen bereits durch die Partitionierung von Query 6 schneller geworden.
-- Jedoch wäre es hier sinnvoll einen Index auf die CITY zu machen. Dies wurde bereits in Query 4
-- gemacht. Jedoch so herum, dass erst der ZIP_CODE kommt. Deshalb muss der Index umgeschrieben
-- werden. Sonst wird dieser Index nicht genutzt.
DROP INDEX ADR_ZI_CI;
CREATE INDEX ADR_CI_ZI ON ADDRESSES (CITY, ZIP_CODE);
-- todo partition auf adr types? oder index
-- todo adr_type = 'D' or 'DP'


--------------------------------------------------------------------------------
-- Query 8: Gesamtumsatz pro Produktkategorie im ersten Quartal 2022 (5 Punkte)
--------------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT prod.prod_category
     , SUM(i.quantity * i.price_per_unit) total_revenue
  FROM orders      o
  JOIN order_items i ON (i.order_id = o.id)
  JOIN products prod ON (prod.id = i.prod_id)
   AND o.order_date BETWEEN TO_DATE('01.01.2022', 'dd.mm.yyyy')
                        AND TO_DATE('31.03.2022', 'dd.mm.yyyy')
GROUP BY prod.prod_category
ORDER BY total_revenue DESC;

-- Dauerte zu Beginn durchschnittlich zwischen 2s und 3s
-- Dauert am Ende aller Verbesserungen zwischen  und


-- Es Könnte ein Index auf die Produktkategorie erstellt werden, jedoch verbessert dies die
-- Performance nicht wirklich. Nur um 1 Punkt, weshalb es keinen Sinn hier macht.
CREATE INDEX PR_CT ON PRODUCTS(PROD_CATEGORY);
DROP INDEX PR_CT;
