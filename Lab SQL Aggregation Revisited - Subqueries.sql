-- Lab | Aggregation Revisited - Subqueries

use sakila;

-- Write the SQL queries to answer the following questions:

-- Select the first name, last name, and email address of all the customers who have rented a movie.
SELECT 
    first_name, last_name, email
FROM
    customer
WHERE
    customer_id IN (
		SELECT 
			DISTINCT customer_id
        FROM
            rental);

-- What is the average payment made by each customer (display the customer id, customer name (concatenated), and the average payment made).
SELECT 
    customer_id, 
	CONCAT(first_name, last_name), 
    AVG(amount)
FROM
    customer
JOIN
    payment 
USING 
	(customer_id)
GROUP BY 
	customer_id;

-- Select the name and email address of all the customers who have rented the "Action" movies.
-- Write the query using multiple join statements
CREATE OR REPLACE VIEW joins AS
SELECT 
    first_name, last_name, email
FROM
    category
JOIN
    film_category
USING 
	(category_id)
JOIN
    inventory 
USING 
	(film_id)
JOIN
    rental
USING 
	(inventory_id)
JOIN
    customer
USING 
	(customer_id)
WHERE
    name = 'Action'
GROUP BY customer_id;
select * from joins;

-- Write the query using sub queries with multiple WHERE clause and IN condition
CREATE OR REPLACE VIEW where_in AS
SELECT 
    first_name, last_name, email
FROM
    customer
WHERE
    customer_id IN (
		SELECT 
            customer_id
        FROM
            rental
        WHERE
            inventory_id IN (
				SELECT 
                    inventory_id
                FROM
                    inventory
                WHERE
                    film_id IN (
						SELECT 
                            film_id
                        FROM
                            film_category
                        WHERE
                            category_id = (
								SELECT 
                                    category_id
                                FROM
                                    category
                                WHERE
                                    name = 'Action'))));
select * from where_in;

-- Verify if the above two queries produce the same results or not
SELECT * FROM joins
where (first_name, last_name, email) not in 
(select * from where_in)
UNION
SELECT * FROM where_in
where (first_name, last_name, email) not in 
(select * from joins);
# empty table so same results

-- Use the case statement to create a new column classifying existing columns as either or high value transactions based on the amount of payment. 
-- If the amount is between 0 and 2, label should be low and if the amount is between 2 and 4, the label should be medium, and if it is more than 4, then it should be high.
SELECT 
    *,
    CASE
        WHEN amount < 2 THEN 'low'
        WHEN amount > 4 THEN 'high'
        ELSE 'medium'
    END AS Classified
FROM
    payment;