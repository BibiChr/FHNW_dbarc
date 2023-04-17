alter session set nls_date_format = 'dd. Month YYYY';

select TO_CHAR(CUSTOMERS.DATE_OF_BIRTH, 'DD.MM.')           AS DATE_OF_BIRTH,
       TO_CHAR(CUSTOMERS.DATE_OF_BIRTH, 'DD.MM.') || '****' AS DATE_OF_BIRTH1,
       TO_CHAR(CUSTOMERS.DATE_OF_BIRTH, 'DD.MM.****')       AS DATE_OF_BIRTH2
from DBARC3_USER.CUSTOMERS;

select *
from DBARC3_USER.CUSTOMERS
where DATE_OF_BIRTH = to_date('23.07.1956', 'dd.mm.yyyy');

select *
from DBARC3_USER.CUSTOMERS
where DATE_OF_BIRTH = date'1956-07-23';



create index cust_last_name on BIANCA.CUSTOMERS(last_name);
explain plan for
select last_name from BIANCA.CUSTOMERS where LAST_NAME = 'Potter';


SELECT *
FROM TABLE (DBMS_XPLAN.DISPLAY);