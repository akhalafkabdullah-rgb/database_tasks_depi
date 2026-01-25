--1. Count the total number of products in the database.

select count(*) as The_count from production.products

--2. Find the average, minimum, and maximum price of all products.
select AVG(list_price) as averg ,MIN(list_price) as min_price, max(list_price) as max_price  from production.products


--3. Count how many products are in each category.
select category_id ,COUNT(*) the_count from production.products group by category_id order by count(*)

--4. Find the total number of orders for each store.
select  store_id ,count(*) the_count   from sales.orders group by store_id

--5. Show customer first names in UPPERCASE and last names in lowercase for the first 10 customers.
select top 10 UPPER(first_name) first_name,LOWER(last_name) last_name from sales.customers 

--6. Get the length of each product name. Show product name and its length for the first 10 products.
select top 10 product_name  , len(product_name) the_length from production.products

--7. Format customer phone numbers to show only the area code (first 3 digits) for customers 1-15.
select top 15 LEFT(phone,3) as the_first_3 from sales.customers

--8. Show the current date and extract the year and month from order dates for orders 1-10.
select GETDATE()The_date
Select top 10 year(order_date) The_year, month(order_date)The_month from sales.orders 

--9. Join products with their categories. Show product name and category name for first 10 products.
select top 10 p.product_name,c.category_name from production.products p join production.categories c
on p.category_id =c.category_id 


--10. Join customers with their orders. Show customer name and order date for first 10 orders.
select o.order_date,c.first_name+' '+c.last_name the_name  from sales.orders o join sales.customers c
on o.customer_id =c.customer_id 


--11. Show all products with their brand names, even if some products don't have brands
--. Include product name, brand name (show 'No Brand' if null).
select p.product_name ,b.brand_name from production.products p left join production.brands b
on p.brand_id=b.brand_id 

--12. Find products that cost more than the average product price. Show product name and price.
select product_name ,list_price from production.products where list_price>(select avg(list_price) from production.products)

--13. Find customers who have placed at least one order. Use a subquery with IN. Show customer_id and customer_name.
select customer_id ,first_name+' '+last_name The_name from sales.customers
where customer_id in (select customer_id from sales.orders)

--14. For each customer, show their name and total number of orders using a subquery in the SELECT clause.

select c.customer_id ,c.first_name+' '+c.last_name The_name,
(select count(*) from sales.orders o where o.customer_id=c.customer_id)  as the_nm_of_orders
from sales.customers c
--another solution
select c.first_name,c.customer_id ,count(o.customer_id)  num_of_orders from sales.customers c  left join sales.orders o
on c.customer_id=o.customer_id group by c.customer_id,c.first_name


--15. Create a simple view called easy_product_list that shows product name, category name, and price. 
--Then write a query to select all products from this view where price > 100.
create view view_product as select p.product_name,p.category_id,c.category_name,p.list_price
from production.products p 
join production.categories c on c.category_id=p.category_id

select * from view_product where list_price>100


--16. Create a view called customer_info that shows customer ID, full name (first + last), email, and city and state combined.
--Then use this view to find all customers from California (CA).

create view customer_info as select customer_id,first_name+' '+last_name The_full_name,email,city,state
from sales.customers

select * from customer_info where city='California' and state='CA'

--17. Find all products that cost between $50 and $200. Show product name and price, ordered by price from lowest to highest.
select product_name,list_price from production.products where list_price between 50 and 200 order by list_price

--18. Count how many customers live in each state. Show state and customer count, ordered by count from highest to lowest.
select state,count(*) Num_of_customers from sales.customers group by state order by COUNT(*) desc

--19. Find the most expensive product in each category. Show category name, product name, and price.

	select 
    p.category_id, 
    p.product_name, 
    p.list_price,
	c.category_name
from production.products p
join production.categories c on c.category_id=p.category_id
where p.list_price = (
    select max(p2.list_price) 
    from production.products p2 
    where p2.category_id = p.category_id
)

--20. Show all stores and their cities, including the total number of orders from each store. Show store name, city, and order count.

select s.store_id,s.store_name,s.city,count(o.order_id) the_orders from sales.stores s join sales.orders o
on s.store_id=o.store_id group by s.store_id,s.store_name,s.city 



