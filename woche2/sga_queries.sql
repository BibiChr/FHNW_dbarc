--------------------------------------------------------------------------------
-- General Database Information
--------------------------------------------------------------------------------

SELECT * FROM v$database;
SELECT * FROM v$instance;
SELECT * FROM v$version;
SELECT * FROM v$pdbs;

--------------------------------------------------------------------------------
-- System Global Area (SGA)
--------------------------------------------------------------------------------

SELECT * FROM v$sga;
SELECT * FROM v$sgainfo;
SELECT * FROM v$parameter WHERE name LIKE '%size';

SELECT username, osuser, machine, program, type, status
  FROM v$session
ORDER BY type DESC, username;

--------------------------------------------------------------------------------
-- Redo Logs / Redo Log Files
--------------------------------------------------------------------------------

SELECT * FROM v$log;
SELECT * FROM v$logfile;
SELECT * FROM v$log_history;

--------------------------------------------------------------------------------
-- Configuration Parameter
--------------------------------------------------------------------------------

SELECT * FROM v$parameter;
SELECT * FROM v$parameter WHERE NAME = 'db_block_size';
SELECT * FROM v$parameter WHERE NAME = 'nls_language';

