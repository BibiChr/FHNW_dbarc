--------------------------------------------------------------------------------
-- Copy data from DBARC_BASE
--------------------------------------------------------------------------------

INSERT /*+ append */ INTO ADR_TYPES 
SELECT * FROM DBARC_BASE.ADR_TYPES;

INSERT /*+ append */ INTO COUNTRIES
SELECT * FROM DBARC_BASE.COUNTRIES;

INSERT /*+ append */ INTO CUSTOMERS
SELECT * FROM DBARC_BASE.CUSTOMERS;

INSERT /*+ append */ INTO ADDRESSES
SELECT * FROM DBARC_BASE.ADDRESSES;

INSERT /*+ append */ INTO PRODUCTS
SELECT * FROM DBARC_BASE.PRODUCTS;

INSERT /*+ append */ INTO ORDERS
SELECT * FROM DBARC_BASE.ORDERS;

INSERT /*+ append */ INTO ORDER_ITEMS
SELECT * FROM DBARC_BASE.ORDER_ITEMS;

COMMIT;
