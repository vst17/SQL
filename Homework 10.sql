USE sakila;
/*Database changed*/

/* 1a.Display the first and last names of all actors from the table `actor*/ 
SELECT first_name, last_name FROM actor;

/* 1b. Display the first and last name of each actor in a single column in upper case letters. 
Name the column `Actor Name'*/

SELECT CONCAT(last_name,' ,', first_name) AS 'Actor Name' from actor ;

/* 2a. You need to find the ID number, first name, and last name of an actor,+
 of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information?*/

SELECT actor_id, first_name, last_name
FROM actor
where first_name = "Joe";

/*2b Find all actors whose last name contain the letters `GEN` */
SELECT last_name
FROM ACTOR
WHERE last_name like "%GEN%";

/* 2c. Find all actors whose last names contain the letters `LI`. 
This time, order the rows by last name and first name, in that order: */

SELECT last_name, first_name
FROM ACTOR
WHERE last_name like "%LI%"
ORDER BY last_name;

/* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
Afghanistan, Bangladesh, and China: */

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan','Bangladesh','China');


/* 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. 
Hint: you will need to specify the data type. */

-- data type of actors
DESCRIBE actor;

ALTER TABLE actor
ADD middle_name varchar(45) NOT NULL AFTER first_name;

select * from actor;

/* 3b.You realize that some of these actors have tremendously long last names. 
## Change the data type of the `middle_name` column to `blobs`.*/

ALTER TABLE actor
MODIFY middle_name BLOB NOT NULL;
-- to get the data type of the colums -- 
DESCRIBE actor;

/*3c. Now delete the `middle_name` column.*/

ALTER TABLE actor
DROP  middle_name;

DESCRIBE actor;

/* 4a. List the last names of actors, 
as well as how many actors have that last name. */

SELECT last_name, 
COUNT(*) AS 'Number of actors with last_name'
FROM actor 
GROUP BY last_name;

/*4b. Lis last name of actors and the number of actors who have that last name, 
but only for names that are shared by at least two actors. */

SELECT last_name, 
COUNT(*) AS COUNT
FROM actor
HAVING COUNT >=2;

/*4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, 
the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record */

set sql_safe_updates = 0;
UPDATE actor
SET first_name = REPLACE(first_name, 'GROUCHO','HARPO');

-- to check if its empty
SELECT * FROM actor
WHERE first_name = "GROUCHO";
-- to check the change
SELECT * FROM  actor
WHERE first_name = "HARPO";


/* 4d Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
It turns out that `GROUCHO` was the correct name after all! In a single query, 
if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. 
Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. 
BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, 
HOWEVER! (Hint: update the record using a unique identifier.) */

UPDATE actor
SET first_name = REPLACE(first_name, 'HARPO', 'GROUCHO');

SELECT * FROM actor
WHERE first_name = 'GROUCHO';

-- change the name to mucho groucho
/*UPDATE actor
SET first_name = REPLACE(first_name, 'MUCHO GROUCHO', 'GROUCHO')
WHERE last_name = "WILLIAMS";
UPDATE actor
SET first_name = REPLACE(first_name, 'GROUCHO', 'HARPO')
WHERE last_name = "WILLIAMS";*/

SELECT * FROM ACTOR
WHERE last_name = "WILLIAMS";


/* 5a. You cannot locate the schema of the `address` table. 
Which query would you use to re-create it? */

SHOW CREATE TABLE address;

/* 6a.  Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
Use the tables `staff` and `address`: */

SELECT s.first_name, s.last_name, a.address 
FROM staff AS s
LEFT JOIN address AS a
ON (s.address_id = a.address_id);

/* 6b. Use 'join  to display the total amount rung up by each staff member in August of 2005. 
Use tables `staff` and `payment`*/
-- to obtain the total amount for AUG 2005

SELECT CONCAT("$", FORMAT(SUM(amount),2))
AS Total
FROM payment
WHERE payment_date LIKE '2005-08%';

/* 6c. List each film and the number of actors who are listed for that film. 
Use tables `film_actor` and `film`. Use inner join.*/

SELECT f.title, COUNT(fa.actor_id) AS 'Number of Actors'
FROM film AS f
INNER JOIN film_actor AS fa
ON (f.film_id = fa.film_id)
GROUP BY f.film_id;

/*6d. How many copies of the film `Hunchback Impossible` exist in the inventory system? */

SELECT f.title, (
SELECT COUNT(*) FROM inventory AS i
WHERE f.film_id = i.film_id
) AS 'Number of Copies'
FROM film AS f
WHERE f.title = "Hunchback Impossible";

/* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
List the customers alphabetically by last name */

SELECT customer_id, SUM(amount) AS 'Total Paid'
FROM payment
GROUP BY customer_id;

/* Display all the customers alphabetically by last name*/
SELECT last_name, first_name, customer_id
FROM customer
ORDER BY last_name ASC;

/* To combine the two with 'JOIN' */

SELECT c.first_name, c.last_name, CONCAT("$", FORMAT(SUM(p.amount), 2)) AS 'Total Amount Paid'
FROM payment AS p
JOIN customer AS c
ON (p.customer_id = c.customer_id)
GROUP BY p.customer_id
ORDER BY c.last_name ASC;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
As an unintended consequence, films starting with the letters 'k' and 'Q' have also soared in popularity.
Use subqueries to display the titles or movies starting with the letters 'K' and 'Q' whose language is English*/

SELECT f.title
FROM film as f
WHERE f.language_id IN (
		SELECT l.language_id
        FROM language as l
WHERE f.title like 'K%' OR f.title like 'Q%' AND l.name = "English"
);

/* Use subqueries to display all actors who appear in the film 'Alone Trip'*/
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
		SELECT actor_id
        FROM film_actor
        WHERE film_id IN (
				SELECT film_id
                FROM film
				WHERE title = "Alone Trip")
                );
/*7c. You want to run an email marketing campaign in Canada, 
for which you will need the names and email addresses of all Canadian customers. 
Use joins to retrieve this information */

SELECT c.first_name, c.last_name, c.email, country.country
FROM address AS a
JOIN city
ON (city.city_id = a.city_id)
JOIN customer AS c
ON (c.address_id = a.address_id)
JOIN country
ON (country.country_id = city.country_id)
WHERE country.country = 'Canada';

/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films. */

SELECT f.title, c.name AS 'Type of film'
FROM category AS c
JOIN film_category as fc
ON (fc.category_id = c.category_id)
JOIN film as f
ON(f.film_id = fc.film_id)
WHERE c.name = "Family";

/*  7e. Display the most frequently rented movies in descending order. */

SELECT f.title, COUNT(f.title) AS 'Number_Rented'
FROM film AS f
JOIN inventory AS i 
ON(i.film_id = f.film_id)
JOIN rental AS r
ON (i.inventory_id = r.inventory_id)
GROUP BY f.title
ORDER BY COUNT(f.title) DESC;

/* List the top five genres in gross revenue in descending order. 
(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
SELECT cat.name AS 'Film Genre', CONCAT("$",FORMAT(SUM(p.amount),2)) AS 'Gross Revenue'
FROM category AS cat
JOIN film_category AS fc
ON(fc.category_id = cat.category_id)
JOIN inventory AS i
ON (i.film_id = fc.film_id)
JOIN rental AS r
ON(r.inventory_id = i.inventory_id)
JOIN payment AS p
ON(p.rental_id = r.rental_id)
GROUP BY cat.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

/* 8a.In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view. */

CREATE VIEW top_five_genres AS
SELECT cat.name AS 'Film Genre', CONCAT("$",FORMAT(SUM(p.amount),2)) AS 'Gross Revenue'
	FROM category AS cat
    JOIN film_category AS fc
    ON(fc.category_id = cat.category_id)
    JOIN inventory AS i
	ON (i.film_id = fc.film_id)
	JOIN rental AS r
	ON(r.inventory_id = i.inventory_id)
	JOIN payment AS p
	ON(p.rental_id = r.rental_id)
	GROUP BY cat.name
	ORDER BY SUM(p.amount) DESC
    LIMIT 5;
    
/*  8b. How would you display the view that you created in 8a? */
 SELECT * FROM top_five_genres;
 
/*8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it. */

DROP VIEW top_five_genres;
