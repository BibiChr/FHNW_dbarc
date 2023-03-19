CREATE TABLESPACE DBARC3_TS;

SELECT FILE_NAME, (BYTES) / (1024 * 1024) AS "Size (MB)"
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME = 'DBARC3_TS';
-- 100 mb

CREATE USER DBARC3_USER
    IDENTIFIED BY DBARC3_USER
    DEFAULT TABLESPACE DBARC3_TS
    QUOTA UNLIMITED ON DBARC3_TS;

GRANT dbarc_scheme_role to DBARC3_USER;

-- dbarc_create_tables.sql

select *
from USER_TABLES;
select *
from USER_SEGMENTS;

-- dbarc_load_data.sql

SELECT FILE_NAME, (BYTES) / (1024 * 1024) AS "Size (MB)"
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME = 'DBARC3_TS';
-- 400 mb

--dbarc_finish_setup.sql
SELECT FILE_NAME, (BYTES) / (1024 * 1024) AS "Size (MB)"
FROM DBA_DATA_FILES
WHERE TABLESPACE_NAME = 'DBARC3_TS';
-- 800 mb

select TABLE_NAME, NUM_ROWS
from USER_TABLES;
Select count(*)
from ADDRESSES;


--Wie viele Länder sind in der Tabelle COUNTRIES vorhanden?
SELECT COUNT(*)
FROM COUNTRIES;

--Wie viele unterschiedliche Länder kommen in der Tabelle ADDRESSES vor? Welches sind die drei häufigsten verwendeten Länder?
SELECT CTR_CODE
FROM ADDRESSES
GROUP BY CTR_CODE;

SELECT COUNT(DISTINCT CTR_CODE) AS NUM_OF_COUNTRIES
FROM ADDRESSES;

SELECT CTR_CODE, COUNT(*) AS COUNTRY_COUNT
FROM ADDRESSES
GROUP BY CTR_CODE
ORDER BY COUNTRY_COUNT DESC
    FETCH FIRST 3 ROWS ONLY;

--Wo wohnt Harry Potter?
SELECT *
from ADDRESSES;

SELECT STREET, STREET_NO, CITY, CTR_CODE
from CUSTOMERS
         join ADDRESSES on CUSTOMERS.ID = ADDRESSES.CUST_ID
where LAST_NAME = 'Potter'
  AND FIRST_NAME = 'Harry';

--Was ist die Adresse von James Bond?
SELECT STREET, STREET_NO, CITY, CTR_CODE
from CUSTOMERS
         join ADDRESSES on CUSTOMERS.ID = ADDRESSES.CUST_ID
where LAST_NAME = 'Bond'
  AND FIRST_NAME = 'James';

--Warum hat Miss Moneypenny zwei verschiedene Adressen?
SELECT STREET, STREET_NO, CITY, CTR_CODE
from CUSTOMERS
         join ADDRESSES on CUSTOMERS.ID = ADDRESSES.CUST_ID
where LAST_NAME = 'Moneypenny';

SELECT *
from CUSTOMERS
where LAST_NAME = 'Moneypenny';

select *
from ADDRESSES
where CUST_ID = 456;
-- Weil in der Adress Tabelle zwei Addressen auf sie gespeichert wurden.

--Welcher Kunde oder welche Kundin hat am meisten Bestellungen (ORDERS) ausgeführt?
Select CUST_ID, count(*) AS "Orders"
from ORDERS
group by CUST_ID
order by "Orders" desc;

Select CUST_ID, CUSTOMERS.FIRST_NAME, CUSTOMERS.LAST_NAME, count(*) AS "Orders"
from ORDERS
         join CUSTOMERS on CUSTOMERS.ID = ORDERS.CUST_ID
group by CUST_ID, CUSTOMERS.LAST_NAME, CUSTOMERS.FIRST_NAME
order by "Orders" desc;

SELECT Count(*), FIRST_NAME, LAST_NAME
from ORDERS
         left outer join CUSTOMERS on CUSTOMERS.ID = ORDERS.CUST_ID
group by FIRST_NAME, LAST_NAME
order by count(*) desc;

--An welchem Datum sind die letzten Bestellungen eingetroffen, und wie viele waren es?
Select max(ORDER_DATE)
from ORDERS;

SELECT count(*), ORDER_DATE
from ORDERS
where ORDER_DATE = (Select Max(ORDER_DATE) From ORDERS)
group by ORDER_DATE;

Select count(*), ORDER_DATE
from ORDERS
group by ORDER_DATE
order by ORDER_DATE desc
    fetch first 1 rows only;

--Wie oft wurde das Produkt „Y Box“ im Dezember 2022 bestellt?
select *
from ORDERS;
select *
from ORDER_ITEMS;

Select *
from ORDER_ITEMS
         join ORDERS on ORDERS.ID = ORDER_ITEMS.ORDER_ID
where ORDER_DATE Like '%.12.22';

Select ID
from PRODUCTS
where PROD_NAME = 'Y Box';

SELECT count(*)
FROM ORDER_ITEMS
         LEFT OUTER JOIN ORDERS on ORDERS.ID = ORDER_ITEMS.ORDER_ID
where ORDER_DATE Like '%.12.22'
  AND ORDER_ITEMS.PROD_ID = (Select PRODUCTS.ID
                             from PRODUCTS
                             where PROD_NAME = 'Y Box');

-- 3417