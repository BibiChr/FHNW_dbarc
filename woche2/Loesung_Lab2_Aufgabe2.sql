--------------------------------------------------------------------------------
-- Allgemeine Informationen zur Datenbank
--------------------------------------------------------------------------------

-- Welche Oracle-Datenbankversion wird verwendet?
SELECT * FROM v$version;

-- Unter welchem Betriebssystem läuft der Datenbankserver?
SELECT platform_name FROM v$database;

-- Wann wurde die Datenbank erstellt?
SELECT created FROM v$database;

-- Wann wurde die Datenbankinstanz das letzte Mal gestartet?
SELECT startup_time FROM v$instance;

-- Auf welcher Pluggable Database (PDB) befinden wir uns? Gibt es noch weitere PDBs?
SELECT con_id, name, open_mode FROM v$pdbs;

/* Innerhalb einer Pluggable Database sieht man nur die eigene PDB (in unserem
   Fall DB21C_DBARC). Wird die gleiche Abfrage auf der Container Database (CDB)
   ausgeführt, sind alle PDBs sichtbar:
   
    CON_ID NAME                 OPEN_MODE 
---------- -------------------- ----------
         2 PDB$SEED             READ ONLY 
         3 DB21C_PDB1           READ WRITE
         4 DB21C_DBARC          READ WRITE
*/

--------------------------------------------------------------------------------
-- System Global Area (SGA)
--------------------------------------------------------------------------------

-- Wieviel Speicher kann auf unserer Umgebung für die SGA maximal verwendet werden?
SELECT * FROM v$sgainfo WHERE name = 'Maximum SGA Size';
SELECT * FROM v$parameter WHERE name = 'sga_max_size';

-- Wie gross ist der Database Buffer Cache? Wie viele Datenblöcke finden darin Platz?
SELECT * FROM v$sgainfo WHERE name = 'Buffer Cache Size';
SELECT * FROM v$parameter WHERE name = 'db_block_size';
SELECT bytes/8192 FROM v$sgainfo WHERE name = 'Buffer Cache Size';

-- Wie gross ist die In-Memory Area? Hast Du eine Erklärung dafür?
SELECT * FROM v$sgainfo WHERE name = 'In-Memory Area Size';

/* Ist 0, weil In-Memory nicht konfiguriert ist. Oracle Database In-Memory ist
   eine kostenpflichtige Option, die zusätzlich lizenziert werden muss.
*/

-- Welche Sessions sind momentan aktiv auf der Datenbank?
SELECT username, osuser, machine, program, type, status
  FROM v$session
ORDER BY type DESC, username;


--------------------------------------------------------------------------------
-- Redo Logs und Redo Log Files
--------------------------------------------------------------------------------
-- Wie viele Redolog-Gruppen sind vorhanden, und wie viele Files gehören zu jeder Gruppe?
SELECT * FROM v$log;
SELECT * FROM v$logfile;

-- Wie oft wird ein Log Switch durchgeführt?
SELECT * FROM v$log_history ORDER BY sequence# DESC;

--------------------------------------------------------------------------------
-- Konfigurationsparameter
--------------------------------------------------------------------------------
-- Wie viele Konfigurationsparameter gibt es?
SELECT COUNT(*) FROM v$parameter;

-- Wie viele davon lassen sich auf Session-Ebene ändern?
SELECT COUNT(*) FROM v$parameter WHERE isses_modifiable = 'TRUE';

-- Wie gross ist die Blockgrösse eines Datenbankblock? Wie könnte sie geändert werden?
SELECT * FROM v$parameter WHERE NAME = 'db_block_size';

-- Setze den Parameter nls_language mit einem ALTER SESSION Befehl auf 'GERMAN'. Was hat dies für Auswirkungen?
SELECT * FROM v$parameter WHERE NAME = 'nls_language';

ALTER SESSION SET nls_language = 'German';

ALTER SESSION SET nls_language = 'English';
