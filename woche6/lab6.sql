CREATE TABLE customers
(
    id             NUMBER(8)         NOT NULL,
    first_name     VARCHAR2(30 BYTE) NOT NULL,
    last_name      VARCHAR2(30 BYTE) NOT NULL,
    date_of_birth  DATE              NOT NULL,
    title          VARCHAR2(10 BYTE),
    gender         VARCHAR2(1 BYTE),
    marital_status VARCHAR2(10 BYTE),
    member_flag    VARCHAR2(1 BYTE),
    active_flag    VARCHAR2(1 BYTE),
    email_address  VARCHAR2(100 BYTE),
    language_code  VARCHAR2(2 BYTE)
)
    PARTITION BY RANGE (date_of_birth)
(
    PARTITION p_gen_silent VALUES LESS THAN (TO_DATE('01.01.1946', 'dd.mm.yyyy')),
    PARTITION p_gen_boomer VALUES LESS THAN (TO_DATE('01.01.1965', 'dd.mm.yyyy')),
    PARTITION p_gen_x VALUES LESS THAN (TO_DATE('01.01.1981', 'dd.mm.yyyy')),
    PARTITION p_gen_y VALUES LESS THAN (TO_DATE('01.01.1997', 'dd.mm.yyyy')),
    PARTITION p_gen_z VALUES LESS THAN (TO_DATE('01.01.2011', 'dd.mm.yyyy')),
    PARTITION p_gen_alpha VALUES LESS THAN (TO_DATE('01.01.2026', 'dd.mm.yyyy'))
);


INSERT INTO customers
SELECT *
FROM dbarc_base.customers;
COMMIT;

Begin
    dbms_stats.gather_table_stats(USER, 'CUSTOMERS');
end;

SELECT partition_position, partition_name, num_rows, high_value
FROM user_tab_partitions
WHERE table_name = 'CUSTOMERS';

explain plan for
select *
from customers
where EXTRACT(YEAR FROM date_of_birth) = 1993;

EXPLAIN PLAN FOR
SELECT *
FROM customers
WHERE date_of_birth >= TO_DATE('1993-01-01', 'YYYY-MM-DD')
  AND date_of_birth < TO_DATE('1994-01-01', 'YYYY-MM-DD');


EXPLAIN PLAN FOR
SELECT *
FROM customers
WHERE date_of_birth BETWEEN TO_DATE('1993-01-01', 'YYYY-MM-DD')
          AND TO_DATE('1994-01-01', 'YYYY-MM-DD');

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);



-- explain plan for
select *
from customers
where gender != 'F'
  AND gender != 'M';



ALTER TABLE customers
    MODIFY PARTITION BY LIST (gender)
        (PARTITION p_male VALUES ('M')
        ,PARTITION p_female VALUES ('F')
        ,PARTITION p_other VALUES (DEFAULT)
        );


CREATE TABLE orders
(
    id         NUMBER(8) NOT NULL,
    cust_id    NUMBER(8) NOT NULL,
    order_date DATE      NOT NULL
)
    PARTITION BY RANGE (order_date)
    INTERVAL (NUMTOYMINTERVAL(1, 'MONTH'))
(
    PARTITION p_old_data VALUES LESS THAN (TO_DATE('01.01.2020', 'dd.mm.yyyy'))
);

SELECT partition_position, partition_name, num_rows, high_value
FROM user_tab_partitions
WHERE table_name = 'ORDERS';

INSERT INTO orders
SELECT *
FROM dbarc_base.orders
WHERE order_date BETWEEN TO_DATE('01.01.2023', 'dd.mm.yyyy')
          AND TO_DATE('31.12.2023', 'dd.mm.yyyy');
COMMIT;

select *
from orders;

begin
    dbms_stats.gather_table_stats(USER, 'ORDERS');
end;



CREATE TABLE full_table_scan AS
SELECT oi.order_id
     , oi.line_no
     , o.order_date
     , oi.delivery_date
     , c.title
     , c.first_name
     , c.last_name
     , c.email_address
     , p.prod_name
     , p.prod_desc
     , p.prod_category
     , oi.quantity
FROM dbarc_base.customers c
         JOIN dbarc_base.orders o ON (o.cust_id = c.id)
         JOIN dbarc_base.order_items oi ON (oi.order_id = o.id)
         JOIN dbarc_base.products p ON (p.id = oi.prod_id);


explain plan for
SELECT COUNT(*) FROM full_table_scan;

SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);


explain plan for
SELECT COUNT(*) FROM full_table_scan WHERE order_date >= TO_DATE('01.01.2023', 'dd.mm.yyyy');

Alter table full_table_scan move compress;
begin
    dbms_stats.gather_table_stats(USER, 'FULL_TABLE_SCAN');
end;