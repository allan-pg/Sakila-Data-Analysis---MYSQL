use sakila;

/* 1) All films with PG-13 films with rental rate of 2.99 or lower */
SELECT *
FROM film
WHERE rating = 'PG-13' AND rental_rate <= 2.99;

SELECT *
FROM (
		SELECT *
        FROM film 
                ) x
WHERE x.rating = 'PG-13' AND x.rental_rate <= 2.99;

-- 2) All films that have deleted scenes
SELECT *
FROM film f 
WHERE f.special_features like '%Deleted Scenes%';

-- 3) All active customers
SELECT *
FROM customer c 
WHERE c.active = 1;

-- 4) Names of customers who rented a movie on 26th July 2005
SELECT concat(c.first_name, ' ', c.last_name) as full_name
FROM customer c
inner join rental r USING(customer_id)
WHERE r.rental_date like '2005-07-26%';

-- 5) Distinct names of customers who rented a movie on 26th July 2005
SELECT DISTINCT(concat(c.first_name, ' ', c.last_name)) as full_name
FROM customer c
inner join rental r USING(customer_id)
WHERE r.rental_date like '2005-07-26%';

-- 6) How many rentals we do on each day?
 
	select 
			date(rental_date),
			count(rental_id) as num_of_rentals
	from rental
	group by date(rental_date)
	order by num_of_rentals desc;



-- 7) All Sci-fi films in our catalogue
-- select * from category;
-- select * from film_category;
-- select * from film;


	SELECT f.film_id,
			f.title,
            f.release_year
	FROM film f
	INNER JOIN film_category fc USING(film_id)
	INNER JOIN category c USING(category_id)
    WHERE name = 'Sci-fi';


-- 8) Customers and how many movies they rented from us so far?
-- select * from customer;
WITH cte as (
	SELECT c.customer_id, 
		   c.first_name, 
		   count(c.customer_id) as number_of_movies
	FROM rental r
	INNER JOIN customer c USING(customer_id)
	GROUP BY c.customer_id
    )
    select *
    from cte;

WITH CTE as (
	SELECT *
	FROM (
		 SELECT c.customer_id, 
			   c.first_name, 
			   count(c.customer_id) as number_of_movies
			   -- ROW_NUMBER() over(PARTITION BY c.customer_id ORDER BY count(c.customer_id) desc)
		FROM rental r
		INNER JOIN customer c USING(customer_id)
		group by customer_id
    ) as x
)
select * from CTE; 

-- 9) Which movies should we discontinue from our catalogue (less than 2 lifetime rentals)

select  f.film_id,
        f.title,
        i.inventory_id,
		count(*) as lifetime_rentals
from rental r
inner join inventory i USING(inventory_id)
inner join film f USING(film_id)
group by i.inventory_id
HAVING count(*) < 2;




-- 10) Which movies are not returned yet?

SELECT *
FROM (
	SELECT f.film_id,
			f.title
	FROM rental r
	INNER JOIN inventory i USING(inventory_id)  
	INNER JOIN film f USING(film_id)
	WHERE return_date is null and rental_date is not null) AS x
   ;


-- H1) How many distinct last names we have in the data?

SELECT count(last_name) as num_of_customer
	from customer 
	WHERE last_name in (
			SELECT DISTINCT(last_name)
			FROM customer);


        

-- H2) How much money and rentals we make for Store 1 by day? 
 select * from inventory;
 
 
 select date(payment_date) as date,
			count(rental_id) as num_of_rentals,
			sum(amount) as money
FROM  payment
GROUP BY date(payment_date);
    
-- What are the three top earning days so far?
 select date(payment_date) as date,
			count(rental_id) as num_of_rentals,
			sum(amount) as money
FROM  payment
GROUP BY date(payment_date)
ORDER BY sum(amount) desc
limit 3;

-- number of movies acted by each actor
WITH cte AS (
SELECT * 
FROM (
	SELECT  a.actor_id,
			concat(a.first_name, ' ', a.last_name) as name,
			count(film_id) as num_movies
	FROM actor a
	INNER JOIN film_actor fa USING(actor_id)
	INNER JOIN film f USING(film_id)
	GROUP BY a.actor_id
    ORDER BY num_movies desc) as x
)
SELECT *
FROM cte;

-- Countries with highest number of customers (top 3)
SELECT *
FROM (
	SELECT c.country,
			count(cm.customer_id) as num_customer
	from country c
	inner join city ct USING(country_id)
	inner join address a USING(city_id)
	INNER JOIN customer cm USING(address_id)
	 GROUP BY c.country
     ORDER BY num_customer desc) as x;
     
-- Store that made the highest number of sales and by how much
WITH cte AS (
	select *
	FROM (
		SELECT s.store_id,
			   sum(p.amount) as amount
		FROM store s
		INNER JOIN staff st USING(store_id)
		INNER JOIN payment p USING(staff_id)
		GROUP BY s.store_id
		ORDER BY sum(p.amount) desc) as x
 )
 SELECT *
 FROM cte;