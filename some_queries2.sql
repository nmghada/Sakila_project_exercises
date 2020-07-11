use sakila;

# 1a. Display the first and last names of all actors from the table actor.

SELECT first_name, last_name
FROM actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. 
# Name the column Actor Name.

SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information? */

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE 'Joe';

# 2b. Find all actors whose last name contain the letters GEN:

SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE ('%GEN%');

/* 2c. Find all actors whose last names contain the letters LI. 
This time, order the rows by last name and first name, in that order: */

SELECT * 
FROM actor
WHERE UPPER(last_name) LIKE ('%LI%')
ORDER BY last_name, first_name;

/* 2d. Using IN, display the country_id and country columns of the following 
countries: Afghanistan, Bangladesh, and China:    */

SELECT *
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

/* 3a. You want to keep a description of each actor. You don't think you will be 
performing queries on a description, so create a column in the table actor named 
description and use the data type BLOB (Make sure to research the type BLOB, as the 
difference between it and VARCHAR are significant). */

ALTER TABLE actor
ADD COLUMN description TEXT;

/* 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
Delete the description column. */

ALTER TABLE actor
DROP COLUMN description;

# 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(*) AS num
FROM actor
GROUP BY last_name
ORDER BY num DESC;

/* 4b. List last names of actors and the number of actors who have that last name, 
but only for names that are shared by at least two actors. */

SELECT last_name, COUNT(*) AS num
FROM actor
GROUP BY last_name
HAVING num >= 2
ORDER BY num DESC, last_name ;

/* 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
Write a query to fix the record.	*/

UPDATE actor
SET first_name = 'HARPO', last_name = 'WILLIAMS'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

SELECT * 
FROM actor
WHERE last_name = 'WILLIAMS';

/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the 
correct name after all! In a single query, if the first name of the actor is currently HARPO, 
change it to GROUCHO.       */

UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

SELECT *
FROM actor
WHERE last_name = 'WILLIAMS';


# 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?


/* 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
Use the tables staff and address:     */

SELECT s.first_name, s.last_name, a.address, a.address2, a.district, a.city_id, c.city, a.postal_code, a.location
FROM staff AS s
JOIN address AS a ON a.address_id = s.address_id
JOIN city AS c ON c.city_id = a.city_id;

/* 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
Use tables staff and payment. */

SELECT s.staff_id, s.first_name, s.last_name, SUM(p.amount) AS amount
FROM staff AS s
JOIN payment AS p ON p.staff_id = s.staff_id
WHERE MONTH(p.payment_date) = 8
AND YEAR(p.payment_date) = 2005
GROUP BY s.staff_id;

/* 6c. List each film and the number of actors who are listed for that film. 
Use tables film_actor and film. Use inner join. */

SELECT f.film_id, f.title, COUNT(fa.actor_id) AS num_actors
FROM film as f
JOIN film_actor AS fa ON fa.film_id = f.film_id
GROUP BY f.film_id
ORDER BY num_actors DESC;

/* 6d. How many copies of the film Hunchback Impossible exist in the inventory system?*/

SELECT f.title, COUNT(i.film_id) AS num_films
FROM film AS f
JOIN inventory AS i ON i.film_id = f.film_id
GROUP BY i.film_id
HAVING f.title = 'Hunchback Impossible';

/* 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name:			*/

SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_payment
FROM customer AS c
JOIN payment AS p ON p.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY last_name;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.*/

SELECT f.title 
FROM film AS f
JOIN language AS l ON f.language_id = l.language_id
WHERE f.title IN 
	(SELECT f.title
	FROM film AS f 
    WHERE f.title LIKE 'K%' OR f.title LIKE 'Q%' ) 
AND l.name = 'English';

# 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT a.first_name, a.last_name
FROM actor AS a
WHERE a.actor_id IN 
	(SELECT fa.actor_id
    FROM film_actor AS fa
    WHERE fa.film_id in
		(SELECT film_id
        FROM film
        WHERE title = 'Alone Trip')
	);
    
/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names 
and email addresses of all Canadian customers. Use joins to retrieve this information. */

SELECT c.first_name, c.last_name, c.email
FROM customer AS c
JOIN address AS a ON a.address_id = c.address_id
WHERE a.city_id IN 
	(SELECT city_id
    FROM city
    WHERE country_id IN 
		(SELECT country_id
        FROM country
        WHERE LOWER(country) = LOWER('canada'))
        );
        
/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films. */

SELECT *
FROM film AS f
JOIN film_category as c ON c.film_id = f.film_id
WHERE c.category_id IN
	(SELECT category_id 
    FROM category
    WHERE LOWER(name) = LOWER('family'));
    
    
# 7e. Display the most frequently rented movies in descending order.

SELECT f.title, COUNT(r.rental_date) AS frequency
FROM film AS f
JOIN inventory AS i ON f.film_id = i.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY frequency DESC;

# 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT s.store_id, SUM(p.amount)
FROM store AS s 
JOIN payment AS p ON s.manager_staff_id = p.staff_id
GROUP BY s.store_id;

SELECT c.store_id, SUM(amount)
FROM payment AS p
JOIN customer AS c ON c.customer_id = p.customer_id 
GROUP BY c.store_id;

# 7g. Write a query to display for each store its store ID, city, and country.

SELECT s.store_id, a.address, c.city, co.country
FROM store AS s
JOIN address AS a ON a.address_id = s.address_id
JOIN city AS c ON c.city_id = a.city_id
JOIN country as co ON co.country_id = c.country_id;

/* 7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.) */

SELECT c.name, SUM(p.amount) AS gross_revenue
FROM category AS c
JOIN film_category AS fc ON fc.category_id = c.category_id
JOIN inventory AS i ON i.film_id = fc.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
JOIN payment AS p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY gross_revenue DESC
LIMIT 5;

/*
8a. In your new role as an executive, you would like to have an easy way of viewing the Top five 
genres by gross revenue. Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view.
*/

CREATE VIEW top5_category AS
SELECT c.name, SUM(p.amount) AS gross_revenue
FROM category AS c
JOIN film_category AS fc ON fc.category_id = c.category_id
JOIN inventory AS i ON i.film_id = fc.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
JOIN payment AS p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY gross_revenue DESC
LIMIT 5;

# 8b. How would you display the view that you created in 8a?
SELECT * 
FROM top5_category;

# 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top5_category;




    

