CREATE OR REPLACE VIEW v_customer_addresses AS
SELECT c.id cust_id
     , a.id adr_id
     , c.first_name
     , c.last_name
     , c.date_of_birth
     , c.title
     , c.gender
     , c.marital_status
     , c.member_flag
     , c.active_flag
     , c.email_address
     , c.language_code
     , a.adr_type
     , a.street
     , a.street_no
     , a.zip_code
     , a.city
     , a.ctr_code
  FROM customers c
  JOIN addresses a ON (a.cust_id = c.id)
 WHERE a.ctr_code = 'GB';

--------------------------------------------------------------------------------
-- SELECT
--------------------------------------------------------------------------------

SELECT * FROM v_customer_addresses
 WHERE last_name = 'Potter';

--------------------------------------------------------------------------------
-- INSERT
--------------------------------------------------------------------------------

INSERT INTO v_customer_addresses
   (cust_id, adr_id, first_name, last_name, date_of_birth, adr_type, street, zip_code, city, ctr_code)
VALUES (99999, 99999, 'Lucky', 'Luke', TRUNC(SYSDATE), 'D', 'FHNW Campus Windisch', '5210', 'Windisch', 'CH');

--------------------------------------------------------------------------------
-- UPDATE
--------------------------------------------------------------------------------

UPDATE v_customer_addresses
   SET email_address = 'harry.potter@students.fhnw.ch'
 WHERE last_name = 'Potter';

SELECT * FROM v_customer_addresses
 WHERE last_name = 'Potter';

--------------------------------------------------------------------------------

UPDATE v_customer_addresses
   SET street = 'Bahnhofstrasse'
     , street_no = '8'
     , zip_code = '5210'
     , city = 'Windisch'
 WHERE last_name = 'Potter';

SELECT * FROM v_customer_addresses
 WHERE last_name = 'Potter';

--------------------------------------------------------------------------------

UPDATE v_customer_addresses
   SET email_address = 'harry.potter@students.fhnw.ch'
     , city = 'Windisch'
 WHERE last_name = 'Potter';

SELECT * FROM v_customer_addresses
 WHERE last_name = 'Potter';

--------------------------------------------------------------------------------

SELECT * FROM v_customer_addresses
 WHERE last_name = 'Moneypenny';

UPDATE v_customer_addresses
   SET street = 'Bahnhofstrasse'
     , street_no = '8'
     , zip_code = '5210'
     , city = 'Windisch'
 WHERE last_name = 'Moneypenny';

UPDATE v_customer_addresses
   SET email_address = 'miss.moneypenny@fhnw.ch'
 WHERE last_name = 'Moneypenny';

SELECT * FROM user_updatable_columns
WHERE table_name = 'V_CUSTOMER_ADDRESSES';

--------------------------------------------------------------------------------

UPDATE v_customer_addresses
   SET ctr_code = 'CH'
 WHERE last_name = 'Potter';

SELECT * FROM v_customer_addresses
 WHERE last_name = 'Potter';

--------------------------------------------------------------------------------

ROLLBACK;

--------------------------------------------------------------------------------
-- CHECK Option
--------------------------------------------------------------------------------

CREATE OR REPLACE VIEW v_customer_addresses AS
SELECT c.id cust_id
     , a.id adr_id
     , c.first_name
     , c.last_name
     , c.date_of_birth
     , c.title
     , c.gender
     , c.marital_status
     , c.member_flag
     , c.active_flag
     , c.email_address
     , c.language_code
     , a.adr_type
     , a.street
     , a.street_no
     , a.zip_code
     , a.city
     , a.ctr_code
  FROM customers c
  JOIN addresses a ON (a.cust_id = c.id)
 WHERE a.ctr_code = 'GB'
WITH CHECK OPTION;

UPDATE v_customer_addresses
   SET ctr_code = 'CH'
 WHERE last_name = 'Potter';
