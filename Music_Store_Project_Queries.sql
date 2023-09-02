/* Q1: Who is the senior most employee based on job title? */

SELECT employee_id, first_name, last_name, title FROM employee
ORDER BY levels DESC
LIMIT 1;


/* Q2: Which countries have the most Invoices? */

SELECT billing_country,
COUNT(*) AS Total_invoices FROM invoice
GROUP BY 1
ORDER BY 2 DESC;



/* Q3: What are top 3 values of total invoice? */

SELECT ROUND(total::NUMERIC, 2) AS Total
FROM invoice
ORDER BY 1 DESC
LIMIT 3;


/* Q4: Which city has the best customers? We would like to throw a promotional 
Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city, ROUND(SUM(total)::NUMERIC, 2) AS money_made FROM invoice
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;



/* Q5: Who is the best customer? The customer who has spent the most money will be 
declared the best customer. 
Write a query that returns the person who has spent the most money.*/


SELECT c.customer_id, 
first_name, 
last_name, 
ROUND(SUM(total)::NUMERIC, 2) AS money_spend 
FROM customer c 
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY 1
ORDER BY 4 DESC
LIMIT 1;



/* Question Set 2 - Moderate */


/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */


SELECT DISTINCT c.email, 
c.first_name, 
c.last_name, 
g.name 
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY 1;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


SELECT a.artist_id, 
a.name, 
COUNT(a.artist_id) AS Number_of_Songs 
FROM artist a 
JOIN album al ON a.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;



/* Q3: Return all the track names that have a song length longer 
than the average song length. 
Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first. */

SELECT name, 
milliseconds 
FROM track WHERE milliseconds > (
SELECT AVG(milliseconds) FROM track)
ORDER BY 2 DESC;



/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */


WITH best_selling_artist AS (
	SELECT a.artist_id AS artist_id, 
	a.name AS artist_name, 
	SUM(il.unit_price * il.quantity) AS total_sales
	FROM invoice_line il
	JOIN track t ON t.track_id = il.track_id
	JOIN album al ON al.album_id = t.album_id
	JOIN artist a ON a.artist_id = al.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, 
c.first_name, 
c.last_name, 
bsa.artist_name, 
ROUND(SUM(il.unit_price*il.quantity)::NUMERIC,2) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = al.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;



/* Q2: We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


WITH Most_popular_genre as (
SELECT DISTINCT c.country, 
	g.name, 
	g.genre_id, 
	count(g.genre_id) as purchase,
ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(g.genre_id) DESC) AS RowNo  
from genre g 
join track t on g.genre_id = t.genre_id
join invoice_line il on t.track_id = il.track_id
join invoice i on il.invoice_id = i.invoice_id
join customer c on i.customer_id = c.customer_id
GROUP BY 1,2,3
ORDER BY 1)
SELECT * from Most_popular_genre where RowNo <=1;




/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customer_spending AS (
SELECT billing_country,
	c.customer_id, 
	c.first_name, 
	c.last_name, 
	ROUND(sum(total)::NUMERIC,2) as Amount_spent,
ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY sum(total) DESC) AS RowNo  
FROM customer c 
join invoice i ON c.customer_id = i.customer_id
GROUP BY 1,2,3,4
ORDER BY 1)
SELECT * from Customer_spending WHERE RowNo <= 1;