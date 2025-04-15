-- Challange

/* Task 1 */
--1. Buat Schema
CREATE schema oe;

--2. Create All Object pake file sql

--3. Create permanent akses untuk All Object yang ada di schema OE.
SET search_path TO oe;
ALTER ROLE postgres SET search_path TO hr;

/* Task 2 */
--1. Tampilkan data category & total product-nya.
select
	c.category_id,
	c.category_name,
	count(1) as total_product
from categories c
join products p on c.category_id = p.category_id
group by c.category_id, c.category_name
order by c.category_id

--2.Tampilkan data supplier & total product-nya.
select
	s.supplier_id, 
	s.company_name,
	count(1) as total_product
from suppliers s
join products p on s.supplier_id = p.supplier_id
group by s.supplier_id, s.company_name
order by total_product desc;


--3. Tampilkan data supplier, total product dan harga rata-rata tiap product (gunakaan to_char() untuk menampilkan format avg_unit_price).
select
	s.supplier_id, 
	s.company_name,
	count(1) as total_product,
	to_char(avg(p.unit_price), '99.99') as avg_unit_price
from suppliers s
join products p on s.supplier_id = p.supplier_id
group by s.supplier_id
order by total_product desc

--4. Tampilkan data product yang harus pesan lagi ke supplier sesuai reorder-level nya. (soal Ambigu)
select * from products;
select * from suppliers;
select 
	p.product_id,
	p.product_name,
	p.supplier_id,
	s.company_name,
	p.unit_price,
	p.units_in_stock,
	p.units_on_order,
	p.reorder_level
from products p
join suppliers s on s.supplier_id = p.supplier_id
where p.units_in_stock <= p.reorder_level
order by p.product_name;

--5. Tampilkan data customer dan total order-nya
select
	cu.customer_id, 
	cu.company_name
	--count(1) as total_order
from customers cu
join orders o on cu.customer_id = o.customer_id
--group by cu.customer_id, cu.company_name
order by cu.customer_id;

--6. Tampilkan data order yang melebihi delivery time lebih dari 7 hari. (Belum selesai)
select
	order_id,
	customer_id,
	order_date,
	required_date,
	shipped_date,
	(shipped_date - order_date) as delivery_time
from orders
where (shipped_date - order_date) > 10;

--7. Tampilkan total product yang sudah di order dan urut berdasarkan total_quantity terbesar (beda)
select
	p.product_id, 
	p.product_name,
	sum(od.quantity) as total_qty
from products p
join order_details od on p.product_id = od.product_id
join orders o on o.order_id = od.order_id
where o.shipped_date is not null
group by 1
order by total_qty desc;


--8. Tampilkan total product yang sudah di order berdasarkan category
with sum_sold_cat as (
	select
		c.category_id, 
		c.category_name,
		sum(od.quantity) as total_qty_ordered
	from products p
	join categories c on p.category_id = c.category_id
	join order_details od on p.product_id = od.product_id
	join orders o on o.order_id = od.order_id
	where o.shipped_date is not null
	group by 1
	order by total_qty_ordered desc
)
select * from sum_sold_cat

--9. Mengacu ke soal no 8, tampilkan data category yang memiliki min & max total_qty_ordered
with sum_sold_cat as (
	select
		c.category_id, 
		c.category_name,
		sum(od.quantity) as total_qty_ordered
	from products p
	join categories c on p.category_id = c.category_id
	join order_details od on p.product_id = od.product_id
	join orders o on o.order_id = od.order_id
	where o.shipped_date is not null
	group by 1
	order by total_qty_ordered desc
)
select * from sum_sold_cat
where total_qty_ordered = (select min(total_qty_ordered) from sum_sold_cat) or  
	total_qty_ordered = (select max(total_qty_ordered) from sum_sold_cat)

--10. Tampilkan data shipper dan total qty product yang dikirim
--cara ke-1: pakai CTE
with prod_order as (
	select
		p.product_id, 
		p.product_name,
		od.order_id,
		sum(od.quantity) as total_qty_ordered
	from products p
	join order_details od on p.product_id = od.product_id
	group by od.order_id,p.product_id, p.product_name
),
ship_order as (
	select
		sh.shipper_id,
		sh.company_name,
		o.order_id
	from shippers sh
	join orders o on o.ship_via = sh.shipper_id
)
select 
	s.shipper_id,
	s.company_name,
	p.product_id,
	p.product_name,
	sum(p.total_qty_ordered) as total_qty_ordered
from ship_order s
join prod_order p on p.order_id = s.order_id
group by 1,2,3,4
order by s.company_name, p.product_name;

--cara ke-2: simple query
select s.shipper_id, s.company_name, p.product_id, p.product_name, sum(od.quantity) AS total_qty_ordered
from shippers s
join orders o on s.shipper_id = o.ship_via
join order_details od on o.order_id = od.order_id
join products p on od.product_id = p.product_id
group by s.shipper_id, s.company_name, p.product_id, p.product_name
order by s.company_name, p.product_name;

--11. Tampilkan data shipper dengan product yang paling sering dikirim dan paling minim dikirim
--cara 1: menggunakan multiple CTE
with combined as (
	select s.shipper_id, s.company_name, p.product_id, p.product_name, sum(od.quantity) as total_qty_ordered
	from shippers s
	join orders o on s.shipper_id = o.ship_via
	join order_details od on o.order_id = od.order_id
	join products p on od.product_id = p.product_id
	group by s.shipper_id, s.company_name, p.product_id, p.product_name
	order by s.company_name, p.product_name
),
min_max_per_shipper as (
	select
		shipper_id,
		min(total_qty_ordered) as min_qty,
		max(total_qty_ordered) as max_qty
	from combined
	group by shipper_id
)
select c.shipper_id, c.company_name, c.product_id, c.product_name, c.total_qty_ordered
from combined c
join min_max_per_shipper m on c.shipper_id = m.shipper_id
where c.total_qty_ordered = m.min_qty or c.total_qty_ordered = m.max_qty
order by c.shipper_id asc, c.total_qty_ordered asc;

--Cara ke-2: cte + rank dan partition 
with total_per_category AS (
select s.shipper_id, s.company_name, p.product_id, p.product_name, sum(od.quantity) AS total_qty_ordered
from shippers s
join orders o on s.shipper_id = o.ship_via
join order_details od on o.order_id = od.order_id
join products p on od.product_id = p.product_id
group by p.product_name, s.shipper_id, s.company_name, p.product_id),
ranked as (
  select *, rank() over (partition by company_name order by total_qty_ordered desc) as rank_max,
         rank() over (partition by company_name order by total_qty_ordered asc) as rank_min
  from total_per_category
)
select shipper_id, company_name, product_id, product_name, total_qty_ordered
from ranked
where rank_max = 1 or rank_min = 1
order by shipper_id, total_qty_ordered;

/* Challange Scheme HR */
--12. hirarki level employee
SET search_path TO hr;

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