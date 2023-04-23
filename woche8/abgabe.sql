CREATE INDEX CUST_FN_LN ON CUSTOMERS (FIRST_NAME, LAST_NAME);
CREATE INDEX ADR_ZIP_CITY ON ADDRESSES (ZIP_CODE, CITY, ADR_TYPE);


ALTER TABLE ORDERS
    MODIFY PARTITION BY RANGE (order_date)
        INTERVAL (NUMTOYMINTERVAL(1, 'YEAR'))
        (PARTITION orders_init VALUES LESS THAN (DATE'1950-01-01'));

--hat aber gar keine auswirkung?
ALTER TABLE ORDER_ITEMS
    MODIFY PARTITION BY REFERENCE(ORDI_ORD_FK);

select * from ADR_TYPES;
select * from ADDRESSES;




--------------------------------------------------------------------------------
-- Query 4: Welche Kunden wohnen in Windisch? (4 Punkte)
--------------------------------------------------------------------------------
SELECT c.first_name, c.last_name, c.date_of_birth
  FROM customers c
  JOIN addresses a ON (a.cust_id = c.id)
 WHERE a.zip_code = '5210'
   AND a.city = 'Windisch'
   AND a.adr_type = 'P';

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

--------------------------------------------------------------------------------
-- Query 6: Schweizer Kunden, die 2023 nichts bestellt haben (5 Punkte)
--------------------------------------------------------------------------------
-- todo partition auf ctr.name? oder index?
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
-- todo partition auf adr types?

SELECT c.first_name
     , c.last_name
     , o.order_date
     , i.delivery_date
     , p.prod_name
     , i.quantity
  FROM orders      o
  JOIN order_items i ON (i.order_id = o.id)
  JOIN products    p ON (p.id = i.prod_id)
  JOIN customers   c ON (c.id = o.cust_id)
  JOIN addresses   a ON (a.cust_id = c.id)
  JOIN adr_types   t ON (t.adr_type = a.adr_type)
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
  FROM orders      o
  JOIN order_items i ON (i.order_id = o.id)
  JOIN products prod ON (prod.id = i.prod_id)
   AND o.order_date BETWEEN TO_DATE('01.01.2022', 'dd.mm.yyyy')
                        AND TO_DATE('31.03.2022', 'dd.mm.yyyy')
GROUP BY prod.prod_category
ORDER BY total_revenue DESC;
