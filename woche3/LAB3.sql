-- User views auf Data Dictionary
SELECT *
FROM DICTIONARY
WHERE TABLE_NAME LIKE 'USER%'
ORDER BY TABLE_NAME;

-- Constraints einer Tabelle anzeigen lassen
SELECT constraint_name, constraint_type, search_condition
FROM user_constraints
WHERE table_name = 'EMP';

SELECT *
FROM user_constraints
WHERE table_name = 'EMP';

SELECT *
FROM all_constraints
WHERE table_name = 'EMP';

SELECT constraint_name, constraint_type, search_condition
FROM all_constraints
WHERE table_name = 'EMP';


SELECT constraint_name, constraint_type, search_condition
FROM DBA_constraints
WHERE table_name = 'EMP';

SELECT *
FROM dba_constraints
WHERE table_name = 'EMP';


SELECT segment_name, owner, bytes
FROM dba_segments
WHERE tablespace_name = 'USERS'
  AND segment_type = 'TABLE'
ORDER BY bytes desc
    FETCH FIRST 4 ROWS ONLY;


Select *
from DBA_SEGMENTS;

SELECT segment_type, segment_name, owner, bytes
from DBA_SEGMENTS
WHERE tablespace_name = 'USERS'
ORDER BY bytes desc
    FETCH FIRST 4 ROWS ONLY;

Select count(*), owner
from DBA_SEGMENTS
WHERE tablespace_name = 'USERS'
  AND segment_type = 'TABLE'
group by owner
order by count(*) desc
    FETCH FIRST 3 ROWS ONLY;

select *
from DBA_SEGMENTS
where owner = 'DANIJEL';

select * from all_tables
             where owner = 'DANIJEL';

select * from DANIJEL.Testdanijel;

SELECT *
FROM dba_tablespaces;

SELECT tablespace_name, SUM(bytes)
FROM dba_data_files
GROUP BY tablespace_name
order by sum(bytes) desc ;

-- In Megabytes anzeigen
SELECT t.tablespace_name, ROUND(SUM(d.bytes)/(1024*1024)) AS "Size (MB)"
FROM dba_tablespaces t, dba_data_files d
WHERE t.tablespace_name = d.tablespace_name
GROUP BY t.tablespace_name
order by "Size (MB)" desc;



