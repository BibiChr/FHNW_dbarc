-- show user
SELECT username, account_status, default_tablespace, created
FROM dba_users
WHERE oracle_maintained = 'N';

-- create user
create
user bianca identified by bibi1234;

-- access for creating session
grant create
session to bianca;

-- access for creating table
grant
create table to bianca;

-- update user to get quota (space / access for insert into table)
alter
user bianca
    quota unlimited on users;

-- finish transaction
commit;

-- delete user
drop user bianca; -- problem if user has objects
drop user bianca cascade; -- delete with objects
-- show user welche manuell angelegt wurden
SELECT username, account_status, default_tablespace, created
 FROM dba_users
 WHERE oracle_maintained = 'N';

-- Haben alle User die Privilegien CREATE SESSION und CREATE TABLE?
SELECT * FROM dba_sys_privs
 WHERE grantee IN (
    SELECT username FROM dba_users
      WHERE oracle_maintained = 'N' AND username != 'PDBADMIN')
ORDER BY grantee, privilege;
-- Sind für jeden User mindestens die Tabellen EMP und DEPT vorhanden?
SELECT owner, table_name, tablespace_name FROM dba_tables
 WHERE owner IN (
   SELECT username FROM dba_users
      WHERE oracle_maintained = 'N' AND username != 'PDBADMIN')
ORDER BY owner, table_name;

