--------------------------------------------------------------------------------
-- Vorbereitung
--------------------------------------------------------------------------------
-- Generiere Löschbefehle
SELECT 'DROP INDEX ' || index_name || ';'
FROM user_indexes
MINUS
SELECT 'DROP INDEX ' || constraint_name || ';'
FROM user_constraints
WHERE constraint_type IN ('P', 'U');

-- Löschen alter Indizes
DROP INDEX ADR_CUST_ID;
DROP INDEX ADR_CTR_CODE;
DROP INDEX ADR_CITY;
DROP INDEX CUST_LN_FN;
DROP INDEX ADR_ZIP_CITY;


--------------------------------------------------------------------------------
-- Query 1: Kundensuche nach Vor- und Nachname (2 Punkte)
--------------------------------------------------------------------------------
SELECT a.cust_id, c.title, c.first_name, c.last_name, c.date_of_birth
     , a.zip_code, a.city, a.ctr_code, atp.label
  FROM customers c
  JOIN addresses a ON (a.cust_id = c.id)
  JOIN adr_types atp ON (atp.adr_type = a.adr_type)
  JOIN countries ctr ON (ctr.code = a.ctr_code)
 WHERE first_name = 'Susanne'
   AND last_name = 'Koenig'
ORDER BY a.cust_id, atp.label;

-- wieso mit neuer Tabelle so ganz anders?

-- Execution Plan vorher
-- -------------------------------------------------------------------------------------------
-- | Id  | Operation                     | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-- -------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT              |           |     1 |    81 |   119   (1)| 00:00:01 |
-- |   1 |  SORT ORDER BY                |           |     1 |    81 |   119   (1)| 00:00:01 |
-- |   2 |   NESTED LOOPS                |           |     1 |    81 |   118   (0)| 00:00:01 |
-- |   3 |    NESTED LOOPS               |           |     1 |    81 |   118   (0)| 00:00:01 |
-- |*  4 |     HASH JOIN                 |           |     1 |    62 |   117   (0)| 00:00:01 |
-- |*  5 |      TABLE ACCESS FULL        | CUSTOMERS |     1 |    34 |    56   (0)| 00:00:01 |
-- |   6 |      TABLE ACCESS FULL        | ADDRESSES | 23941 |   654K|    61   (0)| 00:00:01 |
-- |*  7 |     INDEX UNIQUE SCAN         | ATP_PK    |     1 |       |     0   (0)| 00:00:01 |
-- |   8 |    TABLE ACCESS BY INDEX ROWID| ADR_TYPES |     1 |    19 |     1   (0)| 00:00:01 |
-- -------------------------------------------------------------------------------------------
--
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--
--    4 - access("A"."CUST_ID"="C"."ID")
--    5 - filter("C"."LAST_NAME"='Koenig' AND "C"."FIRST_NAME"='Susanne')
--    7 - access("ATP"."ADR_TYPE"="A"."ADR_TYPE")

-------------------------------------------------------------------------------------------------
-- Für diese Query macht es Sinn einen Index auf customer mit vor und Nachnamen zu machen.
-- Der LAST_NAME kommt als erstes, weil es wahrscheinlich ist, dass es mehr Abfragen geben wird,
-- die nur nach dem Nachnamen suchen.
CREATE INDEX CUST_LN_FN ON CUSTOMERS (LAST_NAME, FIRST_NAME);
-------------------------------------------------------------------------------------------------

-- Aktualisierter Execution Plan
-- ------------------------------------------------------------------------------------------------------
-- | Id  | Operation                               | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
-- ------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                        |            |     1 |    81 |    65   (2)| 00:00:01 |
-- |   1 |  SORT ORDER BY                          |            |     1 |    81 |    65   (2)| 00:00:01 |
-- |   2 |   NESTED LOOPS                          |            |     1 |    81 |    64   (0)| 00:00:01 |
-- |   3 |    NESTED LOOPS                         |            |     1 |    81 |    64   (0)| 00:00:01 |
-- |*  4 |     HASH JOIN                           |            |     1 |    62 |    63   (0)| 00:00:01 |
-- |   5 |      TABLE ACCESS BY INDEX ROWID BATCHED| CUSTOMERS  |     1 |    34 |     2   (0)| 00:00:01 |
-- |*  6 |       INDEX RANGE SCAN                  | CUST_LN_FN |     1 |       |     1   (0)| 00:00:01 |
-- |   7 |      TABLE ACCESS FULL                  | ADDRESSES  | 23941 |   654K|    61   (0)| 00:00:01 |
-- |*  8 |     INDEX UNIQUE SCAN                   | ATP_PK     |     1 |       |     0   (0)| 00:00:01 |
-- |   9 |    TABLE ACCESS BY INDEX ROWID          | ADR_TYPES  |     1 |    19 |     1   (0)| 00:00:01 |
-- ------------------------------------------------------------------------------------------------------
--
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--
--    4 - access("A"."CUST_ID"="C"."ID")"
--    6 - access("C"."LAST_NAME"='Koenig' AND "C"."FIRST_NAME"='Susanne')"
--    8 - access("ATP"."ADR_TYPE"="A"."ADR_TYPE")"


--------------------------------------------------------------------------------
-- Query 2: Kundensuche nach Nachname (2 Punkte)
--------------------------------------------------------------------------------
SELECT a.cust_id
     , c.title
     , c.first_name
     , c.last_name
     , a.street
     , a.street_no
     , a.zip_code
     , a.city
     , a.ctr_code
     , atp.label
FROM customers c
         JOIN addresses a ON (a.cust_id = c.id)
         JOIN adr_types atp ON (atp.adr_type = a.adr_type)
         JOIN countries ctr ON (ctr.code = a.ctr_code)
WHERE last_name = 'Moneypenny'
ORDER BY a.cust_id, atp.label;

-- Execution Plan vorher
-- ----------------------------------------------------------------------------------
-- | Id  | Operation            | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT     |           |    10 |  1000 |   121   (1)| 00:00:01 |
-- |   1 |  SORT ORDER BY       |           |    10 |  1000 |   121   (1)| 00:00:01 |
-- |*  2 |   HASH JOIN          |           |    10 |  1000 |   120   (0)| 00:00:01 |
-- |*  3 |    HASH JOIN         |           |    10 |   810 |   117   (0)| 00:00:01 |
-- |*  4 |     TABLE ACCESS FULL| CUSTOMERS |     7 |   182 |    56   (0)| 00:00:01 |
-- |   5 |     TABLE ACCESS FULL| ADDRESSES | 23941 |  1285K|    61   (0)| 00:00:01 |
-- |   6 |    TABLE ACCESS FULL | ADR_TYPES |     3 |    57 |     3   (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
--
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--
--    2 - access("ATP"."ADR_TYPE"="A"."ADR_TYPE")"
--    3 - access("A"."CUST_ID"="C"."ID")"
--    4 - filter("C"."LAST_NAME"='Moneypenny')"


-------------------------------------------------------------------------------------------------
-- Durch den Index von Query 1 und dass der LAST_NAME als erstes genannt wird, wurde diese Query
-- bereits schneller.
-------------------------------------------------------------------------------------------------

-- Aktualisierter Execution Plan
-- -----------------------------------------------------------------------------------------------------
-- | Id  | Operation                              | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
-- -----------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT                       |            |    10 |  1000 |    74   (2)| 00:00:01 |
-- |   1 |  SORT ORDER BY                         |            |    10 |  1000 |    74   (2)| 00:00:01 |
-- |*  2 |   HASH JOIN                            |            |    10 |  1000 |    73   (0)| 00:00:01 |
-- |*  3 |    HASH JOIN                           |            |    10 |   810 |    70   (0)| 00:00:01 |
-- |   4 |     TABLE ACCESS BY INDEX ROWID BATCHED| CUSTOMERS  |     7 |   182 |     9   (0)| 00:00:01 |
-- |*  5 |      INDEX RANGE SCAN                  | CUST_LN_FN |     7 |       |     2   (0)| 00:00:01 |
-- |   6 |     TABLE ACCESS FULL                  | ADDRESSES  | 23941 |  1285K|    61   (0)| 00:00:01 |
-- |   7 |    TABLE ACCESS FULL                   | ADR_TYPES  |     3 |    57 |     3   (0)| 00:00:01 |
-- -----------------------------------------------------------------------------------------------------
--
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--
--    2 - access("ATP"."ADR_TYPE"="A"."ADR_TYPE")"
--    3 - access("A"."CUST_ID"="C"."ID")"
--    5 - access("C"."LAST_NAME"='Moneypenny')"


--------------------------------------------------------------------------------
-- Query 3: Englischsprachige Members, die am 2.3.20 bestellt haben (3 Punkte)
--------------------------------------------------------------------------------
SELECT DISTINCT c.id, c.first_name, c.last_name
FROM orders o
         JOIN customers c ON (c.id = o.cust_id)
WHERE TO_CHAR(o.order_date, 'dd.mm.yyyy') = '02.03.2020'
  AND c.member_flag = 'Y'
  AND c.language_code = 'en';

-- Execution Plan vorher
-- ----------------------------------------------------------------------------------
-- | Id  | Operation            | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT     |           |  2447 | 95433 |   1796  (3)| 00:00:01 |
-- |   1 |  SORT ORDER BY       |           |  2447 | 95433 |   1796  (3)| 00:00:01 |
-- |*  2 |   HASH JOIN          |           |  2447 | 95433 |   1796  (3)| 00:00:01 |
-- |*  3 |    HASH JOIN         |           |  2447 | 63622 |     56  (0)| 00:00:01 |
-- |*  4 |     TABLE ACCESS FULL| CUSTOMERS | 19465 |   247K|   1738  (3)| 00:00:01 |
-- ----------------------------------------------------------------------------------
--
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--
--    2 - access("C"."ID"="O"."CUST_ID")"
--    3 - filter("C"."MEMBER_FLAG"='Y' AND "C"."LANGUAGE_CODE"='en')
--    4 - filter(TO_CHAR(INTERNAL_FUNCTION("O"."ORDER_DATE"),'dd.mm.yyyy')='
--                02.03.2020')


-------------------------------------------------------------------------------------------------
-- Hier macht es Sinn zuerst einmal die Query anzupassen. Akuell wird auf jede Row die TO_CHAR
-- aufgerufen. Das ORDER_DATE ist aber ein date, also wäre es besser den String in ein DATE
-- umzuwandeln.
SELECT DISTINCT c.id, c.first_name, c.last_name
FROM orders o
         JOIN customers c ON (c.id = o.cust_id)
WHERE o.order_date = TO_DATE('02.03.2020', 'dd.mm.yyyy')
  AND c.member_flag = 'Y'
  AND c.language_code = 'en';
-------------------------------------------------------------------------------------------------

-- Aktualisierter Execution Plan
-- ----------------------------------------------------------------------------------
-- | Id  | Operation            | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-- ----------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT     |           |  1775 | 69225 |   1796  (1)| 00:00:01 |
-- |   1 |  HASH UNIQUE         |           |  1775 | 69225 |   1796  (1)| 00:00:01 |
-- |*  2 |   HASH JOIN          |           |  1775 | 69225 |   1796  (1)| 00:00:01 |
-- |*  3 |    TABLE ACCESS FULL | ORDERS    |  1775 | 23088 |   1711  (1)| 00:00:01 |
-- |*  4 |     TABLE ACCESS FULL| CUSTOMERS |  2447 | 63622 |     56  (0)| 00:00:01 |
-- ----------------------------------------------------------------------------------
--
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--
--    2 - access("C"."ID"="O"."CUST_ID")"
--
--    3 - filter("C"."MEMBER_FLAG"='Y' AND "C"."LANGUAGE_CODE"='en')
--    4 - filter(TO_CHAR(INTERNAL_FUNCTION("O"."ORDER_DATE"),'dd.mm.yyyy')='
--                02.03.2020')


-------------------------------------------------------------------------------------------------
-- Ausserdem könnte hier direkt auch die ORDERS Tabelle nach Datum partitioniert werden.
-- Ich nutze hier die Partitionierung nach Jahr. Es wären natürlich auch kleinere Partitionen
-- wie z.B. nach Monat möglich
-- todo: kann nicht alle partitionen löschen
ALTER TABLE ORDERS
    MODIFY PARTITION BY RANGE (order_date)
        INTERVAL (NUMTOYMINTERVAL(1, 'YEAR'))
        (PARTITION orders_init VALUES LESS THAN (DATE'1950-01-01'));

ALTER TABLE ORDERS
    MODIFY PARTITION BY RANGE (order_date)
        INTERVAL (NUMTODSINTERVAL(1, 'DAY'))
        (PARTITION orders_init VALUES LESS THAN (DATE'2022-01-01'));
-------------------------------------------------------------------------------------------------

-- Aktualisierter Execution Plan
-- ------------------------------------------------------------------------------------------------------
-- | Id  | Operation                | Name      | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
-- ------------------------------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT         |           |   584 | 22776 |   527   (1)| 00:00:01 |       |       |
-- |   1 |  HASH UNIQUE             |           |   584 | 22776 |   527   (1)| 00:00:01 |       |       |
-- |*  2 |   HASH JOIN              |           |   584 | 22776 |   526   (1)| 00:00:01 |       |       |
-- |   3 |    PARTITION RANGE SINGLE|           |   584 |  7592 |   470   (1)| 00:00:01 |    72 |    72 |
-- |*  4 |     TABLE ACCESS FULL    | ORDERS    |   584 |  7592 |   470   (1)| 00:00:01 |    72 |    72 |
-- |*  5 |    TABLE ACCESS FULL     | CUSTOMERS |  2447 | 63622 |    56   (0)| 00:00:01 |       |       |
-- ------------------------------------------------------------------------------------------------------
--
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--
--    2 - access(""C"".""ID""=""O"".""CUST_ID"")
--    4 - filter(""O"".""ORDER_DATE""=TO_DATE(' 2020-03-02 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))
--    5 - filter(""C"".""MEMBER_FLAG""='Y' AND ""C"".""LANGUAGE_CODE""='en')


-------------------------------------------------------------------------------------------------
-- todo hat aber gar keine auswirkung?
ALTER TABLE ORDER_ITEMS
    MODIFY PARTITION BY REFERENCE(ORDI_ORD_FK);
-------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------
-- Query 4: Welche Kunden wohnen in Windisch? (4 Punkte)
--------------------------------------------------------------------------------
SELECT c.first_name, c.last_name, c.date_of_birth
FROM customers c
         JOIN addresses a ON (a.cust_id = c.id)
WHERE a.zip_code || ' ' || a.city = '5210 Windisch'
  AND a.adr_type = 'P';


-- Execution Plan vorher
-- --------------------------------------------------------------------------------
-- | Id  | Operation          | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-- --------------------------------------------------------------------------------
-- |   0 | SELECT STATEMENT   |           |    81 |  4374 |   118   (1)| 00:00:01 |
-- |*  1 |  HASH JOIN         |           |    81 |  4374 |   118   (1)| 00:00:01 |
-- |*  2 |   TABLE ACCESS FULL| ADDRESSES |    81 |  2025 |    61   (0)| 00:00:01 |
-- |   3 |   TABLE ACCESS FULL| CUSTOMERS | 16332 |   462K|    56   (0)| 00:00:01 |
-- --------------------------------------------------------------------------------
--
-- Predicate Information (identified by operation id):
-- ---------------------------------------------------
--
--    1 - access("A"."CUST_ID"="C"."ID")"
--    2 - filter("A"."ADR_TYPE"='P' AND "A"."ZIP_CODE"||' "
--               '||"A"."CITY"='5210 Windisch')"


--------------------------------------------------------------------------------
-- Query 5: Was hat James Bond fŸr Hardware gekauft? (4 Punkte)
--------------------------------------------------------------------------------
SELECT o.order_date, p.prod_name
FROM orders o
         JOIN order_items i ON (i.order_id = o.id)
         JOIN customers c ON (c.id = o.cust_id)
         JOIN products p ON (p.id = i.prod_id)
WHERE c.last_name = 'Bond'
  AND c.first_name = 'James'
  AND p.prod_category = 'Hardware';


-- Execution Plan vorher

--------------------------------------------------------------------------------
-- Query 6: Schweizer Kunden, die 2023 nichts bestellt haben (5 Punkte)
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
-- Query 7: Alle Bestellungen von Harry Potter seit Anfang Jahr (5 Punkte)
--------------------------------------------------------------------------------
SELECT c.first_name
     , c.last_name
     , o.order_date
     , i.delivery_date
     , p.prod_name
     , i.quantity
FROM orders o
         JOIN order_items i ON (i.order_id = o.id)
         JOIN products p ON (p.id = i.prod_id)
         JOIN customers c ON (c.id = o.cust_id)
         JOIN addresses a ON (a.cust_id = c.id)
         JOIN adr_types t ON (t.adr_type = a.adr_type)
WHERE o.order_date >= TO_DATE('01.01.2023', 'dd.mm.yyyy')
  AND t.adr_type IN ('D', 'DP')
  AND c.first_name = 'Harry'
  AND c.last_name = 'Potter'
  AND a.city = 'Hogwarts'
ORDER BY o.order_date, p.prod_name;

--------------------------------------------------------------------------------
-- Query 8: Gesamtumsatz pro Produktkategorie im ersten Quartal 2022 (5 Punkte)
--------------------------------------------------------------------------------
SELECT prod.prod_category
     , SUM(i.quantity * i.price_per_unit) total_revenue
FROM orders o
         JOIN order_items i ON (i.order_id = o.id)
         JOIN products prod ON (prod.id = i.prod_id)
    AND o.order_date BETWEEN TO_DATE('01.01.2022', 'dd.mm.yyyy')
                                   AND TO_DATE('31.03.2022', 'dd.mm.yyyy')
GROUP BY prod.prod_category
ORDER BY total_revenue DESC;
