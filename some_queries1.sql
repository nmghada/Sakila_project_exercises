USE sakila;
### Which actors have the first name ‘Scarlett’
SELECT * 
FROM actor
WHERE first_name = 'Scarlett';

### Which actors have the last name ‘Johansson’
SELECT *
FROM actor
WHERE last_name = 'Johansson';

### How many distinct actors last names are there?
SELECT COUNT(DISTINCT(last_name))
FROM actor;

#...#  Which last names are not repeated?
SELECT DISTINCT(last_name)
FROM actor;

select last_name from actor group by last_name having count(*) = 1;


### Which last names appear more than once?
SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name
HAVING COUNT(*) > 1;


### Which actor has appeared in the most films?
SELECT actor.actor_id, first_name, last_name, COUNT(film_actor.film_id) AS film_num
FROM actor 
JOIN film_actor ON film_actor.actor_id = actor.actor_id
GROUP BY film_actor.actor_id
ORDER BY film_num DESC
LIMIT 1; 

select actor.actor_id, actor.first_name, actor.last_name,
       count(actor_id) as film_count
from actor join film_actor using (actor_id)
group by actor_id
order by film_count desc
limit 1;   

#...# Is ‘Academy Dinosaur’ available for rent from Store 1?
SELECT film.film_id, inventory.inventory_id, film.title, 
	CASE WHEN inventory.store_id = 1 THEN 'Avaiable' ELSE 'Not Avaiable'
    END AS 'Availibility at Store 1'
FROM film
JOIN inventory ON inventory.film_id = film.film_id
WHERE film.title = 'Academy Dinosaur';

			#\! echo Step 1: which copies are at Store 1?

select film.film_id, film.title, store.store_id, inventory.inventory_id
from inventory 
join store using (store_id) 
join film using (film_id)
where film.title = 'Academy Dinosaur' and store.store_id = 1;

			#\! echo Step 2: pick an inventory_id to rent:

select rental.rental_id, inventory.inventory_id
from inventory 
	 join store using (store_id)
     join film using (film_id)
     join rental using (inventory_id)
where film.title = 'Academy Dinosaur'
      and store.store_id = 1
      and not exists (select * from rental
                      where rental.inventory_id = inventory.inventory_id
                      and rental.return_date is null);
                      


#...# Insert a record to represent Mary Smith renting ‘Academy Dinosaur’ from Mike Hillyer at Store 1 today .
insert into rental (rental_date, inventory_id, customer_id, staff_id)
values (NOW(), 1, 1, 1);

#...# When is ‘Academy Dinosaur’ due?

SELECT f.title, r.return_date
FROM rental AS r
JOIN inventory AS i ON r.inventory_id = i.inventory_id
JOIN film AS f ON f.film_id = i.film_id
WHERE f.title = 'Academy Dinosaur';



### What is that average running time of all the films in the sakila DB?
SELECT AVG(f.length)
FROM film AS f;

### What is the average running time of films by category?
SELECT c.name, fc.category_id, AVG(f.length) AS avg_length
FROM film AS f
JOIN film_category AS fc ON f.film_id = fc.film_id
JOIN category AS c ON c.category_id = fc.category_id
GROUP BY fc.category_id
ORDER BY avg_length DESC;

#Why does this query return the empty set? 
#select * from film natural join inventory;

# because it didnt specify what FK or PK these two tables are joining on.


SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_pay
FROM customer AS c
JOIN payment AS p ON p.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_pay DESC;

SELECT f.title, AVG(p.amount) AS revenue_per
FROM film AS f
JOIN inventory AS i ON i.film_id = f.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
JOIN payment AS p ON p.customer_id = r.customer_id
GROUP BY f.title
ORDER BY revenue_per DESC;