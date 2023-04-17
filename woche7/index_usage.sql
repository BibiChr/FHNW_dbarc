--------------------------------------------------------------------------------
-- Query 1:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE id = 17140;

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- Index Unique scan, weil mit = und primary key gesucht wird.

--------------------------------------------------------------------------------
-- Query 2:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE cust_id = 456;

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- Index Range scan, weil cust_id nicht unique ist

--------------------------------------------------------------------------------
-- Query 3:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE ctr_code = 'FR';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- Index Range scan, weil ctr_code nicht unique ist

--------------------------------------------------------------------------------
-- Query 4:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE ctr_code = 'CH';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- Table Access Full Scan, weil es mehr als 5% Adressen wahrscheinlich Schweizer Adressen sind

--------------------------------------------------------------------------------
-- Query 5:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE city = 'Paris';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- Index Range Scan

--------------------------------------------------------------------------------
-- Query 6:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE city = UPPER('Paris');

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- Index Range Scan, weil es auf den Key vom Index geht. Auch, wenn die Funktion UPPER aufgerufen wird.

--------------------------------------------------------------------------------
-- Query 7:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE UPPER(city) = 'PARIS';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- FUll Table Scan, weil auf den key eine Funktion aufgerufen wird

--------------------------------------------------------------------------------
-- Query 8:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE city = 'Berlin';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- Full Table Scan, weil mehr als 5% schätzung

--------------------------------------------------------------------------------
-- Query 9:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, zip_code, city, ctr_code
  FROM addresses
 WHERE city LIKE 'Aesch%';
 
-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- Index Range Scan

--------------------------------------------------------------------------------
-- Query 10:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, zip_code, city, ctr_code
  FROM addresses
 WHERE city LIKE '%stadt';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- Full Table Scan, weil Optimizer mehr schätzt, aber vor allem, weil die Indizes alphabetisch angezeigt werden.

--------------------------------------------------------------------------------
-- Query 11:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT /* +index(addresses adr_zip_city) */ id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE zip_code = 75010 AND city = 'Paris' ;

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- Index Range Scan auf gemeinsamen Key - aber teuer, wegen toNumber


EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE zip_code = 75010 AND city = 'Paris' ;

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- Index Range Scan auf adr_city, weil Zip_code function toNumber augerufen wird

--------------------------------------------------------------------------------
-- Query 12:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE city = 'Paris' AND zip_code = '75010';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- index Range scan auf den adr_zip_city

--------------------------------------------------------------------------------
-- Query 13:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE zip_code = 75010;

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- toNumber -> table full scan

--------------------------------------------------------------------------------
-- Query 14:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE zip_code = '75010';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

--------------------------------------------------------------------------------
-- Query 15:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT zip_code
  FROM addresses
 WHERE city = 'Hamburg';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- Index fast full scan auf zip_city, weil beides im index ist


EXPLAIN PLAN FOR
SELECT zip_code, STREET
  FROM addresses
 WHERE city = 'Hamburg';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

-- Index range scan auf city, weil street nicht im index des zip_city ist _> teuer
