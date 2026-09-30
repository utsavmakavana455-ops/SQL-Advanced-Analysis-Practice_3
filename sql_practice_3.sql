/*
 SQL Practice Questions 17–21

17. Customer Sales Contribution
Calculate each customer's total spending and their percentage contribution to the overall sales.

18. Previous Order Analysis
For each customer, display their current order amount, previous order amount, and the difference between the two orders.

19. Top Customer by City
Find the highest-spending customer in each city based on their total purchase amount.

20. Monthly Sales Report
Create a monthly sales report showing:

Total orders
Total units sold
Total sales
Average order value

21. Above-Average Product Revenue
Find all products whose total revenue is higher than the average revenue generated per product.
*/









#Question 17: Calculate each customer's percentage of total sales
SELECT
    customer_name,
    SUM(amount) AS total_spending,
    ROUND(
        SUM(amount) * 100.0 /
        (SELECT SUM(amount) FROM orders),
        2
    ) AS sales_percentage
FROM orders
GROUP BY customer_name
ORDER BY sales_percentage DESC;

# Question 18: Calculate the difference from the previous order
SELECT
    customer_name,
    order_date,
    amount,
    previous_amount,
    amount - previous_amount AS amount_difference
FROM (
    SELECT
        customer_name,
        order_date,
        amount,
        LAG(amount) OVER (
            PARTITION BY customer_name
            ORDER BY order_date, order_id
        ) AS previous_amount
    FROM orders
) AS customer_orders
ORDER BY customer_name, order_date;

#Question 19: Find the highest-spending customer in each city
SELECT
    city,
    customer_name,
    total_spending
FROM (
    SELECT
        city,
        customer_name,
        SUM(amount) AS total_spending,
        RANK() OVER (
            PARTITION BY city
            ORDER BY SUM(amount) DESC
        ) AS customer_rank
    FROM orders
    GROUP BY city, customer_name
) AS ranked_customers
WHERE customer_rank = 1
ORDER BY city;

# Question 20: Create a monthly sales report
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    COUNT(*) AS total_orders,
    SUM(quantity) AS total_units,
    ROUND(SUM(amount), 2) AS total_sales,
    ROUND(AVG(amount), 2) AS average_order_value
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_month;

#Question 21: Find products generating above-average revenue
SELECT
    product,
    SUM(amount) AS total_revenue
FROM orders
GROUP BY product
HAVING SUM(amount) > (
    SELECT AVG(product_revenue)
    FROM (
        SELECT SUM(amount) AS product_revenue
        FROM orders
        GROUP BY product
    ) AS product_sales
)
ORDER BY total_revenue DESC;
