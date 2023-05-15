--------------------------------------------------------------------------------
-- Erstellung einer Materialized View
--------------------------------------------------------------------------------

--DROP MATERIALIZED VIEW mv_category_revenue_per_day;

CREATE MATERIALIZED VIEW mv_category_revenue_per_day
ENABLE QUERY REWRITE
AS
SELECT prod.prod_category
     , o.order_date
     , SUM(i.quantity * i.price_per_unit) total_revenue
  FROM orders      o
     , order_items i
     , products prod
 WHERE i.order_id = o.id
   AND prod.id = i.prod_id
GROUP BY prod.prod_category, o.order_date;

--------------------------------------------------------------------------------
-- Query 8 (Originalquery aus Lab 7)
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

--------------------------------------------------------------------------------
-- Abfrage in Data Dictionary zu Materialized Views
--------------------------------------------------------------------------------

SELECT mview_name
     , staleness
     , refresh_method
     , last_refresh_type
     , last_refresh_date
  FROM user_mviews;

--------------------------------------------------------------------------------
-- Analysen mit dbms_mview.explain_mview
--------------------------------------------------------------------------------

-- Vorbereitung:
-- Die Tabelle MV_CAPABILITIES_TABLE wird mit dem Script utlsmv.sql erstellt

TRUNCATE TABLE mv_capabilities_table;
exec dbms_mview.explain_mview('MV_CATEGORY_REVENUE_PER_DAY');

SELECT capability_name, possible, msgtxt, related_text
  FROM mv_capabilities_table
 WHERE capability_name NOT LIKE '%PCT%';

--------------------------------------------------------------------------------
-- Analysen mit dbms_mview.explain_rewrite
--------------------------------------------------------------------------------

-- Vorbereitung:
-- Die Tabelle REWRITE_TABLE wird mit dem Script utlsrw.sql erstellt

TRUNCATE TABLE rewrite_table;

DECLARE
   v_query VARCHAR2(1000) := 
     'SELECT prod.prod_category
           , SUM(i.quantity * i.price_per_unit) total_revenue
        FROM orders      o
        JOIN order_items i ON (i.order_id = o.id)
        JOIN products prod ON (prod.id = i.prod_id)
         AND o.order_date BETWEEN TO_DATE(''01.01.2022'', ''dd.mm.yyyy'')
                              AND TO_DATE(''31.03.2022'', ''dd.mm.yyyy'')
      GROUP BY prod.prod_category
      ORDER BY total_revenue DESC';
BEGIN
   dbms_mview.explain_rewrite(v_query, 'MV_CATEGORY_REVENUE_PER_DAY');
END;
/

SELECT message, pass, join_back_tbl, original_cost, rewritten_cost
  FROM rewrite_table
ORDER BY sequence;
