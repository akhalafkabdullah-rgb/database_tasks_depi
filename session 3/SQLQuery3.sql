--List all products with list price greater than 1000
select * from  production.products where list_price>1000


--Get customers from "CA" or "NY" states
select * from sales.customers where state in('CA','NY') 

--Retrieve all orders placed in 2023

select * from sales.orders where year(order_date)=2023 


--Show customers whose emails end with @gmail.com
select * from sales.customers where email like '%@gmail.com'

--Show all inactive staff
select * from sales.staffs where active =1

--List top 5 most expensive products
select top 5 product_name ,list_price from production.products order by list_price desc

--Show latest 10 orders sorted by date
select top 10 order_date from sales.orders order by order_date

--Retrieve the first 3 customers alphabetically by last name
select first_name +' '+last_name from sales.customers order by last_name


--Find customers who did not provide a phone number
select * from sales.customers where phone is null

--Show all staff who have a manager assigned
select * from sales.staffs where manager_id is not null

--Count number of products in each category
select category_id ,count(*) as The_number_of_catagories from production.products group by category_id  

--Count number of customers in each state
select state ,COUNT(*) from sales.customers group by state 


--Get average list price of products per brand
select brand_id ,avg(list_price) as the_avg_price from production.products group by brand_id 

--Show number of orders per staff
select staff_id ,sum(order_status) as the_sum from sales.orders group by  staff_id
--Find customers who made more than 2 orders
select customer_id ,count(*) as the_count_of_orders from sales.orders group by customer_id having count(*)>2
--Products priced between 500 and 1500
select product_name ,list_price from production.products where list_price between 500 and 1500 order by list_price
--Customers in cities starting with "S"
select first_name+' '+last_name from sales.customers where first_name like 'S%' 
--Orders with order_status either 2 or 4
select * from sales.orders where order_status in(2,4)
--Products from category_id IN (1, 2, 3)
select * from production.products where category_id in (1,2,3)

--Staff working in store_id = 1 OR without phone number
select * from sales.staffs where store_id=1 or phone is null 