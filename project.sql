 /**Question 1
We want to understand more about the movies that families are watching. 
The following categories are considered family movies:
Animation, Children, Classics, Comedy, Family and Music.
Create a query that lists each movie, the film category
it is classified in, and the number of times it has been rented out.
**/

select film.title, category.name, count(rental_id)
from film
join film_category
on film.film_id=  film_category.film_id

join category
on film_category.category_id= category.category_id

join inventory
on film.film_id= inventory.film_id

join rental
on inventory.inventory_id= rental.inventory_id

group by film.title,  category.name
having  category.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family' , 'Music')

order by 2

/** 
Question 2
Now we need to know how the length of rental duration of these family-friendly movies compares
to the duration that all movies are rented for. Can you provide a table with the movie titles and
divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) based 
on the quartiles (25%, 50%, 75%) of the rental duration for movies across all categories?
Make sure to also indicate the category that these family-friendly movies fall into.**/


select film.title, category.name, film.rental_duration,
ntile(4) over (order by film.rental_duration ) AS standard_quartile
from film
join film_category
on film.film_id=  film_category.film_id

join category
on film_category.category_id= category.category_id

where   category.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family' , 'Music')
order by 3 


/**
Question 3
Finally, provide a table with the family-friendly film category, each of the quartiles, 
and the corresponding count of movies within each combination of film category for 
each corresponding rental duration category. The resulting table should have three columns:

Category
Rental length category
Count
**/
select name, standard_quartile, count(*)
from
(select film.title, category.name as name , film.rental_duration,
ntile(4) over (order by film.rental_duration ) AS standard_quartile
from film
join film_category
on film.film_id=  film_category.film_id
join category
on film_category.category_id= category.category_id
where   category.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family' , 'Music')) t1
group by 1,2
order by 1,2

/**
Question 1:
We want to find out how the two stores compare in their count of rental orders during every month
for all the years we have data for. Write a query that returns the store ID for the store, 
the year and month and the number of rental orders each store has fulfilled for that month. 
Your table should include a column for each of the following: 
year, month, store ID and count of rental orders fulfilled during that month.**/


select  date_part('month',r.rental_date) rental_month, date_part('year',r.rental_date) rental_year,i.store_id, count(r.rental_id) count_rental
from  rental r
join inventory  i
on r.inventory_id= i.inventory_id
group by 1,2,3
order by 4 desc

/**
Question 2
We would like to know who were our top 10 paying customers, how many payments
they made on a monthly basis during 2007, and what was the amount of the monthly payments. 
Can you write a query to capture the customer name, month and year of payment, 
and total payment amount for each month by these top 10 paying customers?
**/

with t1 as 
	(select first_name|| ' '|| last_name as full_name, sum(amount) total_amount
	from customer c
	join payment p
	on c.customer_id = p.customer_id
	group by 1
	order by 2 desc
	limit 10),
	
	t2 as
	(select first_name|| ' '|| last_name as full_name, date_trunc('month',payment_date) pay_month, count(amount) pay_count_per_month , sum(amount) total
	from customer c
	join payment p
	on c.customer_id = p.customer_id
	where date_part('year',payment_date)=2007
	group by 1,2)

select t2.pay_month, t1.full_name,t2.pay_count_per_month, t2.total
from t2
join t1
on t2.full_name = t1.full_name


	
/**Question 3
Finally, for each of these top 10 paying customers, I would like to find out the difference across their 
monthly payments during 2007. Please go ahead and write a query to compare the payment amounts in each successive month.
Repeat this for each of these 10 paying customers. Also, it will be tremendously helpful
if you can identify the customer name who paid the most difference in terms of payments.
**/

with t1 as 
	(select first_name|| ' '|| last_name as full_name, sum(amount) total_amount
	from customer c
	join payment p
	on c.customer_id = p.customer_id
	group by 1
	order by 2 desc
	limit 10),
	
	t2 as
	(select first_name|| ' '|| last_name as full_name, date_trunc('month',payment_date) pay_month, count(amount) pay_count_per_month , sum(amount) total
	from customer c
	join payment p
	on c.customer_id = p.customer_id
	where date_part('year',payment_date)=2007
	group by 1,2),
	
	t3 as(
	select t2.pay_month, t1.full_name,t2.pay_count_per_month, t2.total, 
	lead(t2.total) over(partition by t1.full_name order by t2.pay_month) as Lead_amount, 
	(lead(t2.total) over(partition by t1.full_name order by t2.pay_month) - t2.total ) as difference
	from t2
	join t1
	on t2.full_name = t1.full_name)

select t3.*,
	case 
		when t3.difference= (select max(t3.difference) from t3) then 'Maximum diffeence'
	else NULL end as max

from t3







