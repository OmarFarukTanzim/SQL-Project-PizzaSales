/*
SQL Case study project
*/

/*
Basic:
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.


Intermediate:
Join the necessary tables to find the total quantity of each pizza category ordered.
Determine the distribution of orders by hour of the day.
Join relevant tables to find the category-wise distribution of pizzas.
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue.

Advanced:
Calculate the percentage contribution of each pizza type to total revenue.
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category.

*/


-- Retrieve the total number of orders placed.

SELECT COUNT(DISTINCT Id) AS Total_Orders
FROM orders;

-- Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) AS 'Total Revenue'
FROM order_details 
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id;

-- Identify the highest-priced pizza.

SELECT  pizza_types.name AS 'Pizza Name' , pizzas.price
FROM pizzas 
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT pizzas.size, COUNT(DISTINCT Id) AS 'No of Orders', SUM(Quantity) AS 'Total Quantity Ordered' 
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY 'No of Orders' DESC;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT  pizza_types.name AS Pizza_Name, SUM(quantity) AS 'Total Ordered'
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name 
ORDER BY SUM(Quantity) DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT pizza_types.category,SUM(Quantity) AS Total_Quantity_Ordered
FROM order_details 
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY Total_Quantity_Ordered;

-- Determine the distribution of orders by hour of the day.

SELECT hour(order_time) AS Hour_Of_The_Day,count(DISTINCT Id) AS No_Of_Orders
FROM pizza_sales.orders
GROUP BY Hour_Of_The_Day
ORDER BY No_Of_Orders DESC;


-- Find the category-wise distribution of pizzas

select category, count(distinct pizza_type_id) as No_Of_Pizzas
from pizza_types
group by category
order by No_Of_Pizzas;

-- Calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(Total_Pizza_Ordered_that_day),0) AS Avg_Number_Of_Pizzas_Ordered_Per_Day FROM
  (
       SELECT orders.order_date AS Date, SUM(order_details.quantity) AS Total_Pizza_Ordered_that_day
	   FROM order_details
	   JOIN orders ON order_details.Id = orders.Id
       GROUP BY orders.order_date
  ) AS pizzas_ordered;
  
  -- Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name AS Pizza_Name,ROUND(SUM(order_details.Quantity*pizzas.price),2) AS Revenue
FROM order_details 
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY Pizza_Name
ORDER BY Revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenues

SELECT pizza_types.category, 
CONCAT(ROUND((SUM(order_details.quantity*pizzas.price) /
(SELECT SUM(order_details.quantity*pizzas.price) 
FROM order_details 
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id 
))*100,2), '%')
AS Revenue_contribution_from_pizza
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY  Revenue_contribution_from_pizza DESC;

-- Revenue contribution from each pizza by pizza name
SELECT pizza_types.name, 
CONCAT(ROUND((SUM(order_details.quantity*pizzas.price) /
(SELECT SUM(order_details.quantity*pizzas.price) 
FROM order_details 
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id 
))*100,2), '%')
AS Revenue_contribution_from_pizza
FROM order_details 
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Revenue_contribution_from_pizza DESC;

-- Analyze the cumulative revenue generated over time.

WITH cte AS (
SELECT order_date, ROUND(SUM(quantity*price),2) AS Revenue
from order_details 
join orders on order_details.Id = orders.Id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by order_date
ORDER BY Revenue
)
select order_date, Revenue,ROUND(sum(Revenue) over (order by order_date),2) as Cumulative_Sum
from cte 
group by order_date, Revenue;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with cte as (
SELECT category, name, ROUND(SUM(quantity*price),2) AS Revenue
FROM order_details 
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY category, name
ORDER BY category,Revenue DESC)
, cte1 AS (
SELECT category, name, Revenue,
RANK() OVER (PARTITION BY category ORDER BY Revenue DESC) AS rnk
FROM cte 
)
SELECT category, name, Revenue
FROM cte1 
WHERE rnk IN (1,2,3)
ORDER BY category, Revenue DESC


