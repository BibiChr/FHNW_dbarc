/* Beispiel für Schema-only Account */

CREATE TABLESPACE dbarc0_ts;

CREATE USER dbarc0 NO AUTHENTICATION
DEFAULT TABLESPACE dbarc0_ts
QUOTA UNLIMITED ON dbarc0_ts;

GRANT dbarc_schema_role TO dbarc0;

ALTER USER dbarc0 GRANT CONNECT THROUGH dani;

-- Connect via User DANI:
connect dani[dbarc0]/<password>@dbarc