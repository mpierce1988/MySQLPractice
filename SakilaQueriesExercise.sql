### MySQL Sakila Queries Practice
### https://datamastery.gitlab.io/exercises/sakila-queries.html

USE sakila;

# Select Actor with first name Scarlett
SELECT * FROM actor WHERE actor.first_name = 'Scarlett';

# Select Actor with last name Johansson
SELECT * FROM actor WHERE actor.last_name = 'Johansson';

# How many distinct actor last names?
SELECT DISTINCT COUNT(actor.last_name) FROM actor;

# Which last names are not repeated?
SELECT actor.last_name, COUNT(actor.last_name) AS num_names FROM actor GROUP BY actor.last_name HAVING num_names <= 1;

# Which last names appear more than once?
SELECT actor.last_name, COUNT(actor.last_name) AS num_names FROM actor GROUP BY actor.last_name HAVING num_names > 1;

# Which actor appeared in the most films?
# IN not supported, use inner join to replicate
SELECT a.* FROM actor a JOIN
(
SELECT film_actor.actor_id FROM film_actor GROUP BY film_actor.actor_id ORDER BY COUNT(film_actor.actor_id) DESC LIMIT 1
) fa ON a.actor_id = fa.actor_id;

# Is 'Academy Dinosaur' availble for rent from Store 1?
SELECT COUNT(*) >= 1 AS available_for_rent FROM inventory
JOIN (
SELECT film.film_id FROM film WHERE film.title LIKE '%Academy Dinosaur%'
) fi ON inventory.film_id = fi.film_id
WHERE inventory.store_id = 1;

# Insert a record to represent Mary Smith renting 'Academy Dinosaur' from Mike Hillyer at Store 1 today

SELECT film.film_id INTO @film_id FROM film WHERE film.title LIKE '%Academy Dinosaur%' LIMIT 1;

SELECT inventory.inventory_id INTO @inventory_id FROM inventory WHERE inventory.film_id = @film_id LIMIT 1;

SELECT staff.staff_id INTO @staff_id FROM staff WHERE staff.first_name = 'Mike' AND staff.last_name = 'Hillyer' LIMIT 1;

SELECT customer.customer_id INTO @customer_id FROM customer WHERE customer.first_name = 'Mary' AND customer.last_name = 'Smith' LIMIT 1;

-- INSERT INTO rental (rental_date, customer_id, inventory_id, return_date, staff_id)
-- VALUES ('2023-06-19', @customer_id, @inventory_id, NULL, @staff_id);

SELECT * FROM rental WHERE rental.staff_id = @staff_id AND rental.customer_id = @customer_id AND rental.inventory_id = @inventory_id;

# When is Academy Dinosaur due?
SELECT film.rental_duration INTO @rental_duration FROM film WHERE film.film_id = @film_id;

SELECT DATE_ADD(rental.rental_date, INTERVAL @rental_duration DAY) AS due_date FROM rental WHERE rental.staff_id = @staff_id AND rental.customer_id = @customer_id AND rental.inventory_id = @inventory_id;

# What is the average running time of all film in sakila db?