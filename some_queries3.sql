USE sakila;
/*Find the first films for each actor based on the release year of the movie. 
Display the records sorted by Release Year first and then by actor’s name alphabetically.*/

SELECT * FROM 
	(SELECT a.first_name, a.last_name, f.title, f.release_year, 
		ROW_NUMBER() OVER (PARTITION BY a.first_name, a.last_name ORDER BY release_year DESC) AS release_order
FROM actor AS a
JOIN film_actor AS fc ON fc.actor_id = a.actor_id
JOIN film AS f ON f.film_id = fc.film_id) AS A
WHERE release_order =1
ORDER BY release_year, a.first_name;

/* Find the “Favourite actor(s) of each store”: Find the actor(s) starring in the most rented 
movie in each month. Display the Actor Name, Store ID */

# STORE 1
SELECT a.actor_id, a.first_name, a.last_name
FROM actor AS a
JOIN film_actor AS fa ON fa.actor_id = a.actor_id
WHERE film_id IN
(	SELECT film_id
	FROM ( 
		SELECT * FROM
			(SELECT i.store_id, year(r.rental_date) AS year, month(r.rental_date) AS month, f.film_id, COUNT(title) AS 'count', 
			ROW_NUMBER() OVER(PARTITION BY i.store_id, year(r.rental_date), month(r.rental_date) ORDER BY COUNT(title) DESC) AS ra
			FROM inventory AS i
			JOIN rental AS r ON r.inventory_id = i.inventory_id
			JOIN film AS f ON f.film_id = i.film_id
			GROUP BY i.store_id, year, month, f.film_id) AS favor_movie_month
		WHERE ra = 1) AS a
	WHERE store_id = 1);

#STORE 2
SELECT a.actor_id, a.first_name, a.last_name
FROM actor AS a
JOIN film_actor AS fa ON fa.actor_id = a.actor_id
WHERE film_id IN
(	SELECT film_id
	FROM ( 
		SELECT * FROM
			(SELECT i.store_id, year(r.rental_date) AS year, month(r.rental_date) AS month, f.film_id, COUNT(title) AS 'count', 
			ROW_NUMBER() OVER(PARTITION BY i.store_id, year(r.rental_date), month(r.rental_date) ORDER BY COUNT(title) DESC) AS ra
			FROM inventory AS i
			JOIN rental AS r ON r.inventory_id = i.inventory_id
			JOIN film AS f ON f.film_id = i.film_id
			GROUP BY i.store_id, year, month, f.film_id) AS favor_movie_month
		WHERE ra = 1) AS a
	WHERE store_id = 2)
    ORDER BY actor_id;
    


