SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);

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

/* Lösung ist ein Index auf den Vor- und Nachnamen zu erstellen.
   Zwei einzelne Indizes sind meist teuer, weshalb das zusammen legen günstiger
   ist. Hier sollte das erste Attribut das sein, auf das am meisten eingeschränkt
   wird.
   Ausserdem sollte ein Foreing Key auf die cust_id gesetzt werden */
CREATE INDEX CUST_LN_FN ON CUSTOMERS (LAST_NAME, FIRST_NAME);
CREATE INDEX ADR_CUST_ID ON ADDRESSES (CUST_ID);


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

/* Indizes aus Aufgabe 1 */

--------------------------------------------------------------------------------
-- Query 3: Englischsprachige Members, die am 2.3.20 bestellt haben (3 Punkte)
--------------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT DISTINCT c.id, c.first_name, c.last_name
  FROM orders o
  JOIN customers c ON (c.id = o.cust_id)
 WHERE TO_CHAR(o.order_date, 'dd.mm.yyyy') = '02.03.2020'
   AND c.member_flag = 'Y'
   AND c.language_code = 'en';

/* 1. Entweder Index auf order_date oder partition auf order_date
   2. Umschreiben der WHERE CONDITION */


--------------------------------------------------------------------------------
-- Query 4: Welche Kunden wohnen in Windisch? (4 Punkte)
--------------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT c.first_name, c.last_name, c.date_of_birth
  FROM customers c
  JOIN addresses a ON (a.cust_id = c.id)
 WHERE a.zip_code||' '||a.city = '5210 Windisch'
   AND a.adr_type = 'P';

/* 1. Aufteilen der WHERE CONDITION in zwei seperate
   2. Index auf CITY; ZIP_CODE */

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

/* 1. Index mit Namen von Query 1 wird genutzt.
   2. KEY auf  ORDERS und ORDER_ITEMS*/
CREATE INDEX ord_cust_id on ORDERS(cust_id);
CREATE INDEX ord_items_id on ORDER_ITEMS(ORDER_ID);

/* Oder bestehenden unique key löschen/ändern */


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

/* 1. Index vom CUST_ID aus Query 5 wird genutzt.
   2. Index auf order date wird genutzt. Aber zusätzlich braucht es eine
      Partition. Aber nicht Tageweise sondern Monatsweise.
   3. Weiter braucht es die Partition auf die Order_items
   4.  */


--------------------------------------------------------------------------------
-- Query 7: Alle Bestellungen von Harry Potter seit Anfang Jahr (5 Punkte)
--------------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT c.first_name
     , c.last_name
     , o.order_date
     , i.delivery_date
     , p.prod_name
     , i.quantity
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

/*  */

/* Erstellen einer Hilfstabelle um den JOIN günstiger zu machen */