Select *
from EMP
         cross join DEPT on DEPT.DEPTNO = EMP.DEPTNO;

Select *
from EMP,
     dept;

SELECT *
from EMP
         join dept on EMP.DEPTNO = DEPT.DEPTNO;
-- vollständig ist inner join, aber ist syntaktisch das gleiche.
-- vor allem dann, wenn die spalten anders heissen
-- Equi-join mit = zeichen

SELECT *
from EMP
         join DEPT using (deptno);
-- schaut, was gleich heisst, und macht dann join
-- geht nur, wenn die attribute gleich heissen.

select *
from EMP
         natural join dept;
-- sollte nicht genutzt werden
-- hier muss das Attribut bei beiden Orten gleich heissen.
-- beispiel, zwei spalten haben id, dann wird das genutzt.

select *
from emp
         join salgrade
              on emp.sal between salgrade.losal AND salgrade.hisal;
-- theta join / band join / non-equi join


-- sind auch equi joins
select *
from emp
         left outer join DEPT D on EMP.DEPTNO = D.DEPTNO;
-- alle mitarbeiter (emp) mit departement (dep) und wenn fehlt, wird alles von dept mit null gefüllt.

select *
from emp
         right outer join DEPT D on EMP.DEPTNO = D.DEPTNO;
-- alle dept werden angezeigt, und nur mitarbeiter die existieren (oder null)


select *
from emp
         full outer join DEPT D on EMP.DEPTNO = D.DEPTNO;
-- alles wird angezeigt, wo etwas fehlt, wir es null