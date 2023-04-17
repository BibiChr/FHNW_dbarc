--------------------------------------------------------------------------------
-- Query 1:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE id = 17140;

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

--------------------------------------------------------------------------------
-- Query 2:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE cust_id = 456;

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

--------------------------------------------------------------------------------
-- Query 3:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE ctr_code = 'FR';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

--------------------------------------------------------------------------------
-- Query 4:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE ctr_code = 'CH';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

--------------------------------------------------------------------------------
-- Query 5:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE city = 'Paris';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

--------------------------------------------------------------------------------
-- Query 6:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE city = UPPER('Paris');

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

--------------------------------------------------------------------------------
-- Query 7:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE UPPER(city) = 'PARIS';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

--------------------------------------------------------------------------------
-- Query 8:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE city = 'Berlin';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

--------------------------------------------------------------------------------
-- Query 9:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, zip_code, city, ctr_code
  FROM addresses
 WHERE city LIKE 'Aesch%';
 
-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

--------------------------------------------------------------------------------
-- Query 10:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, zip_code, city, ctr_code
  FROM addresses
 WHERE city LIKE '%stadt';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

--------------------------------------------------------------------------------
-- Query 11:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE city = 'Paris' AND zip_code = 75010;

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

--------------------------------------------------------------------------------
-- Query 12:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE city = 'Paris' AND zip_code = '75010';

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

--------------------------------------------------------------------------------
-- Query 13:
--------------------------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT id, cust_id, adr_type, street, street_no, zip_code, city, ctr_code
  FROM addresses
 WHERE zip_code = 75010;

-- Index or Full Table Scan? Think first, then check the execution plan:
SELECT * FROM TABLE(dbms_xplan.display);

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
