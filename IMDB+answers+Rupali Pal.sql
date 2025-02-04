USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

select ROW_NUMBER() over() as num_rows
from genre
order by num_rows desc
limit 1;
-- genre: 14662

select ROW_NUMBER() over() as num_rows
from director_mapping
order by num_rows desc
limit 1;
-- director_mapping: 3867

select ROW_NUMBER() over() as num_rows
from movie
order by num_rows desc
limit 1;
-- movie: 7997

select ROW_NUMBER() over() as num_rows
from names
order by num_rows desc
limit 1;
-- names: 25735

select ROW_NUMBER() over() as num_rows
from ratings
order by num_rows desc
limit 1;
-- ratings: 7997

select ROW_NUMBER() over() as num_rows
from role_mapping
order by num_rows desc
limit 1;
-- role_mapping: 15615

-- Q2. Which columns in the movie table have null values?
-- Type your code below:

SELECT Sum(CASE
             WHEN id IS NULL THEN 1
             ELSE 0
           END) AS null_id,
       Sum(CASE
             WHEN title IS NULL THEN 1
             ELSE 0
           END) AS null_title,
       Sum(CASE
             WHEN year IS NULL THEN 1
             ELSE 0
           END) AS null_year,
       Sum(CASE
             WHEN date_published IS NULL THEN 1
             ELSE 0
           END) AS null_datepublished,
       Sum(CASE
             WHEN duration IS NULL THEN 1
             ELSE 0
           END) AS null_duration,
       Sum(CASE
             WHEN country IS NULL THEN 1
             ELSE 0
           END) AS null_country,
       Sum(CASE
             WHEN worlwide_gross_income IS NULL THEN 1
             ELSE 0
           END) AS null_grossincome,
       Sum(CASE
             WHEN languages IS NULL THEN 1
             ELSE 0
           END) AS null_lang,
       Sum(CASE
             WHEN production_company IS NULL THEN 1
             ELSE 0
           END) AS null_productionc
FROM   movie; 

-- null_country: 20
-- null_grossincome: 3724
-- null_lang: 194
-- null_productionc: 528


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT year,
       Count(year) AS num_of_movies
FROM   movie
GROUP  BY ( year );

SELECT Month(date_published)        AS month_num,
       Count(Month(date_published)) AS number_of_movies
FROM   movie
GROUP  BY Month(date_published)
ORDER  BY Count(Month(date_published)) DESC; 


/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT sum(2019_movie.num_films_produced) AS total
FROM  (
                SELECT   country,
                         count(country) AS num_films_produced
                FROM     movie
                WHERE    country regexp 'India|USA'
                AND      year = 2019
                GROUP BY country) 2019_movie;

-- 1059

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT( genre ) AS genre_present
FROM   genre; 

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT DISTINCT( year )
FROM   movie
ORDER  BY year DESC
LIMIT  1;

-- year: 2019
SELECT year,
       mg.genre,
       Count(genre) AS number_genre
FROM   (SELECT movie.*,
               genre.genre
        FROM   movie
               JOIN genre
                 ON movie.id = genre.movie_id) AS mg
WHERE  year = 2019
GROUP  BY genre
ORDER  BY number_genre DESC; 

-- Drama


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

CREATE VIEW jmg
AS
  SELECT movie.*,
         genre.genre
  FROM   movie
         JOIN genre
           ON movie.id = genre.movie_id;

SELECT Count(title) AS total
FROM   (SELECT title,
               genre,
               Row_number()
                 OVER(
                   partition BY title
                   ORDER BY genre) AS genre_num,
               CASE
                 WHEN Count(genre)
                        OVER(
                          partition BY title) > 1 THEN 'no'
                 ELSE 'yes'
               END                 AS single_genre
        FROM   jmg) single
WHERE  single_genre = 'yes'; 


/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT genre,
       Round(Avg(duration), 2) AS avg_duration
FROM   jmg
GROUP  BY genre
ORDER  BY Avg(duration) DESC; 

-- Action	112.88

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH cte1
     AS (SELECT genre,
                Count(title)                    AS movie_count,
                Rank()
                  OVER(
                    ORDER BY Count(title) DESC) AS genre_rank
         FROM   jmg
         GROUP  BY genre)
SELECT *
FROM   cte1
WHERE  genre = 'Thriller'; 

-- Thriller	1484	3

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT Min(avg_rating)    AS min_avg_rating,
       Max(avg_rating)    AS max_avg_rating,
       Min(total_votes)   AS min_total_votes,
       Max(total_votes)   AS max_total_votes,
       Min(median_rating) AS min_median_rating,
       Max(median_rating) AS max_median_rating
FROM   ratings; 

-- 1.0		10.0	100		725138		1		10

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

WITH cte2
     AS (SELECT m.title,
                r.avg_rating,
                Rank()
                  OVER(
                    ORDER BY avg_rating DESC) AS movie_rank,
                Row_number()
                  OVER(
                    ORDER BY avg_rating DESC) AS TOP
         FROM   movie m
                JOIN ratings r
                  ON m.id = r.movie_id)
SELECT title,
       avg_rating,
       movie_rank
FROM   cte2
WHERE  top <= 10; 

-- Kirket

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT median_rating,
       Count(movie_id) AS movie_count
FROM   ratings
GROUP  BY median_rating
ORDER  BY movie_count DESC; 


/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT *
FROM   (SELECT m.production_company,
               Count(m.title)                    AS movie_count,
               Rank()
                 OVER(
                   ORDER BY Count(m.title) DESC) AS prod_company_rank
        FROM   movie m
               JOIN ratings r
                 ON m.id = r.movie_id
        WHERE  r.avg_rating > 8
               AND production_company IS NOT NULL
        GROUP  BY m.production_company) rec
WHERE  prod_company_rank = 1; 

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:
+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT genre,
       Count(m.id) AS movie_count
FROM   movie m
       JOIN ratings r
         ON m.id = r.movie_id
       JOIN genre g using (movie_id)
WHERE  Month(m.date_published) = 3
       AND year = 2017
GROUP  BY genre
ORDER  BY movie_count DESC; 

-- Drama	176

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT m.title,
       r.avg_rating,
       genre
FROM   movie m
       JOIN ratings r
         ON m.id = r.movie_id
       JOIN genre g USING (movie_id)
WHERE  title REGEXP '^The'
ORDER  BY avg_rating DESC; 

-- The Brighton Miracle

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT Count(m.title) AS total_count
FROM   movie m
       JOIN ratings r
         ON m.id = r.movie_id
WHERE  date_published BETWEEN '2018-04-01' AND '2019-04-01'
       AND median_rating = 8; 

-- 361

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT CASE
         WHEN m.languages LIKE '%German%' THEN 'German'
         WHEN m.languages LIKE '%Italian%' THEN 'Italian'
         ELSE 'Other'
       END                AS language_category,
       Sum(r.total_votes) AS total_votes
FROM   movie m
       JOIN ratings r
         ON m.id = r.movie_id
WHERE  m.languages LIKE '%German%'
        OR m.languages LIKE '%Italian%'
GROUP  BY language_category; 


-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/


-- Segment 3:

-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT Sum(CASE
             WHEN id IS NULL THEN 1
             ELSE 0
           END) AS id_null,
       Sum(CASE
             WHEN NAME IS NULL THEN 1
             ELSE 0
           END) AS name_null,
       Sum(CASE
             WHEN height IS NULL THEN 1
             ELSE 0
           END) AS height_null,
       Sum(CASE
             WHEN date_of_birth IS NULL THEN 1
             ELSE 0
           END) AS dob_null,
       Sum(CASE
             WHEN known_for_movies IS NULL THEN 1
             ELSE 0
           END) AS known_movies_null
FROM   names; 


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:
+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
/*
select *
from (
	select movie_id, genre, avg_rating,
	count(movie_id) over(partition by genre order by count(movie_id) desc) as num_movie,
	row_number() over(partition by genre order by avg_rating desc) as rownum
    from (
		select *
		from (
			select *,
			rank() over(partition by genre order by count(movie_id) desc) as rnk
			from (
				select g.*, r.avg_rating
				from genre g join ratings r on g.movie_id = r.movie_id
				where r.avg_rating > 8 ) above_8
			where rnk < 3 ) top_3
		group by movie_id, genre
		order by num_movie desc ) count_movie
where rownum = 1;

Select director_name, count(name_id) as movie_count
from(
	select top_three.movie_id, name_id, name as director_name
	from (
		select *
		from(
			select *,
			count(movie_id) over(partition by genre order by count(movie_id) desc) as num_movie,
			row_number() over(partition by genre order by count(movie_id) desc) as rownum
			from (
				select g.*, r.avg_rating
				from genre g join ratings r on g.movie_id = r.movie_id
				where r.avg_rating > 8 and genre <> 'Others' 
				order by r.avg_rating desc) above_8
			group by movie_id, genre
			order by num_movie desc) summary
		where rownum = 1
		limit 3) top_three
	left join director_mapping d on top_three.movie_id = d.movie_id
	left join names n on n.id = d.name_id) mnd
left join movie m on m.id = mnd.movie_id
group by name_id


select genre, 
count(movie_id) as genre_count_movie
from
	(select g.*, r.avg_rating
	from genre g join ratings r on g.movie_id = r.movie_id
	where r.avg_rating > 8 and genre <> 'Others') start_info
group by genre
order by genre_count_movie desc


with cte4 as
	(with cte3 as (
		select d.name_id, d.movie_id, r.avg_rating
		from director_mapping d join ratings r on d.movie_id = r.movie_id
		where r.avg_rating > 8)
	select name_id 
	from (
		select name_id, genre, 
		row_number() over(partition by genre order by top_ranks) as num_directors,
		dense_rank() over(order by genre) as num_genre
		from(
			select genre, name_id, 
			dense_rank() over(order by movie_counts) as top_ranks
			from(
				select cte3.name_id, cte3.movie_id, genre,
				count(cte3.movie_id) over(partition by genre) as movie_counts
				from cte3 left join genre g on cte3.movie_id = g.movie_id
				where genre <> 'Others') genre_counts ) directors_id
		where top_ranks < 3) dir_name_id
	where num_directors = 1 and num_genre <= 3 ) 
select director_name, count(movie_id) as movie_count
from(
	select cte4.name_id, n.name as director_name, d.movie_id
	 from cte4 left join names n on n.id = cte4.name_id
	 join director_mapping d on cte4.name_id = d.name_id) all_info
group by director_name;
*/



WITH TopGenres AS (
    SELECT
        genre,
        COUNT(DISTINCT g.movie_id) AS num_movies
    FROM
        genre g
    JOIN
        ratings r ON g.movie_id = r.movie_id
    WHERE
        r.avg_rating > 8
    GROUP BY
        genre
    ORDER BY
        num_movies DESC
    LIMIT 3
)

SELECT
    n.name as director_name,
    COUNT(DISTINCT g.movie_id) AS movie_count
FROM
    director_mapping d
JOIN
	names n ON n.id = d.name_id
JOIN
    genre g ON d.movie_id = g.movie_id
JOIN
    ratings r ON g.movie_id = r.movie_id
JOIN
    TopGenres tg ON g.genre = tg.genre
WHERE
    r.avg_rating > 8
GROUP BY
    n.name
ORDER BY
    movie_count DESC
LIMIT 3;



/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT n.name            AS actor_name,
       Count(r.movie_id) AS movie_count
FROM   (SELECT movie_id,
               median_rating
        FROM   ratings
        WHERE  median_rating >= 8) mm
       LEFT JOIN role_mapping r
              ON mm.movie_id = r.movie_id
       LEFT JOIN names n
              ON n.id = r.name_id
GROUP  BY n.name
ORDER  BY movie_count DESC
LIMIT  2; 

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT   production_company,
         Sum(vote_count)                       AS vote_count,
         Rank() OVER(ORDER BY Sum(vote_count)) AS prod_comp_rank
FROM    (
                   SELECT    m.production_company,
                             r.movie_id,
                             r.total_votes AS vote_count
                   FROM      ratings r
                   LEFT JOIN movie m
                   ON        m.id = r.movie_id) pmv
GROUP BY production_company
ORDER BY vote_count DESC limit 3;

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT n.NAME                                                     AS actor_name,
       Sum(r.total_votes)                                         AS total_votes
       ,
       Count(m.id)                                                AS
       movie_count,
       Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) AS
       actor_avg_rating,
       Dense_rank()
         OVER(
           ORDER BY Count(m.id) DESC)                             AS actor_rank
FROM   movie m
       JOIN ratings r
         ON m.id = r.movie_id
       JOIN role_mapping rm
         ON rm.movie_id = m.id
       JOIN names n
         ON n.id = rm.name_id
WHERE  rm.category = 'actor'
       AND m.country LIKE '%India%'
GROUP  BY n.NAME
HAVING movie_count >= 5
ORDER  BY actor_avg_rating DESC; 


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


SELECT   n.NAME                                                     AS actress_name,
         Sum(r.total_votes)                                         AS total_votes,
         Count(m.id)                                                AS movie_count,
         Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) AS actor_avg_rating,
         Dense_rank() OVER(ORDER BY Count(m.id) DESC)               AS actor_rank
FROM     movie m
JOIN     ratings r
ON       m.id = r.movie_id
JOIN     role_mapping rm
ON       rm.movie_id = m.id
JOIN     names n
ON       n.id = rm.name_id
WHERE    rm.category = 'actress'
AND      m.country LIKE '%India%'
AND        languages LIKE '%HINDI%'
GROUP BY n.NAME
HAVING   movie_count >= 3
ORDER BY actor_avg_rating DESC limit 5;


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT classification,
       Count(title) AS numbers
FROM   (SELECT title,
               CASE
                 WHEN r.avg_rating > 8 THEN 'Superhit movies'
                 WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
                 WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
                 ELSE 'Flop movies'
               END AS classification
        FROM   movie m
               LEFT JOIN ratings r
                      ON m.id = r.movie_id
        WHERE  id IN (SELECT movie_id
                      FROM   genre
                      WHERE  genre = 'Thriller')) result
GROUP  BY classification; 

-- Hit movies	166; Flop movies	493; One-time-watch movies	786; Superhit movies	39

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


SELECT genre,
		ROUND(AVG(duration),2) AS avg_duration,
        SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
        AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

WITH cte7
     AS (SELECT m.id,
                m.title,
                m.year,
                m.worlwide_gross_income,
                g.genre
         FROM   movie m
                JOIN genre g
                  ON m.id = g.movie_id) SELECT *
FROM   (SELECT genre,
               year,
               worlwide_gross_income,
               title,
               Dense_rank()
                 OVER(
                   ORDER BY worlwide_gross_income DESC) inc
        FROM   cte7
        WHERE  id IN (SELECT id
                      FROM   (SELECT *
                              FROM   (SELECT *,
                                             Dense_rank()
                                               OVER(
                                                 ORDER BY num DESC) AS rnk
                                      FROM   (SELECT id,
                                                     genre,
                                                     Count(id)
                                                       OVER(
                                                         partition BY genre
                                                         ORDER BY Count(id)DESC)
                                                     AS num
                                              FROM   cte7
                                              WHERE  year = 2017
                                              GROUP  BY id,
                                                        genre
                                              ORDER  BY num DESC) m) n
                              WHERE  rnk <= 3) o)) q
WHERE  inc <= 5
UNION
SELECT *
FROM   (SELECT genre,
               year,
               worlwide_gross_income,
               title,
               Dense_rank()
                 OVER(
                   ORDER BY worlwide_gross_income DESC) inc
        FROM   cte7
        WHERE  id IN (SELECT id
                      FROM   (SELECT *
                              FROM   (SELECT *,
                                             Dense_rank()
                                               OVER(
                                                 ORDER BY num DESC) AS rnk
                                      FROM   (SELECT id,
                                                     genre,
                                                     Count(id)
                                                       OVER(
                                                         partition BY genre
                                                         ORDER BY Count(id)DESC)
                                                     AS num
                                              FROM   cte7
                                              WHERE  year = 2018
                                              GROUP  BY id,
                                                        genre
                                              ORDER  BY num DESC) m) n
                              WHERE  rnk <= 3) o)) q
WHERE  inc <= 5
UNION
SELECT *
FROM   (SELECT genre,
               year,
               worlwide_gross_income,
               title,
               Dense_rank()
                 OVER(
                   ORDER BY worlwide_gross_income DESC) inc
        FROM   cte7
        WHERE  id IN (SELECT id
                      FROM   (SELECT *
                              FROM   (SELECT *,
                                             Dense_rank()
                                               OVER(
                                                 ORDER BY num DESC) AS rnk
                                      FROM   (SELECT id,
                                                     genre,
                                                     Count(id)
                                                       OVER(
                                                         partition BY genre
                                                         ORDER BY Count(id)DESC)
                                                     AS num
                                              FROM   cte7
                                              WHERE  year = 2019
                                              GROUP  BY id,
                                                        genre
                                              ORDER  BY num DESC) m) n
                              WHERE  rnk <= 3) o)) q
WHERE  inc <= 5; 


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH MovieRatings AS (
    SELECT
        m.production_company,
        COUNT(r.median_rating) AS movie_count,
        DENSE_RANK() OVER (ORDER BY COUNT(r.median_rating) DESC) AS prod_comp_rank
    FROM
        movie m
    JOIN
        ratings r ON m.id = r.movie_id
    WHERE
        r.median_rating >= 8
        AND m.languages LIKE '%,%'
        AND m.production_company IS NOT NULL
    GROUP BY
        m.production_company
)

SELECT
    production_company,
    movie_count,
    prod_comp_rank
FROM
    MovieRatings
ORDER BY
    movie_count DESC
LIMIT 2;

-- Star Cinema; Twentieth Century Fox

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH TopActresses AS (
    SELECT
        n.name AS actress_name,
        SUM(r.total_votes) AS total_votes,
        COUNT(rm.movie_id) AS movie_count,
        ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes), 2) AS actress_avg_rating
    FROM
        role_mapping rm
    JOIN
        names n ON rm.name_id = n.id
    JOIN
        ratings r ON rm.movie_id = r.movie_id
    JOIN
        genre g ON rm.movie_id = g.movie_id
    WHERE
        rm.category = 'actress'
        AND r.avg_rating > 8
        AND g.genre = 'drama'
    GROUP BY
        n.name
)

SELECT
    actress_name,
    total_votes,
    movie_count,
    actress_avg_rating,
    RANK() OVER (ORDER BY movie_count DESC) AS actress_rank
FROM
    TopActresses
LIMIT 3;


-- Top 3 actresses based on number of Super Hit movies are Parvathy Thiruvothu, Susan Brown and Amanda Lawrence


/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH DirectorSummary AS (
    SELECT
        d.movie_id,
        d.name_id AS director_id,
        n.name AS director_name,
        r.avg_rating,
        r.total_votes,
        m.duration,
        m.date_published,
        LEAD(m.date_published, 1) OVER (PARTITION BY d.name_id ORDER BY m.date_published, d.movie_id) AS next_date
    FROM
        director_mapping d
    LEFT JOIN
        names n ON n.id = d.name_id
    LEFT JOIN
        ratings r ON r.movie_id = d.movie_id
    LEFT JOIN
        movie m ON m.id = d.movie_id
)

SELECT
    director_id,
    director_name,
    COUNT(movie_id) AS num_of_movies,
    AVG(avg_rating) AS avg_avg_rating,
    SUM(total_votes) AS total_votes,
    MIN(avg_rating) AS min_avg_rating, 
    MAX(avg_rating) AS max_avg_rating, 
    SUM(duration) AS total_duration,
    ROUND(AVG(DATEDIFF(next_date, date_published))) AS avg_inter_movie_days
FROM
    DirectorSummary
GROUP BY
    director_id, director_name
ORDER BY
    num_of_movies DESC
LIMIT 9;

-- Andrew Jones; A.L. Vijay; Sion Sono; Chris Stokes; Sam Liu; Steven Soderbergh; Jesse V. Johnson; Justin Price; Özgür Bakar