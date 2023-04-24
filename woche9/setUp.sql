--------------------------------------------------------------------------------
-- Table COUNTRIES
--------------------------------------------------------------------------------
CREATE TABLE COUNTRIES
( CODE VARCHAR2(2 BYTE) NOT NULL
, NAME VARCHAR2(100 BYTE) NOT NULL
);

--------------------------------------------------------------------------------
-- Table ADR_TYPES
--------------------------------------------------------------------------------
CREATE TABLE ADR_TYPES
( ADR_TYPE VARCHAR2(2 BYTE) NOT NULL
, LABEL VARCHAR2(20) NOT NULL
);

--------------------------------------------------------------------------------
-- Table CUSTOMERS
--------------------------------------------------------------------------------
CREATE TABLE CUSTOMERS
( ID NUMBER(8) GENERATED BY DEFAULT AS IDENTITY NOT NULL
, FIRST_NAME VARCHAR2(30 BYTE) NOT NULL
, LAST_NAME VARCHAR2(30 BYTE) NOT NULL
, DATE_OF_BIRTH DATE NOT NULL
, TITLE VARCHAR2(10 BYTE)
, GENDER VARCHAR2(1 BYTE)
, MARITAL_STATUS VARCHAR2(10 BYTE)
, MEMBER_FLAG VARCHAR2(1 BYTE)
, ACTIVE_FLAG VARCHAR2(1 BYTE)
, EMAIL_ADDRESS VARCHAR2(100 BYTE)
, LANGUAGE_CODE VARCHAR2(2 BYTE)
);

--------------------------------------------------------------------------------
-- Table ADDRESSES
--------------------------------------------------------------------------------
CREATE TABLE ADDRESSES
( ID NUMBER(8) GENERATED BY DEFAULT AS IDENTITY NOT NULL
, CUST_ID NUMBER(8) NOT NULL
, ADR_TYPE VARCHAR2(2 BYTE) NOT NULL
, STREET VARCHAR2(40 BYTE)
, STREET_NO VARCHAR2(10 BYTE)
, ZIP_CODE VARCHAR2(10 BYTE) NOT NULL
, CITY VARCHAR2(40 BYTE) NOT NULL
, CTR_CODE VARCHAR2(2 BYTE) NOT NULL
);

--------------------------------------------------------------------------------
-- Table PRODUCTS
--------------------------------------------------------------------------------
CREATE TABLE PRODUCTS
( ID NUMBER(8) GENERATED BY DEFAULT AS IDENTITY NOT NULL
, PROD_NAME	VARCHAR2(50 BYTE) NOT NULL
, PROD_DESC	VARCHAR2(4000 BYTE) NOT NULL
, PROD_CATEGORY	VARCHAR2(50 BYTE) NOT NULL
, SUPPLIER_ID	NUMBER(8)
, NUM_ON_STOCK	NUMBER(5)
, LIST_PRICE	NUMBER(8,2)
, MIN_PRICE	NUMBER(8,2)
);

--------------------------------------------------------------------------------
-- Table ORDERS
--------------------------------------------------------------------------------
CREATE TABLE ORDERS
( ID NUMBER(8) GENERATED BY DEFAULT AS IDENTITY NOT NULL
, CUST_ID NUMBER(8) NOT NULL
, ORDER_DATE DATE NOT NULL
);

--------------------------------------------------------------------------------
-- Table ORDER_ITEMS
--------------------------------------------------------------------------------
CREATE TABLE ORDER_ITEMS
( ID NUMBER(8) GENERATED BY DEFAULT AS IDENTITY NOT NULL
, ORDER_ID NUMBER(8) NOT NULL
, LINE_NO NUMBER(2) NOT NULL
, PROD_ID NUMBER(8) NOT NULL
, DELIVERY_DATE DATE
, QUANTITY NUMBER(3) NOT NULL
, PRICE_PER_UNIT NUMBER(8,2) NOT NULL
);

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

--------------------------------------------------------------------------------
-- Primary Key Constraints
--------------------------------------------------------------------------------
ALTER TABLE COUNTRIES ADD CONSTRAINT CTR_PK PRIMARY KEY (CODE);
ALTER TABLE ADR_TYPES ADD CONSTRAINT ATP_PK PRIMARY KEY (ADR_TYPE);
ALTER TABLE CUSTOMERS ADD CONSTRAINT CUST_PK PRIMARY KEY (ID);
ALTER TABLE ADDRESSES ADD CONSTRAINT ADR_PK PRIMARY KEY (ID);
ALTER TABLE PRODUCTS ADD CONSTRAINT PROD_PK PRIMARY KEY (ID);
ALTER TABLE ORDERS ADD CONSTRAINT ORD_PK PRIMARY KEY (ID);
ALTER TABLE ORDER_ITEMS ADD CONSTRAINT ORDI_PK PRIMARY KEY (ID);

--------------------------------------------------------------------------------
-- Unique Constraints
--------------------------------------------------------------------------------
ALTER TABLE ORDER_ITEMS ADD CONSTRAINT ORDI_UK UNIQUE(ORDER_ID, LINE_NO);

--------------------------------------------------------------------------------
-- Foreign Key Constraints
--------------------------------------------------------------------------------
ALTER TABLE ADDRESSES ADD CONSTRAINT ADR_CTR_FK FOREIGN KEY (CTR_CODE) REFERENCES COUNTRIES;
ALTER TABLE ADDRESSES ADD CONSTRAINT ADR_ATP_FK FOREIGN KEY (ADR_TYPE) REFERENCES ADR_TYPES;
ALTER TABLE ADDRESSES ADD CONSTRAINT ADR_CUST_FK FOREIGN KEY (CUST_ID) REFERENCES CUSTOMERS;
ALTER TABLE ORDERS ADD CONSTRAINT ORD_CUST_FK FOREIGN KEY (CUST_ID) REFERENCES CUSTOMERS;
ALTER TABLE ORDER_ITEMS ADD CONSTRAINT ORDI_ORD_FK FOREIGN KEY (ORDER_ID) REFERENCES ORDERS;
ALTER TABLE ORDER_ITEMS ADD CONSTRAINT ORDI_PROD_FK FOREIGN KEY (PROD_ID) REFERENCES PRODUCTS;

--------------------------------------------------------------------------------
-- Adjust Identity Columns
--------------------------------------------------------------------------------
ALTER TABLE CUSTOMERS MODIFY (ID GENERATED BY DEFAULT AS IDENTITY START WITH 20000);
ALTER TABLE ADDRESSES MODIFY (ID GENERATED BY DEFAULT AS IDENTITY START WITH 25000);
ALTER TABLE PRODUCTS MODIFY (ID GENERATED BY DEFAULT AS IDENTITY START WITH 100);
ALTER TABLE ORDERS MODIFY (ID GENERATED BY DEFAULT AS IDENTITY START WITH 2000000);
ALTER TABLE ORDER_ITEMS MODIFY (ID GENERATED BY DEFAULT AS IDENTITY START WITH 10000000);

--------------------------------------------------------------------------------
-- Gather Statistics
--------------------------------------------------------------------------------
BEGIN
   dbms_stats.gather_schema_stats
      (ownname => USER
      ,method_opt => 'FOR ALL COLUMNS SIZE SKEWONLY'
      ,no_invalidate => FALSE);
END;
/















-- Rolle f�r das Administrations-Team
CREATE ROLE DBARC3_ROLE_CUSTOMER_ADMIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON ADDRESSES TO DBARC3_ROLE_CUSTOMER_ADMIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON CUSTOMERS TO DBARC3_ROLE_CUSTOMER_ADMIN;
GRANT SELECT ON ADR_TYPES TO DBARC3_ROLE_CUSTOMER_ADMIN;
GRANT SELECT ON COUNTRIES TO DBARC3_ROLE_CUSTOMER_ADMIN;

-- Hinzuf�gen der Rolle f�r die Administratoren
GRANT DBARC3_ROLE_CUSTOMER_ADMIN TO DANIJEL;
GRANT DBARC3_ROLE_CUSTOMER_ADMIN TO BIANCA;


-- Konfigurationstabelle f�r die CRMs und ihre L�ndercodes
CREATE TABLE CRM_TEAM
(
    USERNAME varchar2(50),
    CTR_CODE varchar2(2),
    CONSTRAINT pk_crm_team PRIMARY KEY (USERNAME, CTR_CODE)
);

-- Hinzuf�gen jedes Mitgliedes mit seinen L�ndercodes
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('HUGENTOBLER', 'CH');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('SONDEREGGER', 'CH');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('SCHMIDT', 'DE');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('NELSON', 'US');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('NELSON', 'CA');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('JASON', 'US');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('JASON', 'CA');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('KELLY', 'GB');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('KELLY', 'NZ');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('KELLY', 'SG');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('DUPONT', 'FR');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('DUPONT', 'IT');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('DUPONT', 'NL');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('DUPONT', 'DK');
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('DUPONT', 'IS');
COMMIT;

-- VIEW erstellen um nur Userdaten zu sehen, welche den L�ndercode des CRMs haben
CREATE OR REPLACE VIEW DBARC3_VIEW_CRM AS
SELECT CUSTOMERS.FIRST_NAME,
       CUSTOMERS.LAST_NAME,
       CUSTOMERS.DATE_OF_BIRTH,
       CUSTOMERS.TITLE,
       CUSTOMERS.GENDER,
       CUSTOMERS.MARITAL_STATUS,
       CUSTOMERS.MEMBER_FLAG,
       CUSTOMERS.ACTIVE_FLAG,
       CUSTOMERS.EMAIL_ADDRESS,
       CUSTOMERS.LANGUAGE_CODE,
       ADR_TYPES.LABEL AS ADDRESS_TYPE,
       ADDRESSES.STREET,
       ADDRESSES.STREET_NO,
       ADDRESSES.ZIP_CODE,
       ADDRESSES.CITY,
       COUNTRIES.NAME  AS COUNTRY_NAME
FROM CUSTOMERS
         JOIN ADDRESSES ON CUSTOMERS.ID = ADDRESSES.CUST_ID
         JOIN ADR_TYPES ON ADR_TYPES.ADR_TYPE = ADDRESSES.ADR_TYPE
         JOIN COUNTRIES ON ADDRESSES.CTR_CODE = COUNTRIES.CODE
WHERE CTR_CODE IN (SELECT CTR_CODE FROM CRM_TEAM WHERE USERNAME = USER);

-- Rolle f�r CRM-Mitglieder erstellen und Rechte f�r die DBARC3_VIEW_CRM hinzuf�gen.
CREATE ROLE DBARC3_ROLE_CRM;
GRANT SELECT ON DBARC3_VIEW_CRM TO DBARC3_ROLE_CRM;

-- Rolle DBARC3_VIEW_CRM allen CRMs hinzuf�gen.
GRANT DBARC3_ROLE_CRM to HUGENTOBLER;
GRANT DBARC3_ROLE_CRM to SONDEREGGER;
GRANT DBARC3_ROLE_CRM to SCHMIDT;
GRANT DBARC3_ROLE_CRM to NELSON;
GRANT DBARC3_ROLE_CRM to JASON;
GRANT DBARC3_ROLE_CRM to KELLY;
GRANT DBARC3_ROLE_CRM to DUPONT;



-- View um nur Adressen des Types 'D' oder 'DP' in der Schweiz anzuzeigen
CREATE OR REPLACE VIEW DBARC3_VIEW_SUPPLIER_CH AS
SELECT TITLE, FIRST_NAME, LAST_NAME, STREET, STREET_NO, ZIP_CODE, CITY
FROM CUSTOMERS
         JOIN ADDRESSES ON ADDRESSES.CUST_ID = CUSTOMERS.ID
WHERE ADDRESSES.CTR_CODE = 'CH'
  AND (ADDRESSES.ADR_TYPE = 'D' OR ADDRESSES.ADR_TYPE = 'DP');


-- Rolle DBARC3_ROLE_SUPPLIER_CH erstellen f�r alle Lieferanten in der Schweiz
CREATE ROLE DBARC3_ROLE_SUPPLIER_CH;
GRANT SELECT ON DBARC3_VIEW_SUPPLIER_CH TO DBARC3_ROLE_SUPPLIER_CH;

-- Rolle DBARC3_ROLE_SUPPLIER_CH zum Lieferanten PAECKLI hinzuf�gen
GRANT DBARC3_ROLE_SUPPLIER_CH to PAECKLI;




-- Anpassungen der Datenschutzbestimmungen aus Aufg. 4
CREATE OR REPLACE VIEW DBARC3_VIEW_CRM AS
SELECT CUSTOMERS.FIRST_NAME,
       CUSTOMERS.LAST_NAME,
       TO_CHAR(CUSTOMERS.DATE_OF_BIRTH, 'DD.MM.') AS DATE_OF_BIRTH,
       CUSTOMERS.TITLE,
       CUSTOMERS.GENDER,
       CUSTOMERS.MEMBER_FLAG,
       CUSTOMERS.ACTIVE_FLAG,
       CUSTOMERS.EMAIL_ADDRESS,
       CUSTOMERS.LANGUAGE_CODE,
       ADR_TYPES.LABEL                            AS ADDRESS_TYPE,
       ADDRESSES.STREET,
       ADDRESSES.STREET_NO,
       ADDRESSES.ZIP_CODE,
       ADDRESSES.CITY,
       COUNTRIES.NAME                             AS COUNTRY_NAME
FROM CUSTOMERS
         JOIN ADDRESSES ON CUSTOMERS.ID = ADDRESSES.CUST_ID
         JOIN ADR_TYPES ON ADR_TYPES.ADR_TYPE = ADDRESSES.ADR_TYPE
         JOIN COUNTRIES ON ADDRESSES.CTR_CODE = COUNTRIES.CODE
WHERE CTR_CODE IN (SELECT CTR_CODE
                   FROM CRM_TEAM
                   WHERE USERNAME = USER);


-- Hinzuf�gen des neuen CRM-Kollegen Volker Volkmann
INSERT INTO CRM_TEAM (USERNAME, CTR_CODE)
VALUES ('VOLKMANN', 'DE');

GRANT DBARC3_ROLE_CRM to VOLKMANN;