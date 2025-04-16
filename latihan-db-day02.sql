set search_path to oe,hr;

--1. populate all attributes location di tabel suppliers , customers, employees, dan order
select address, city, region, postal_code, country
from oe.employees
union --menerapkan distinc (union all, tidak)
select address, city, region, postal_code, country
from oe.suppliers
union
select address, city, region, postal_code, country
from oe.customers
union
select ship_address, ship_city, ship_region, ship_postal_code, ship_country
from oe.orders

select * from hr.locations;

--2. add row number
select ROW_NUMBER() OVER (ORDER BY country) + 3000 AS location_id,address as
street_address,postal_code,city,state_province,country as country_name 
from(
select address,postal_code,city,region as state_province,country 
from oe.employees
union
select address,postal_code,city,region as state_province,country 
from suppliers
union
select address,postal_code,city,region as state_province,country 
from customers
union
select ship_address,ship_postal_code,ship_city,ship_region as
state_province,ship_country 
from orders)

--3. create table temporary
create table oe.location_x as
select ROW_NUMBER() OVER (ORDER BY country) + 3000 AS location_id,address
as street_address,postal_code,city,state_province,country as country_name
from (
select address,postal_code,city,region as state_province,country 
from oe.employees
union
select address,postal_code,city,region as state_province,country 
from suppliers
union
select address,postal_code,city,region as state_province,country 
from customers
union
select ship_address,ship_postal_code,ship_city,ship_region as
state_province,ship_country 
from orders)

select * from oe.location_x

--4. menambahkan country_id untuk tabel locations_x untuk menyesuaikan dengan tabel location di hr
alter table oe.location_x 
add column country_id char(2)

select * from oe.location_x

--5. Mengisi kolom country_id dalam tabel oe.loaction_x sesuai dengan hr.countries
select * from hr.countries

update oe.location_x as x
set country_id = (select country_id from hr.countries where upper(country_name) = upper(x.country_name))
where country_id is null

select * from oe.location_x where country_id is null

-- untuk USA dan UK
update oe.location_x
set country_id ='UK'
where country_name='UK'
and country_id is null;
update oe.location_x
set country_id ='US'
where country_name='USA'
and country_id is null;

--untuk Austria, Finland, Ireland, Spain,dll
select distinct
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
end country_id, country_name, case when country_name = 'Venezuela' then 2 else 1 end region_id
from oe.location_x
where country_id is null

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
on hr.countries.country_id = src.country_id
when matched then
	update set region_id = src.region_id
when not matched then
insert (country_id,country_name,region_id) values (src.country_id,src.country_name,src.region_id);

select * from hr.countries
select * from oe.location_x where country_id is null

--update kembali setelah menambahkan negara ke hr
update oe.location_x as x
set country_id = (select country_id from hr.countries where upper(country_name) = upper(x.country_name))
where country_id is null

select * from oe.location_x where country_id is null

--7. insert table oe.location_x ke hr
select * from oe.location_x

alter table hr.locations
alter column street_address type varchar(60)

insert into hr.locations
select location_id,street_address,postal_code,city,state_province,country_id
from oe.location_x

--8.  Berikutnya kita akan tambahkan kolom location_id di table oe.customers dan create relasi one-to-many antara table hr.locations dengan oe.customers
alter table oe.customers
add column location_id integer;

select * from oe.customers;

alter table oe.customers
add constraint customer_location_fk Foreign Key (location_id) REFERENCES
hr.locations(location_id);

select * from oe.customers;

--9. insert value location_id pada table oe.customer berdasarkan oe.location_x
select * from oe.customers;
select * from oe.location_x;

update oe.customers as cu
set location_id = (select location_id from oe.location_x loc
where loc.street_address=cu.address and loc.postal_code=cu.postal_code
and loc.city=cu.city and loc.state_province=cu.region and
loc.country_name=cu.country
) where cu.location_id is null

select * from oe.customers oc where oc.location_id is not null;

select * from oe.orders;

