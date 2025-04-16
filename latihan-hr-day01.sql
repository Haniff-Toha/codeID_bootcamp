/* Join */
select
 c.region_id,region_name,country_id,country_name
from regions r join countries c
on r.region_id = c.region_id
order by r.region_name,c.country_id;

select
 c.region_id,region_name,c.country_id,country_name,
 location_id,street_address,city,state_province
from regions r
join countries c on r.region_id = c.region_id
join locations l on c.country_id=l.country_id;


select 
	c.country_id,country_name,location_id,street_address,city,state_province
from countries c
left join locations l on c.country_id=l.country_id;

select
c.country_id,country_name,
location_id,street_address,city,state_province
from countries c
right join locations l on c.country_id=l.country_id;


select
 c.country_id,country_name,
 location_id,street_address,city,state_province
from countries c
FULL OUTER JOIN locations l on c.country_id=l.country_id


/* Filtering */
select * from employees
where department_id in (9,10)

select * from employees
where lower(last_name) like lower('king')


select employee_id,first_name||' '||last_name as
full_name,hire_date,TO_CHAR(salary, 'FM999999.00') as salary
from HR.employees
where hire_date between '1997-08-17' and '1998-04-23'


select *
from employees where extract(MONTH from hire_date)=08

--Menggunakan IN
select * from departments where location_id in (
	select l.location_id
	from regions r
	join countries c on r.region_id = c.region_id
	join locations l on c.country_id=l.country_id
	order by l.location_id
)

select department_id,department_name,
(select street_address||' '||postal_code||' '||city||' '||state_province
from locations l where l.location_id=d.location_id)
as address
from departments d

select
 department_id,department_name,l.location_id
from regions r
join countries c on r.region_id = c.region_id
join locations l on c.country_id=l.country_id
join departments d on d.location_id=l.location_id
order by l.location_id

--exist
select * from departments where exists (
 select
 1
 from regions r
 join countries c on r.region_id = c.region_id
 join locations l on c.country_id=l.country_id
 order by l.location_id
)


/* Agregasi */
--sum
select
 d.department_id,d.department_name,
 sum(salary) as total_salary
from departments d
join employees e on d.department_id=e.department_id
group by d.department_id,d.department_name
order by department_name

--avg
select
 d.department_id,d.department_name,
 avg(salary) as total_salary
from departments d
join employees e on d.department_id=e.department_id
group by d.department_id,d.department_name
order by department_name

-- count
select
 d.department_id,d.department_name,
 count(1) as total_employee
from departments d
join employees e on d.department_id=e.department_id
group by d.department_id,d.department_name
order by department_name

--min
select
 d.department_id,d.department_name,
 min(salary) as min_salary
from departments d
join employees e on d.department_id=e.department_id
group by d.department_id,d.department_name
order by department_name

--max
select
 d.department_id,d.department_name,
 max(salary) as max_salary
from departments d
join employees e
on d.department_id=e.department_id
group by d.department_id,d.department_name
order by department_name


-- Filtering: HAVING
select
 d.department_id,d.department_name,
 max(salary) as max_salary
from departments d
join employees e
on d.department_id=e.department_id
group by d.department_id,d.department_name
having max(salary) >= 12000
order by department_name;


/* Common Table Expression (CTE) */
-- simple CTE
with emps as(
 select *
 from employees where department_id in (9,10))
select * from emps where salary >= 8000

-- Multiple CTE
with cte1 as(
 select
 l.location_id
 from regions r
 join countries c on r.region_id = c.region_id
 join locations l on c.country_id=l.country_id
),
cte2 as (
 select * from departments where department_id in (9,10)
)
select * from cte1 join cte2 on cte1.location_id = cte2.location_id;

with recursive hirarki as (
 select
	employee_id,first_name||' '||last_name as full_name,manager_id,1 as level,
 	cast(first_name||' '||last_name as text) as path
 from employees where manager_id is null
 
 union all
 
 select
	k.employee_id,first_name||' '||last_name as full_name,
	k.manager_id, h.level + 1, h.path || ' > ' || first_name||' '||last_name
 from employees k
 join hirarki h on k.manager_id=h.employee_id
)
select * from hirarki
order by path

/* Challange Scheme HR */
SET search_path TO hr;
select * from employees;
select * from departments;

select e.employee_id, 
	(e.first_name||' '||e.last_name) as full_name, 
	e.manager_id,
	d.department_name
from employees e
join departments d on e.department_id = d.department_id;

with recursive hirarki as (
 select
	e.employee_id, 
	(e.first_name||' '||e.last_name) as full_name, 
	e.manager_id,
	d.department_name, 
	1 as level
 from employees e
 join departments d on e.department_id = d.department_id
 where manager_id is null
 
 union all
 
 select
	e.employee_id, 
	(e.first_name||' '||e.last_name) as full_name, 
	e.manager_id,
	d.department_name, h.level + 1
 from employees e
 join departments d on e.department_id = d.department_id
 join hirarki h on e.manager_id=h.employee_id
)
select * from hirarki
order by employee_id