--------------------------------------------------------------------------------
-- 1. Abfragen auf Data Dictionary
--------------------------------------------------------------------------------
/*
Schaue Dir mit SQL Developer (oder dem Tool Deiner Wahl) die Struktur der 
EMP-Tabelle an (Columns, Constraints, Indexes) an.
Versuche die gleichen Informationen durch SQL-Abfragen auf den Data Dictionary
zu ermitteln. Verwende dazu die USER-Views des Data Dictionary.
*/

SELECT *
  FROM user_tab_columns
 WHERE table_name = 'EMP'
ORDER BY column_id;

SELECT *
  FROM user_constraints
 WHERE table_name = 'EMP'
ORDER BY constraint_name;

SELECT *
  FROM user_indexes
 WHERE table_name = 'EMP'
ORDER BY index_name;

/*
Kopiere Deine SQL-Abfragen und ersetze die USER-Views durch die entsprechenden
ALL-Views des Data Dicionary. Was stellst Du fest, wenn Du die Abfragen ausführst?
*/

SELECT *
  FROM all_tab_columns
 WHERE table_name = 'EMP'
ORDER BY column_id;

--> zusätzlich wird noch OWNER angezeigt. Falls Zugriff auf EMP-Tabellen von
--  anderen Users erlaubt ist, werden diese hier ebenfalls angezeigt.

/*
Kopiere Deine SQL-Abfragen und ersetze die USER-Views durch die entsprechenden
DBA- Views des Data Dicionary. Was stellst Du fest, wenn Du die Abfragen ausführst?
*/

SELECT *
  FROM dba_tab_columns
 WHERE table_name = 'EMP'
ORDER BY column_id;
--> ORA-00942: table or view does not exist
--  (keine Berechtigung vorhanden)

--------------------------------------------------------------------------------
-- 2. Abfragen auf Data Dictionary (DBA-Views)
--------------------------------------------------------------------------------

-- Welches sind die vier grössten Tabellen im Tablespace USERS?
SELECT owner, segment_name, segment_type
     , bytes / 1024 KB
FROM dba_segments
WHERE tablespace_name = 'USERS'
AND segment_type = 'TABLE'
ORDER BY bytes DESC
FETCH FIRST 4 ROWS ONLY;

-- Welches sind die vier grössten Segmente im Tablespace USERS?
SELECT owner, segment_name, segment_type
     , bytes / 1024 KB
FROM dba_segments
WHERE tablespace_name = 'USERS'
ORDER BY bytes DESC
FETCH FIRST 4 ROWS ONLY;

-- Welcher Datenbank-User besitzt die meisten Tabellen?
SELECT owner, COUNT(*)
  FROM dba_tables
GROUP BY owner
ORDER BY COUNT(*) DESC;

-- Was für Tablespaces sind vorhanden, und wie gross (in Megabytes) sind sie?
SELECT * FROM dba_tablespaces;
SELECT * FROM dba_data_files;
SELECT * FROM dba_temp_files;

SELECT tablespace_name, blocks, bytes / 1024 / 1024 MB
FROM dba_data_files
UNION ALL
SELECT tablespace_name, blocks, bytes / 1024 / 1024 MB
FROM dba_temp_files;

--------------------------------------------------------------------------------
-- 3. Deployment von Demo-Schema
--------------------------------------------------------------------------------

CREATE TABLESPACE dbarc0_ts;

CREATE USER dbarc0 IDENTIFIED BY <password>
DEFAULT TABLESPACE dbarc0_ts
QUOTA UNLIMITED ON dbarc0_ts;

GRANT dbarc_schema_role TO dbarc0;
