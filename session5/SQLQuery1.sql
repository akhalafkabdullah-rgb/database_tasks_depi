
use StoreDB

--1.Write a query that classifies all products into price categories:

--Products under $300: "Economy"
--Products $300-$999: "Standard"
--Products $1000-$2499: "Premium"
--Products $2500 and above: "Luxury"

select product_name,list_price,
case 
when list_price<300 then 'Economy'
when list_price <1000 then 'Standard'
when list_price <2500 then 'Premium'
when list_price >=2500 then 'Luxury'
end as The_state

from production.products
order by list_price

--2.Create a query that shows order processing information with user-friendly status descriptions:

--Status 1: "Order Received"
--Status 2: "In Preparation"
--Status 3: "Order Cancelled"
--Status 4: "Order Delivered"
--Also add a priority level:

--Orders with status 1 older than 5 days: "URGENT"
--Orders with status 2 older than 3 days: "HIGH"
--All other orders: "NORMAL"


select order_id,order_status,order_date,DATEDIFF(day,order_date,getdate()) Days_late,
case
when  order_status=1 and DATEDIFF(day,order_date,getdate())>5 then 'Urgent'
when order_status=2 and DATEDIFF(day,order_date,getdate())>3 then 'High'
else 'Normal'
end as pririty_level
from sales.orders


--3.Write a query that categorizes staff based on the number of orders they've handled:

--0 orders: "New Staff"
--1-10 orders: "Junior Staff"
--11-25 orders: "Senior Staff"
--26+ orders: "Expert Staff"


select staff_id,COUNT(*) the_nm_of_orders_handeled ,

case 
when count(*) =0 then 'new'
when COUNT(*) <11 then 'junior'
when count(*)<26 then 'senior'
else 'expert'
end as the_state

from sales.orders

group by staff_id
order by count(*)

--4.Create a query that handles missing customer contact information:

--Use ISNULL to replace missing phone numbers with "Phone Not Available"
--Use COALESCE to create a preferred_contact field (phone first, then email, then "No Contact Method")
--Show complete customer information



select customer_id,first_name+' '+last_name full_name,ISNULL(phone,'No phone available') Phone,
coalesce(phone,email,'No contact found') contact_way 
from sales.customers


--7.Use a CTE to find customers who have spent more than $1,500 total:

--Create a CTE that calculates total spending per customer
--Join with customer information
--Show customer details and spending
--Order by total_spent descending


with total_paid as( select customer_id ,sum(oi.list_price*oi.quantity) total from sales.orders o join sales.order_items oi
on o.order_id=oi.order_id

group by customer_id)

select c.first_name+' '+c.last_name Full_name,phone,email,street,city,state,zip_code,tp.total
from sales.customers c join total_paid tp on c.customer_id=tp.customer_id
where tp.total>1500
order by tp.total desc


--8.Create a multi-CTE query for category analysis:

--CTE 1: Calculate total revenue per category
--CTE 2: Calculate average order value per category
--Main query: Combine both CTEs
--Use CASE to rate performance: >$50000 = "Excellent", >$20000 = "Good", else = "Needs Improvement"


with total_reven as(select category_id,sum(oi.list_price*oi.quantity) total,avg(oi.list_price*oi.quantity) average
from production.products p join sales.order_items oi
on p.product_id=oi.product_id group by category_id )
select c.category_id,c.category_name,tv.total,tv.average,

case 
when tv.total>50000 then 'Exc'
when tv.total >20000 then 'good'
else 'need improvement'
 
end as Evaluate
 from production.categories c right join total_reven tv on
c.category_id=tv.category_id
 order by total desc



-- 9.Use CTEs to analyze monthly sales trends:

--CTE 1: Calculate monthly sales totals
--CTE 2: Add previous month comparison
--Show growth percentage


WITH MonthlySales AS (
    SELECT 
        DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0) AS sales_month_date,
        SUM(i.quantity * i.list_price * (1 - i.discount)) AS current_month_total
    FROM sales.orders o
    JOIN sales.order_items i ON o.order_id = i.order_id
    GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, order_date), 0)
),
SalesComparison AS (
    SELECT 
        T1.sales_month_date,
        T1.current_month_total AS current_sales,
        T2.current_month_total AS previous_sales
    FROM MonthlySales T1
    LEFT JOIN MonthlySales T2 
        ON T2.sales_month_date = DATEADD(MONTH, -1, T1.sales_month_date)
)
SELECT 
    FORMAT(sales_month_date, 'yyyy-MM') AS [Month],
    ROUND(current_sales, 2) AS [Current Sales],
    ROUND(previous_sales, 2) AS [Previous Sales],
    CONCAT(
        ROUND(((current_sales - ISNULL(previous_sales, 0)) / NULLIF(previous_sales, 0)) * 100, 2), 
        '%'
    ) AS [Growth]
FROM SalesComparison
ORDER BY sales_month_date;

-- 10. Create a query that ranks products within each category:
WITH ProductRanks AS (
    SELECT 
        category_id,
        product_name,
        list_price,
        ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY list_price DESC) AS RowNum,
        RANK() OVER (PARTITION BY category_id ORDER BY list_price DESC) AS RankVal,
        DENSE_RANK() OVER (PARTITION BY category_id ORDER BY list_price DESC) AS DenseRankVal
    FROM production.products
)
SELECT * FROM ProductRanks WHERE RowNum <= 3;

GO

-- 11. Rank customers by their total spending:
WITH CustomerSpending AS (
    SELECT 
        c.customer_id,
        c.first_name + ' ' + c.last_name AS customer_name,
        SUM(i.quantity * i.list_price * (1 - i.discount)) AS total_spent
    FROM sales.customers c
    JOIN sales.orders o ON c.customer_id = o.customer_id
    JOIN sales.order_items i ON o.order_id = i.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name
),
CustomerGroups AS (
    SELECT *,
        RANK() OVER (ORDER BY total_spent DESC) AS SpendingRank,
        NTILE(5) OVER (ORDER BY total_spent DESC) AS Tile
    FROM CustomerSpending
)
SELECT *,
    CASE Tile
        WHEN 1 THEN 'VIP'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Silver'
        WHEN 4 THEN 'Bronze'
        WHEN 5 THEN 'Standard'
    END AS CustomerTier
FROM CustomerGroups;

GO

-- 12. Create a comprehensive store performance ranking:
WITH StoreStats AS (
    SELECT 
        s.store_name,
        SUM(i.quantity * i.list_price * (1 - i.discount)) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM sales.stores s
    LEFT JOIN sales.orders o ON s.store_id = o.store_id
    LEFT JOIN sales.order_items i ON o.order_id = i.order_id
    GROUP BY s.store_name
)
SELECT 
    store_name,
    RANK() OVER (ORDER BY total_revenue DESC) AS RevenueRank,
    RANK() OVER (ORDER BY total_orders DESC) AS OrderCountRank,
    CAST(PERCENT_RANK() OVER (ORDER BY total_revenue ASC) * 100 AS DECIMAL(10,2)) AS PercentilePerformance
FROM StoreStats;

GO

-- 13. Create a PIVOT table showing product counts by category and brand:
SELECT Category_Name, [Electra], [Haro], [Trek], [Surly]
FROM (
    SELECT c.category_name AS Category_Name, b.brand_name AS Brand_Name, p.product_id
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
    JOIN production.brands b ON p.brand_id = b.brand_id
) SourceTable
PIVOT (
    COUNT(product_id)
    FOR Brand_Name IN ([Electra], [Haro], [Trek], [Surly])
) AS PivotTable;

GO

-- 14. Create a PIVOT showing monthly sales revenue by store:
SELECT Store_Name, [Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec],
       ([Jan]+[Feb]+[Mar]+[Apr]+[May]+[Jun]+[Jul]+[Aug]+[Sep]+[Oct]+[Nov]+[Dec]) AS Total_Revenue
FROM (
    SELECT 
        s.store_name AS Store_Name, 
        LEFT(DATENAME(MONTH, o.order_date), 3) AS Order_Month,
        i.quantity * i.list_price * (1 - i.discount) AS Line_Total
    FROM sales.stores s
    JOIN sales.orders o ON s.store_id = o.store_id
    JOIN sales.order_items i ON o.order_id = i.order_id
) SourceTable
PIVOT (
    SUM(Line_Total)
    FOR Order_Month IN ([Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec])
) AS PivotTable;

GO

-- 15. PIVOT order statuses across stores:
SELECT Store_Name, [Pending], [Processing], [Completed], [Rejected]
FROM (
    SELECT 
        s.store_name AS Store_Name, 
        CASE o.order_status 
            WHEN 1 THEN 'Pending' WHEN 2 THEN 'Processing' 
            WHEN 3 THEN 'Rejected' WHEN 4 THEN 'Completed' 
        END AS Status_Name,
        o.order_id
    FROM sales.stores s
    JOIN sales.orders o ON s.store_id = o.store_id
) SourceTable
PIVOT (
    COUNT(order_id)
    FOR Status_Name IN ([Pending], [Processing], [Completed], [Rejected])
) AS PivotTable;

GO

-- 16. Create a PIVOT comparing sales across years:
WITH BrandSales AS (
    SELECT 
        b.brand_name, 
        YEAR(o.order_date) AS Order_Year,
        i.quantity * i.list_price * (1 - i.discount) AS Revenue
    FROM production.brands b
    JOIN production.products p ON b.brand_id = p.brand_id
    JOIN sales.order_items i ON p.product_id = i.product_id
    JOIN sales.orders o ON i.order_id = o.order_id
)
SELECT brand_name, [2016], [2017], [2018],
       ROUND((([2018] - [2017]) / NULLIF([2017], 0)) * 100, 2) AS Growth_17_18
FROM (SELECT brand_name, Order_Year, Revenue FROM BrandSales) AS SourceTable
PIVOT (SUM(Revenue) FOR Order_Year IN ([2016], [2017], [2018])) AS PivotTable;

GO

-- 17. Use UNION to combine different product availability statuses:
SELECT product_name, 'In-stock' AS Status FROM production.products WHERE product_id IN (SELECT product_id FROM production.stocks WHERE quantity > 0)
UNION
SELECT product_name, 'Out-of-stock' AS Status FROM production.products WHERE product_id IN (SELECT product_id FROM production.stocks WHERE quantity = 0 OR quantity IS NULL)
UNION
SELECT product_name, 'Discontinued' AS Status FROM production.products WHERE product_id NOT IN (SELECT product_id FROM production.stocks);

GO

-- 18. Use INTERSECT to find loyal customers:
SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2017
INTERSECT
SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2018;

GO

-- 19. Use multiple set operators to analyze product distribution:
(SELECT product_id, 'Available in All Stores' AS Label FROM production.stocks WHERE store_id = 1
 INTERSECT
 SELECT product_id, 'Available in All Stores' AS Label FROM production.stocks WHERE store_id = 2
 INTERSECT
 SELECT product_id, 'Available in All Stores' AS Label FROM production.stocks WHERE store_id = 3)
UNION
(SELECT product_id, 'Only Store 1 (Not 2)' FROM production.stocks WHERE store_id = 1
 EXCEPT
 SELECT product_id, 'Only Store 1 (Not 2)' FROM production.stocks WHERE store_id = 2);

GO

-- 20. Complex set operations for customer retention:
SELECT customer_id, 'Lost' AS CustomerStatus FROM sales.orders WHERE YEAR(order_date) = 2016
EXCEPT
SELECT customer_id, 'Lost' FROM sales.orders WHERE YEAR(order_date) = 2017
UNION ALL
SELECT customer_id, 'New' FROM sales.orders WHERE YEAR(order_date) = 2017
EXCEPT
SELECT customer_id, 'New' FROM sales.orders WHERE YEAR(order_date) = 2016
UNION ALL
SELECT customer_id, 'Retained' FROM sales.orders WHERE YEAR(order_date) = 2016
INTERSECT
SELECT customer_id, 'Retained' FROM sales.orders WHERE YEAR(order_date) = 2017;