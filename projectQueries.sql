--Query 1

select rname, ename from relates where rname = (	
 	select rname from relates group by rname having count(rname)>2
);


------------------------------------------------------------------------------------

--Query 2

select rname, ename 
	from relates 
	where rname = (	
					select rname 
					from relates 
					group by rname 
					having count(rname)=3
	);

--Extra Credit - Display this all on one line.
------------------------------------------------------------------------------------



--Query 3 (need verification)
--Print the name of all binary relationships that have a cardinality --of M-to-M and have max
--cardinality of M.

--All binary relationships
select rname from relates group by rname having count(rname)=2;

SELECT lower(RNAME)
FROM   RELATES
WHERE upper(RL_CARD)='M'
GROUP BY lower(RNAME)
HAVING COUNT (lower(RNAME))=2;

SELECT DISTINCT R.RNAME
FROM   RELATES RL, REL_TYPE R
WHERE LOWER(R.RTYPE)='binary'
 		AND	LOWER(RL.RL_CARD)='m'
 		AND	LOWER(RL.RL_MAX_CARD)='m'
 		AND	RL.RNAME=R.RNAME;

--This top block finds all binary relationships
SELECT rname
FROM relates
WHERE lower(RL_MAX_CARD) = 'm'
GROUP BY rname	
HAVING count(rname)=2
	MINUS
		SELECT DISTINCT rname
		FROM relates
		WHERE lower(rl_card)<>'m';

--This block finds relationships that are not M

--AND with max cardinality of M

------------------------------------------------------------------------------------


--Query 4
--4. For entities that have two or three attributes, print the name --of the entity and its attributes.
SELECT ename, aname
FROM contains
WHERE ename IN( select ename
            	from contains
            	group by ename
            	having count(ename)=any(2,3)
            	)
order by ename;

------------------------------------------------------------------------------------


--Query 5
--5. Print the name of all entities that participate in 2, 3, or 5 relationships.
select ename, rname
	from relates
	where ename in( select ename
					from relates
					group by ename
					having count(ename)=any(2,3,5)
					)
	order by ename;

------------------------------------------------------------------------------------


--Query 6
--6. Print the name of all entities that have at least one attributes with the data type �Date�
select distinct ename
	from contains
	where lower(cn_datatype)='date';

------------------------------------------------------------------------------------


--Query 7
--7. For all attributes that use a domain, print the name the attribute,
--the name of the domain, and the data type of the domain (one line per attribute).
select aname, cn_domain, cn_datatype
	from contains
	where lower(cn_domain) is not null
	order by aname;

------------------------------------------------------------------------------------

--Query 8
--8. Print the name of any attribute, entity, relationship, or specialization
--that has either lowercase �r� or uppercase �R� somewhere in their name.
--For example, if an entity has the name �Project�, your query will print a line
--as �Project	Entity�, and if a relationship has the name Refers�, your query
--also prints a line as �Refers 	Relationship�.
----------------------------
select concat(ename,'Entity')
	From entity_type
	Where lower(ename) like '%r%'
union
select concat(aname,'Attribute')
	From attr_type
	Where lower(aname) like '%r%'
union
select concat(rname,'Relationship')
	From rel_type
	Where lower(rname) like '%r%'
union
	select concat(sname,'Specialization')
		From specialization
	Where lower(sname) like '%r%';

--answer returns 17 rows

------------------------------------------------------------------------------------


--Query 9
--Print the name of entities that participate in at least 2 
--relationships with cardinality of 1 or 
--2 relationships with cardinality M on the end that connects to the --entity.
select distinct ename 
from relates
where lower(rl_card)='1'
group by ename
having count (ename)>1 
-- this selects entiry with two or more card 1
union
select distinct ename 
from relates
where lower(rl_card)='m'
group by ename
having count (ename)=2;  
--this selects entities with two card M


------------------------------------------------------------------------------------

--Query 10
--10. Print the name of each entity that has a Pkey with the name(s)
--of the attribute(s) that form the Pkey
select ename, aname
from contains
where lower(cn_keytype)='pk'
order by ename;

------------------------------------------------------------------------------------

--Query 11
--11. Print the names of all derived and base attributes and the data type of the --each.
--For example, if Age is derived from DOB and the data type of Age is Number(2)
--and the data type of DOB is Date, you need to print: Age Number(2) DOB  Date
select dv.aname, dv.dv_datatype, cn.aname,cn.cn_datatype
from derives dv, contains cn
where dv.att_aname=cn.aname;

------------------------------------------------------------------------------------

--Query 12

--Print the name of all composite attributes and their component 
--attributes for those composite attributes that have one component 
--attributes is defined on a domain.
select att_aname, aname
from is_in
where ii_domain is not null;


------------------------------------------------------------------------------------

--13. Print the name of each specialization, its type (Overlapping or Disjoint),
--and its super type and sub-type entity names. For example, if we have an --overlapping
--specialization S1 with E1 as the super type, E2 and E3 as the subtypes,
--then you will print:
--E1 S1 Overlapping E2
--E1 S1 Overlapping E3
select sp.Ename, sp.sname,concat('Overlapping   ',sb.ename)Ename
from specialization sp, sub sb
where sp.soverlapping='1'
and   sp.sname=sb.sname
union
select sp.Ename, sp.sname,concat('Disjoint  	',sb.ename)Ename
from specialization sp, sub sb
where sp.soverlapping='0'
and   sp.sname=sb.sname;

------------------------------------------------------------------------------------

--14. Print the name of all specialization, their super type entity,
--and the super type entity attribute names (one line per entity and attribute --combination).
--For example, if we have specialization S1 with E1that has attributes A1 and A2 as the super --type,
--then you will print:
   --S1 E1 A1
  --S1 E1 A2
select s.sname, s.ename,cn.aname
from specialization s, contains cn
where lower(s.ename)=lower(cn.ename)
order by s.sname;


------------------------------------------------------------------------------------

--mark? - how do we print the hierarchy he is talking about below?

--15. Print the name of all specialization, their subtype entity, and
--the subtype entity attribute names (one line per entity and attribute --combination).
--For example, if we have specialization S1 with E2 as one subtype with attributes
--A3 and A4 and E3 as the other subtype with attribute A5, then you will print:
   --S1 E2 A3
      --S1 E2 A4
      --S1 E3 A5
select s.sname, s.ename,cn.aname
from  sub s, contains cn
where lower(s.ename)=lower(cn.ename)
order by s.sname;