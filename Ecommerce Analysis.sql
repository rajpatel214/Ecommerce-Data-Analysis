

select * from ecommerce_data ed 


#1 analysis type of shipping
select distinct shipping_type from ecommerce_data ed 

#2 max time to deliver product to customer 
select max(days_for_shipment_scheduled) num_of_day_to_delivery from ecommerce_data ed

#3 Anlysis the took time to delay product deliver
select max(days_for_shipment_real) max_time_for_delays  from ecommerce_data ed 

#4 Category of products name 
select distinct category_name from ecommerce_data ed 

#5 types of customer segments
select distinct customer_segment from ecommerce_data ed 

#6 total products order base on category of product  
select sum(order_quantity) as total_order,category_name from ecommerce_data ed group by 2

#7 here analysis Individual customers  More  
select count(*) type_of_customer,customer_segment from ecommerce_data ed group by 2 order by type_of_customer desc 

#8 California is the state where we generated max profit and most order book
with cte as (
select distinct customer_state,category_name,sum(order_quantity) total_order, round(sum(profit_per_order) ,2) total_profit from ecommerce_data ed 
group by 1,2 order by total_order desc )
,cte1 as (
select *,row_number() over(partition by category_name order by total_order desc) as top_product_category from cte) 
select * from cte1 where top_product_category =1;

#9 Wyoming is the state where we generated min profit and min order book
with cte as (
select distinct customer_state,category_name,sum(order_quantity) total_order, round(sum(profit_per_order) ,2) total_profit from ecommerce_data ed 
group by 1,2 order by total_order desc )
,cte1 as (
select *,row_number() over(partition by category_name order by total_order desc) as top_product_category from cte) 
select * from cte1 where top_product_category = 49;

#10 analys standard class mean regular Delivery option are  mostly canceled
select distinct shipping_type,delivery_status, sum(order_quantity) total_order from ecommerce_data ed 
where delivery_status in (select delivery_status from ecommerce_data ed  where delivery_status = 'Shipping Canceled')
group by 1,2 

#11 total 4,896 delivery canceled
select count(*) Total_order_canceled,delivery_status from ecommerce_data ed where delivery_status='Shipping Canceled' group by 2


#12 mostly delivery happen Late
select count(*) Total_order_canceled,delivery_status from ecommerce_data ed  group by 2

#13 How many days are dealys base on shipping types
select distinct shipping_type, max(days_for_shipment_real) delays_days from ecommerce_data ed 
group by 1

# 14 Sales and Profits base on Region 
select distinct customer_region,sum(order_quantity) total_product,sum(sales_per_order) total_sales,round(sum(profit_per_order),2) total_profit 
from ecommerce_data ed group by 1 order by total_product desc 

#15 Top 5 US Citys Where we generated more profit and sales (West Citys)
with cte as (
select distinct customer_region, customer_state, customer_city,
sum(order_quantity) total_order , sum(sales_per_order) total_sales,round(sum(profit_per_order),2) total_profit 
from ecommerce_data ed where customer_region = 'West'
group by 1,2,3 order by total_order desc )
,cte1 as(
select *, row_number() over(order by total_order desc) as rnk from cte)
select * from cte1 where rnk <=5

#16 Top 5 US Citys (East Citys) Where we generated more profit and sales 
with cte as (
select distinct customer_region, customer_state, customer_city,
sum(order_quantity) total_order , sum(sales_per_order) total_sales,round(sum(profit_per_order),2) total_profit 
from ecommerce_data ed where customer_region = 'East'
group by 1,2,3 order by total_order desc )
,cte1 as(
select *, row_number() over(order by total_order desc) as rnk from cte)
select * from cte1 where rnk <=5

#17 Top 5 US Citys (South Citys) Where we generated more profit and sales 
with cte as (
select distinct customer_region, customer_state, customer_city,
sum(order_quantity) total_order , sum(sales_per_order) total_sales,round(sum(profit_per_order),2) total_profit 
from ecommerce_data ed where customer_region = 'South'
group by 1,2,3 order by total_order desc )
,cte1 as(
select *, row_number() over(order by total_order desc) as rnk from cte)
select * from cte1 where rnk <=5

#18 Top 5 US Citys (Central Citys) Where we generated more profit and sales 
with cte as (
select distinct customer_region, customer_state, customer_city,
sum(order_quantity) total_order , sum(sales_per_order) total_sales,round(sum(profit_per_order),2) total_profit 
from ecommerce_data ed where customer_region = 'Central'
group by 1,2,3 order by total_order desc )
,cte1 as(
select *, row_number() over(order by total_order desc) as rnk from cte)
select * from cte1 where rnk <=5

select distinct customer_region,customer_country from ecommerce_data ed 

# 19 max_discount on category product 
select max(order_item_discount) max_discount,category_name from ecommerce_data ed group by 2
order by max_discount desc 

# 20 year range of order date and shiping date 
SELECT 
    MIN((STR_TO_DATE(order_date, '%d-%m-%Y'))) AS earliest_year, 
    MAX((STR_TO_DATE(order_date, '%d-%m-%Y'))) AS latest_year
FROM ecommerce_data ed;

SELECT 
    MIN((STR_TO_DATE(ship_date , '%d-%m-%Y'))) AS earliest_year, 
    MAX((STR_TO_DATE(ship_date , '%d-%m-%Y'))) AS latest_year
FROM ecommerce_data ed;

# 21 one day profit by each city and total orders 

with cte as (
select ed.*,STR_TO_DATE(order_date, '%d-%m-%Y') as new_order_date,
STR_TO_DATE(ship_date, '%d-%m-%Y') as new_ship_date
from ecommerce_data ed )
select customer_region, customer_state, customer_city,
sum(order_quantity) total_order , sum(sales_per_order) total_sales,round(sum(profit_per_order),2) total_profit
from cte where new_order_date = new_ship_date
group by 1,2,3 order by total_order desc 

#22 analysis which months we provided more discount with max profit and max sales 


select monthname(STR_TO_DATE(order_date, '%d-%m-%Y')) new_months,max(order_item_discount) max_discount ,
 sum(order_quantity) total_order , sum(sales_per_order) total_sales,round(sum(profit_per_order),0) total_profit
from ecommerce_data ed group by 1 order by total_sales desc ,max_discount desc , total_profit desc


#23 product list provided highest per of discount 

with new_discount as (
SELECT subquery.*,
CONCAT(ROUND(per_discount, 0), '%') AS per_discount1
FROM (
    SELECT ed.*, 
           ((order_item_discount / sales_per_order) * 100) AS per_discount
    FROM ecommerce_data ed
) AS subquery )
select * from new_discount where per_discount >= (select max(per_discount1) from new_discount )

#24 Write a query to identify customers with the highest lifetime sales.

select distinct customer_id ,customer_first_name, 
    customer_last_name,sum(sales_per_order) total_sales from ecommerce_data ed 
group by 1,2,3 order by total_sales desc limit 10;

#25 How can you identify customers who have placed orders in multiple regions?

SELECT 
    customer_id, 
    customer_first_name, 
    customer_last_name,count(*) num_placed_orders
FROM 
    ecommerce_data
GROUP BY 
    customer_id, customer_first_name, customer_last_name
HAVING 
    COUNT(DISTINCT customer_region) > 1;

#26 How can you calculate the percentage of orders delivered on time versus late delivery?

select 
    (SUM(CASE WHEN days_for_shipment_real <= days_for_shipment_scheduled THEN 1 ELSE 0 END) / COUNT(*) * 100) AS on_time_percentage,
    (SUM(CASE WHEN days_for_shipment_real > days_for_shipment_scheduled THEN 1 ELSE 0 END) / COUNT(*) * 100) AS late_percentage
FROM 
    ecommerce_data ed;

select CASE WHEN days_for_shipment_real <= days_for_shipment_scheduled THEN 1 ELSE 0 END
from ecommerce_data ed   

select * from ecommerce_data ed 

#27 How can you calculate the total discount given for orders with a profit margin above a certain threshold?
   
SELECT 
    SUM(order_item_discount) AS total_discount
FROM 
    ecommerce_data ed
WHERE 
    profit_per_order / sales_per_order > 0.20;  -- Threshold of 20% profit margin


