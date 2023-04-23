--------------------------------------------------------------------------------
-- Table COUNTRIES2
--------------------------------------------------------------------------------
CREATE TABLE COUNTRIES2
(
    CODE VARCHAR2(2 BYTE)   NOT NULL,
    NAME VARCHAR2(100 BYTE) NOT NULL
);

--------------------------------------------------------------------------------
-- Table ADR_TYPES2
--------------------------------------------------------------------------------
CREATE TABLE ADR_TYPES2
(
    ADR_TYPE VARCHAR2(2 BYTE) NOT NULL,
    LABEL    VARCHAR2(20)     NOT NULL
);

--------------------------------------------------------------------------------
-- Table CUSTOMERS2
--------------------------------------------------------------------------------
CREATE TABLE CUSTOMERS2
(
    ID             NUMBER(8) GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    FIRST_NAME     VARCHAR2(30 BYTE)                          NOT NULL,
    LAST_NAME      VARCHAR2(30 BYTE)                          NOT NULL,
    DATE_OF_BIRTH  DATE                                       NOT NULL,
    TITLE          VARCHAR2(10 BYTE),
    GENDER         VARCHAR2(1 BYTE),
    MARITAL_STATUS VARCHAR2(10 BYTE),
    MEMBER_FLAG    VARCHAR2(1 BYTE),
    ACTIVE_FLAG    VARCHAR2(1 BYTE),
    EMAIL_ADDRESS  VARCHAR2(100 BYTE),
    LANGUAGE_CODE  VARCHAR2(2 BYTE)
);

--------------------------------------------------------------------------------
-- Table ADDRESSES2
--------------------------------------------------------------------------------
CREATE TABLE ADDRESSES2
(
    ID        NUMBER(8) GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    CUST_ID   NUMBER(8)                                  NOT NULL,
    ADR_TYPE  VARCHAR2(2 BYTE)                           NOT NULL,
    STREET    VARCHAR2(40 BYTE),
    STREET_NO VARCHAR2(10 BYTE),
    ZIP_CODE  VARCHAR2(10 BYTE)                          NOT NULL,
    CITY      VARCHAR2(40 BYTE)                          NOT NULL,
    CTR_CODE  VARCHAR2(2 BYTE)                           NOT NULL
);

--------------------------------------------------------------------------------
-- Table PRODUCTS2
--------------------------------------------------------------------------------
CREATE TABLE PRODUCTS2
(
    ID            NUMBER(8) GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    PROD_NAME     VARCHAR2(50 BYTE)                          NOT NULL,
    PROD_DESC     VARCHAR2(4000 BYTE)                        NOT NULL,
    PROD_CATEGORY VARCHAR2(50 BYTE)                          NOT NULL,
    SUPPLIER_ID   NUMBER(8),
    NUM_ON_STOCK  NUMBER(5),
    LIST_PRICE    NUMBER(8, 2),
    MIN_PRICE     NUMBER(8, 2)
);

--------------------------------------------------------------------------------
-- Table ORDERS2
--------------------------------------------------------------------------------
CREATE TABLE ORDERS2
(
    ID         NUMBER(8) GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    CUST_ID    NUMBER(8)                                  NOT NULL,
    ORDER_DATE DATE                                       NOT NULL
);

--------------------------------------------------------------------------------
-- Table ORDER_ITEMS2
--------------------------------------------------------------------------------
CREATE TABLE ORDER_ITEMS2
(
    ID             NUMBER(8) GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    ORDER_ID       NUMBER(8)                                  NOT NULL,
    LINE_NO        NUMBER(2)                                  NOT NULL,
    PROD_ID        NUMBER(8)                                  NOT NULL,
    DELIVERY_DATE  DATE,
    QUANTITY       NUMBER(3)                                  NOT NULL,
    PRICE_PER_UNIT NUMBER(8, 2)                               NOT NULL
);


--------------------------------------------------------------------------------
-- Copy data from DBARC_BASE
--------------------------------------------------------------------------------

INSERT /*+ append */ INTO ADR_TYPES2
SELECT *
FROM DBARC_BASE.ADR_TYPES;

INSERT /*+ append */ INTO COUNTRIES2
SELECT *
FROM DBARC_BASE.COUNTRIES;

INSERT /*+ append */ INTO CUSTOMERS2
SELECT *
FROM DBARC_BASE.CUSTOMERS;

INSERT /*+ append */ INTO ADDRESSES2
SELECT *
FROM DBARC_BASE.ADDRESSES;

INSERT /*+ append */ INTO PRODUCTS2
SELECT *
FROM DBARC_BASE.PRODUCTS;

INSERT /*+ append */ INTO ORDERS2
SELECT *
FROM DBARC_BASE.ORDERS;

INSERT /*+ append */ INTO ORDER_ITEMS2
SELECT *
FROM DBARC_BASE.ORDER_ITEMS;

COMMIT;


--------------------------------------------------------------------------------
-- Primary Key Constraints
--------------------------------------------------------------------------------
ALTER TABLE COUNTRIES2
    ADD CONSTRAINT CTR_PK2 PRIMARY KEY (CODE);
ALTER TABLE ADR_TYPES2
    ADD CONSTRAINT ATP_PK2 PRIMARY KEY (ADR_TYPE);
ALTER TABLE CUSTOMERS2
    ADD CONSTRAINT CUST_PK2 PRIMARY KEY (ID);
ALTER TABLE ADDRESSES2
    ADD CONSTRAINT ADR_PK2 PRIMARY KEY (ID);
ALTER TABLE PRODUCTS2
    ADD CONSTRAINT PROD_PK2 PRIMARY KEY (ID);
ALTER TABLE ORDERS2
    ADD CONSTRAINT ORD_PK2 PRIMARY KEY (ID);
ALTER TABLE ORDER_ITEMS2
    ADD CONSTRAINT ORDI_PK2 PRIMARY KEY (ID);

--------------------------------------------------------------------------------
-- Unique Constraints
--------------------------------------------------------------------------------
ALTER TABLE ORDER_ITEMS2
    ADD CONSTRAINT ORDI_UK2 UNIQUE (ORDER_ID, LINE_NO);

--------------------------------------------------------------------------------
-- Foreign Key Constraints
--------------------------------------------------------------------------------
ALTER TABLE ADDRESSES2
    ADD CONSTRAINT ADR_CTR_FK2 FOREIGN KEY (CTR_CODE) REFERENCES COUNTRIES2;
ALTER TABLE ADDRESSES2
    ADD CONSTRAINT ADR_ATP_FK2 FOREIGN KEY (ADR_TYPE) REFERENCES ADR_TYPES2;
ALTER TABLE ADDRESSES2
    ADD CONSTRAINT ADR_CUST_F2  FOREIGN KEY (CUST_ID) REFERENCES CUSTOMERS2;
ALTER TABLE ORDERS2
    ADD CONSTRAINT ORD_CUST_F2  FOREIGN KEY (CUST_ID) REFERENCES CUSTOMERS2;
ALTER TABLE ORDER_ITEMS2
    ADD CONSTRAINT ORDI_ORD_F2  FOREIGN KEY (ORDER_ID) REFERENCES ORDERS2;
ALTER TABLE ORDER_ITEMS2
    ADD CONSTRAINT ORDI_PROD_2  FOREIGN KEY (PROD_ID) REFERENCES PRODUCTS2;

--------------------------------------------------------------------------------
-- Adjust Identity Columns
--------------------------------------------------------------------------------
ALTER TABLE CUSTOMERS2
    MODIFY (ID GENERATED BY DEFAULT AS IDENTITY START WITH 20000);
ALTER TABLE ADDRESSES2
    MODIFY (ID GENERATED BY DEFAULT AS IDENTITY START WITH 25000);
ALTER TABLE PRODUCTS2
    MODIFY (ID GENERATED BY DEFAULT AS IDENTITY START WITH 100);
ALTER TABLE ORDERS2
    MODIFY (ID GENERATED BY DEFAULT AS IDENTITY START WITH 2000000);
ALTER TABLE ORDER_ITEMS2
    MODIFY (ID GENERATED BY DEFAULT AS IDENTITY START WITH 10000000);

--------------------------------------------------------------------------------
-- Gather Statistics
--------------------------------------------------------------------------------
BEGIN
    dbms_stats.gather_schema_stats
        (ownname => USER
        , method_opt => 'FOR ALL COLUMNS SIZE SKEWONLY'
        , no_invalidate => FALSE);
END;
/

