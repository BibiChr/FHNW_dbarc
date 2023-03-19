/* Anhand der View SECURE_EMP werden verschiedene Varianten von
   Column-Level Security und Row-Level Security aufgezeigt
*/

--------------------------------------------------------------------------------
-- Column-Level Security
--------------------------------------------------------------------------------

-- Lohndaten (Salary) darf nicht angezeigt werden
--> View SECURE_EMP zeigt nur die erlaubten Attribute (Columns) an

CREATE OR REPLACE VIEW secure_emp AS
SELECT EMPNO
     , ENAME
     , JOB
     , MGR
     , HIREDATE
--     , SAL
     , COMM
     , DEPTNO
FROM emp;

GRANT SELECT ON secure_emp TO EMPLOYEES_ROLE;

-- Als Alternative kann das Attribut angezeigt werden, aber
-- "maskiert" werden (z.B. mit Sternchen)

CREATE OR REPLACE VIEW secure_emp AS
SELECT EMPNO
     , ENAME
     , JOB
     , MGR
     , HIREDATE
     , '********' AS SAL
     , COMM
     , DEPTNO
FROM emp;

--------------------------------------------------------------------------------
-- Row-Level Security
--------------------------------------------------------------------------------

-- Manager dürfen nicht angezeigt werden:

CREATE OR REPLACE VIEW secure_emp AS
SELECT EMPNO
     , ENAME
     , JOB
     , MGR
     , HIREDATE
     , SAL
     , COMM
     , DEPTNO
FROM emp
WHERE job <> 'MANAGER';

-- Nur eigene Mitarbeiterdaten werden angezeigt:

CREATE OR REPLACE VIEW secure_emp AS
SELECT EMPNO
     , ENAME
     , JOB
     , MGR
     , HIREDATE
     , SAL
     , COMM
     , DEPTNO
FROM emp
WHERE ename = USER;

-- Nur Mitarbeiter aus der eigenen Abteilung:

CREATE OR REPLACE VIEW secure_emp AS
SELECT EMPNO
     , ENAME
     , JOB
     , MGR
     , HIREDATE
     , SAL
     , COMM
     , DEPTNO
FROM emp
WHERE deptno in (SELECT deptno FROM emp WHERE ename = USER);

--------------------------------------------------------------------------------
-- Column-/Row-Level Security
--------------------------------------------------------------------------------

-- Nur Mitarbeiter aus der eigenen Abteilung, aber ohne Lohndaten:

CREATE OR REPLACE VIEW secure_emp AS
SELECT EMPNO
     , ENAME
     , JOB
     , MGR
     , HIREDATE
     , CASE 
          WHEN ename = USER THEN SAL
          ELSE NULL
       END AS SAL
     , COMM
     , DEPTNO
FROM emp
WHERE deptno in (SELECT deptno FROM emp WHERE ename = USER);
