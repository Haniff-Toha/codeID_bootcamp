--9 update customer
update oe.customers as c
set location_id = (select location_id from oe.location_x l 
where l.street_address=c.address and l.postal_code=c.postal_code and l.country_name=c.country)

select * from customers

select * from oe.location_x

--8. alter table customer
    alter table oe.customers
    add column location_id integer;

    alter table oe.customers
    add constraint customer_location_fk Foreign Key (location_id) REFERENCES hr.locations(location_id);


--7 insert into hr.locations
insert into hr.locations
select location_id,street_address,postal_code,city,state_province,country_id from oe.location_x

select * from locations



--6
   merge into hr.countries 
   using (select distinct 
   case 
        when country_name = 'Spain' then 'SP'
        when country_name = 'Venezuela' then 'VZ'
        when country_name = 'Sweden' then 'SW'
        when country_name = 'Norway' then 'NW'
        when country_name = 'Austria' then 'AT'
        when country_name = 'Poland' then 'PL'
        when country_name = 'Ireland' then 'IR'
        when country_name = 'Portugal' then 'PO' 
        when country_name = 'Finland' then 'FI' 
   end country_id,
   country_name, case when country_name = 'Venezuela' then 2 else 1 end region_id
   from oe.location_x
   where country_id is null) as src
   on hr.countries.country_id  = src.country_id
   when matched then
       update set region_id = src.region_id
   when not matched then
       insert (country_id,country_name,region_id) values (src.country_id,src.country_name,src.region_id);

	
--5. update country_id di table location_x
update oe.location_x as x
set country_id = (select country_id from hr.countries where lower(country_name)=lower(x.country_name))

update oe.location_x
set country_id='UK'
where country_name='UK'
and country_id is null

select * from oe.location_x where country_id is null

--4. add column country_id
alter table oe.location_x
add column country_id char(2)

select * from hr.countries where

select * from oe.location_x 

select * from hr.locations in 

--3. create table temporary
create table oe.location_x as
select ROW_NUMBER() OVER (ORDER BY country) + 3000 AS location_id,
address as street_address,postal_code,city,state_province,country as country_name 
from (
select address,postal_code,city,region as state_province,country 
from oe.employees
union
select  address,postal_code,city,region as state_province,country 
from suppliers
union
select  address,postal_code,city,region as state_province,country 
from customers
union
select  ship_address,ship_postal_code,ship_city,ship_region as state_province,ship_country  
from orders)

select * from oe.location_x

drop table oe.location_x


--2. add rownumber()
select ROW_NUMBER() OVER (ORDER BY country) + 3000 AS location_id,
address as street_address,postal_code,city,state_province,country as country_name 
from (
select address,postal_code,city,region as state_province,country 
from oe.employees
union
select  address,postal_code,city,region as state_province,country 
from suppliers
union
select  address,postal_code,city,region as state_province,country 
from customers
union
select  ship_address,ship_postal_code,ship_city,ship_region as state_province,ship_country  
from orders)

--1. populate all attributes locatin di table suppliers,customers, employees and order
select address,city,region,postal_code,country
from oe.employees
union 
select address,city,region,postal_code,country
from oe.suppliers
union 
select address,city,region,postal_code,country
from oe.customers
union 
select ship_address,ship_city,ship_region,ship_postal_code,ship_country
from oe.orders

select * from hr.locations

delete from hr.locations where location_id >= 3000

update oe.customers
set location_id =null

set search_path to oe,hr;