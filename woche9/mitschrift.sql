explain plan for
select count(*)
from customers
where GENDER = 'M';

SELECT *
FROM table (dbms_xplan.display);


select *
from table (dbms_xplan.display_cursor(sql_id=>'1kygrhz8q06nb', format=>'ALLSTATS LAST'));


-- neu berechnen der Statistiken ohne Histogramme
exec dbms_starts.gather_table_stats(user, 'CUSTOMERS', method_opt= 'for all columns size 1');

select *
from user_tab_statistics;
select * from USER_TAB_COL_STATISTICS;
select stale_stats from USER_TAB_STATISTICS;


select num_rows, sample_size, last_analyzed
from USER_TABLES
where table_name = 'ADDRESSES';


-- was in den statistiken steht, ist der stand der daten, wenn sample gleich num_dist
select column_name, NUM_DISTINCT, num_buckets, HISTOGRAM, SAMPLE_SIZE, LAST_ANALYZED
from user_tab_columns
where table_name = 'ADDRESSES'
order by column_id;

select *
    from USER_INDEXES;





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
-- für den eingerichteten
--          User als owner der Tabelle
--          wurden Histogramme berechnet
--          und statistiken werden sofort verwendet





-- todo: bringt nix?
-- Hier könnte die Tabelle Products in Partitionen anhand der product_category aufgeteilt werden.
-- Hierfür lässt man sich die Kategorien einfach generieren:
SELECT DISTINCT 'PARTITION PROD_CAT_' || SUBSTR(PROD_CATEGORY, 0, 3) || ' VALUES(''' || PRODUCTS.PROD_CATEGORY || '''),'
FROM PRODUCTS;

ALTER TABLE PRODUCTS
    MODIFY PARTITION BY LIST (PROD_CATEGORY)
        (
            PARTITION PROD_CAT_Pho VALUES('Photo'),
            PARTITION PROD_CAT_Per VALUES('Peripherals and Accessories'),
            PARTITION PROD_CAT_Har VALUES('Hardware'),
            PARTITION PROD_CAT_Ele VALUES('Electronics'),
            PARTITION PROD_CAT_Sof VALUES('Software/Other')
        );
-- todo: das verbessert in dieser Anfrage gar nix...





-------
-- EInschränken von Suchergebnissen
select *
from customers
where ROWNUM <=10;
--wenn man das nun sortieren will, wird es nun schwierig.

select * from CUSTOMERS
order by LAST_NAME desc
fetch first 10 ROWS only;

