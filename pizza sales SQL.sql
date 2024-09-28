create database pizza;

use pizza;

select * from pizzas;

select * from pizza_types;

create table orders(
order_id int NOT NULL,
order_date datetime NOT NULL,
order_time time  NOT NULL,
primary key(order_id));

create table order_details(
order_details_id int NOT NULL,
order_id int NOT NULL,
pizza_id text NOT NULL,
quantity int  NOT NULL,
primary key(order_details_id));

select * from order_details;

select * from orders;

# Q1) find Total number of orders

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

# Q2) Total Revenue Generated

SELECT 
    COUNT(orders.order_id) AS Total_orders, ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
    JOIN
    orders ON orders.order_id = order_details.order_id;

# Q3) Highest priced pizza

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1;

# Q4) Most common pizza size ordered

SELECT 
    pizzas.size, COUNT(order_details.order_details_id) AS Qty
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY Qty DESC
LIMIT 1;

# Q5) top 5 most ordered pizza types along with their quantity

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS qty
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY qty DESC
LIMIT 5;

# Q6) total qty of each pizza category ordered

SELECT 
    pizza_types.category, SUM(order_details.quantity) AS qty
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY qty DESC;

# Q7) Distribution of Orders for every hour of the day 

SELECT 
    HOUR(order_time) AS Hour , COUNT(order_id) as No_of_Orders
FROM
    orders
GROUP BY HOUR(order_time);

# Q8) join tables to get category vise distribution of pizzas

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

----------------------------------------------------------------------------------------------------------------------

# Q9) group orders by date and calculate average number of pizzas ordered per day

SELECT 
    ROUND(AVG(qty), 0) as No_of_pizzas
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS qty
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_qty;

----------------------------------------------------------------------------------------------------------------------

# Q10) Top 3 most ordered pizza types in terms of revenue

SELECT 
    pizza_types.name as Pizza_Name,
    ROUND(SUM(order_details.quantity * pizzas.price),
            0) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

----------------------------------------------------------------------------------------------------------------------

# Q11) calculate percentage contribution of each pizza category to the total revenue

SELECT 
    pizza_types.category as Pizza_category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(order_details.quantity * pizzas.price)
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS percentage_revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;

----------------------------------------------------------------------------------------------------------------------

# Q12) cummative revenue generated over time

SELECT
	order_date, revenue, ROUND(SUM(revenue) OVER(ORDER BY order_date),2) AS cum_sum 
FROM
	(SELECT 
         orders.order_date, ROUND(SUM(order_details.quantity * pizzas.price),2) AS revenue 
	 FROM 
         order_details 
             JOIN 
		pizzas ON order_details.pizza_id = pizzas.pizza_id 
			 JOIN 
		orders ON order_details.order_id = orders.order_id 
	    GROUP BY orders.order_date) AS daily;

-------------------------------------------------------------------------------------------------------------------------------

# Q13) Which are the top 3 most ordered pizza types based on revenue for each pizza category ?

SELECT
    category AS Category, name AS Name, Revenue, Ranking
FROM
    (SELECT
            category, name, Revenue, RANK() OVER (PARTITION BY category ORDER BY Revenue DESC) AS Ranking
        FROM
            (SELECT
                    pizza_types.category, pizza_types.name, ROUND(SUM(order_details.quantity * pizzas.price), 2) AS Revenue
                FROM
                    pizza_types
                JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
                JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
                GROUP BY
                    pizza_types.category, pizza_types.name
            ) AS a
    ) AS b
WHERE
    Ranking <= 3;

