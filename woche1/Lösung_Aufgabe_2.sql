--------------------------------------------------------------------------------
-- Lšsung Aufgabe 2
--------------------------------------------------------------------------------

-- Die nachfolgenden SQL-Befehle mŸssen unter dem User PDBAMIN ausgefŸhrt werden:

-- Neuen User erstellen
CREATE USER test IDENTIFIED BY topsecret;
--          ^^^^               ^^^^^^^^^
--        Username              Passwort

/* Beim Versuch, mit dem neuen User zu connecten, erscheint eine Fehlermeldung:
ORA-01045: user TEST lacks CREATE SESSION privilege; logon denied
*/

-- Privileg CREATE SESSION wird von jedem User benštigt, um sich anzumelden
GRANT CREATE SESSION TO test;

/* Nun funktioniert der Connect, aber beim Erstellen einer Tabelle erscheint
eine andere Fehlermeldung:
ORA-01031: insufficient privileges
*/

/* Um Tabellen erstellen zu kšnnen, wird zusŠtzlich das Privileg CREATE TABLE
benštigt:
*/
GRANT CREATE TABLE TO test;

/* Die Tabellen kšnnen nun erstellt werden, aber beim ersten INSERT gibt es
nochmals ein Problem:
ORA-01950: no privileges on tablespace 'USERS'

Wir brauchen nicht nur die Berechtigung, um Tabellen zu erstellen, sondern auch
Schreibberechtigungen auf den zugehšrigen "Tablespace", in welchem die Tabelle
gespeichert ist. In unserem Fall ist dies der Default-Tablespace USERS.

†ber "Quotas" kšnnte der maximale Speicherplatz eingeschrŠnkt werden, aber wir
erlauben hier den Zugriff auf Tablespace ohne EinschrŠnkung.
*/

ALTER USER test QUOTA UNLIMITED ON USERS;
--         ^^^^       ^^^^^^^^^    ^^^^^
--       Username      Limite     Tablespace

--------------------------------------------------------------------------------
-- †berprŸfung der Ergebnisse
--------------------------------------------------------------------------------

/* Mit Abfragen auf verschiedene Data Dictionary Views (Theorie dazu folgt spŠter)
kšnnen wir ŸberprŸfunge, ob alle persšnlichen User korrekt erstellt wurden. Nachfolgend
ein paar typische SQL-Abfragen, wie dies gemacht werden kann.
*/

-- Wurden alle persšnlichen User erstellt?
SELECT username, account_status, default_tablespace, created FROM dba_users
 WHERE oracle_maintained = 'N';

-- Haben alle User die Privilegien CREATE SESSION und CREATE TABLE?
SELECT * FROM dba_sys_privs
 WHERE grantee IN (SELECT username
                     FROM dba_users
                    WHERE oracle_maintained = 'N'
                      AND username != 'PDBADMIN')
ORDER BY grantee, privilege;

-- Sind fŸr jeden User mindestens die Tabellen EMP und DEPT vorhanden?
SELECT owner, table_name, tablespace_name
  FROM dba_tables
 WHERE owner IN (SELECT username
                   FROM dba_users
                  WHERE oracle_maintained = 'N'
                    AND username != 'PDBADMIN')
ORDER BY owner, table_name;
