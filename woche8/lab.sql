--Generiere Löschbefehle
SELECT 'DROP INDEX '||index_name||';'
FROM user_indexes
MINUS
SELECT 'DROP INDEX '||constraint_name||';'
FROM user_constraints WHERE constraint_type IN ('P', 'U');

--Löschen alter Indexe
DROP INDEX ADR_CUST_ID;
DROP INDEX ADR_CTR_CODE;
DROP INDEX ADR_CITY;
DROP INDEX CUST_FN_LN;
DROP INDEX ADR_ZIP_CITY;
COMMIT;

--------------------------------------------------------------------------------
-- Query 1: Kundensuche nach Vor- und Nachname (2 Punkte)
--------------------------------------------------------------------------------
-- Erstellen von Index für first_name und last_name
CREATE INDEX CUST_FN_LN ON CUSTOMERS (FIRST_NAME, LAST_NAME);

EXPLAIN PLAN FOR
SELECT /*+ gather_plan_statistics */  a.cust_id, c.title, c.first_name, c.last_name, c.date_of_birth
     , a.zip_code, a.city, a.ctr_code, atp.label
  FROM customers c
  JOIN addresses a ON (a.cust_id = c.id)
  JOIN adr_types atp ON (atp.adr_type = a.adr_type)
  JOIN countries ctr ON (ctr.code = a.ctr_code)
 WHERE first_name = 'Susanne'
   AND last_name = 'Koenig'
ORDER BY a.cust_id, atp.label;




--------------------------------------------------------------------------------
-- Query 2: Kundensuche nach Nachname (2 Punkte)
--------------------------------------------------------------------------------
-- Der für Query 1 erstellte Index hat hier bereits einiges beschleunigt.

EXPLAIN PLAN FOR
SELECT a.cust_id, c.title, c.first_name, c.last_name
     , a.street, a.street_no, a.zip_code, a.city, a.ctr_code, atp.label
  FROM customers c
  JOIN addresses a ON (a.cust_id = c.id)
  JOIN adr_types atp ON (atp.adr_type = a.adr_type)
  JOIN countries ctr ON (ctr.code = a.ctr_code)
 WHERE last_name = 'Moneypenny'
ORDER BY a.cust_id, atp.label;




--------------------------------------------------------------------------------
-- Query 3: Englischsprachige Members, die am 2.3.20 bestellt haben (3 Punkte)
--------------------------------------------------------------------------------
-- Statt der Methode TO_CHAR sollte lieber die Methode TO_DATE verwendet werden.
-- todo hier sollte noch eventuell eine Partitionierung nach Datum vorgenommen werden
-- todo eventuell partitionierung nach language code? oder index?

EXPLAIN PLAN FOR
SELECT DISTINCT c.id, c.first_name, c.last_name
  FROM orders o
  JOIN customers c ON (c.id = o.cust_id)
 WHERE o.order_date = TO_DATE('02.03.2020', 'DD.MM.YYYY')
   AND c.member_flag = 'Y'
   AND c.language_code = 'en';




--------------------------------------------------------------------------------
-- Query 4: Welche Kunden wohnen in Windisch? (4 Punkte)
--------------------------------------------------------------------------------
-- index auf zipcode und city
CREATE INDEX ADR_ZIP_CITY ON ADDRESSES (ZIP_CODE, CITY);

EXPLAIN PLAN for
SELECT c.first_name, c.last_name, c.date_of_birth
  FROM customers c
  JOIN addresses a ON (a.cust_id = c.id)
 WHERE a.zip_code||' '||a.city = '5210 Windisch'
   AND a.adr_type = 'P';





SELECT *
FROM table (dbms_xplan.display);