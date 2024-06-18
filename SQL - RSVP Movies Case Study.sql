USE imdb;

/* Now that we have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?


SELECT table_name,
       table_rows -- Finding the total number of rows in each table of our DB imdb
FROM   information_schema.tables
WHERE  table_schema = 'imdb'; 







-- Q2. Which columns in the movie table have null values?


-- Using case statement to find null count for each column in movie table
SELECT SUM(CASE
             WHEN id IS NULL THEN 1
             ELSE 0
           END) AS id_nulls,
		SUM(CASE
             WHEN title IS NULL THEN 1
             ELSE 0
           END) AS title_nulls,
		SUM(CASE
             WHEN year IS NULL THEN 1
             ELSE 0
           END) AS year_nulls,
		SUM(CASE
             WHEN date_published IS NULL THEN 1
             ELSE 0
           END) AS date_published_nulls,     
		SUM(CASE
             WHEN duration IS NULL THEN 1
             ELSE 0
           END) AS duration_nulls,
		SUM(CASE
             WHEN country IS NULL THEN 1
             ELSE 0
           END) AS country_nulls,   
		SUM(CASE
             WHEN worlwide_gross_income IS NULL THEN 1
             ELSE 0
           END) AS worlwide_gross_income_nulls,
		SUM(CASE
             WHEN languages IS NULL THEN 1
             ELSE 0
           END) AS languages_nulls,
		SUM(CASE
             WHEN production_company IS NULL THEN 1
             ELSE 0
           END) AS production_company_nulls
FROM   movie; 




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

-- Solution to first part of the question
SELECT year,
	   COUNT(DISTINCT id) as number_of_movies
FROM movie
GROUP BY year;

/*
OUTPUT
Year	Movies
2017	3052
2018	2944
2019	2001
*/

-- Solution to Second part of the question
SELECT MONTH(date_published) as month_num,
	   COUNT(DISTINCT id) as number_of_movies
FROM movie
GROUP BY month_num
ORDER BY number_of_movies DESC;  

/*
OUTPUT
3	824
9	809
1	804
10	801
4	680
8	678
2	640
5	625
11	625
6	580
7	493
12	438
*/



/*The highest number of movies is produced in the month of March.
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??

SELECT year,
       Count(id) AS number_of_movies_in_USA_India
FROM   movie
WHERE  (country LIKE '%USA%'
          OR country LIKE'%India%')
       AND year = 2019; 
       
/*
Output:
year	number_of_movies_in_USA_India
2019	1059
*/


/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 

-- Q5. Find the unique list of the genres present in the data set?

SELECT DISTINCT genre  -- finding the unique or distinct list of genre
FROM genre;

/*
OutPut:

Thriller
Fantasy
Drama
Comedy
Horror
Romance
Family
Adventure
Sci-Fi
Action
Mystery
Crime
Others
*/


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?

SELECT genre,
	   Count(movie_id) AS number_of_movies
FROM genre
GROUP BY genre
ORDER BY number_of_movies DESC
LIMIT 1;
                
/*
-- Drama genre has the most amount of movies produced
/*
OUTPUT:
Drama		4285
*/

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
 

-- Approach 1: Using With Clause
WITH movies_having_one_genre AS
(
	SELECT movie_id,
		COUNT(genre) AS number_of_genre
	FROM genre
	GROUP BY movie_id
	HAVING number_of_genre = 1
)
SELECT COUNT(*) AS number_of_movies_with_one_genre
FROM movies_having_one_genre;

-- Approach 2: Joining two table to get the actual movie and genre lists
SELECT M.id,
       M.title,
       Count(genre) AS Num_Of_Genre
FROM   movie M
       INNER JOIN genre G
               ON M.id = G.movie_id
GROUP  BY M.id,
          M.title
HAVING num_of_genre = 1 -- Filtering Movie belong to one genre
ORDER  BY id ASC; -- ordering Movie by Ud ascending order

/*
Total Records : 3289 (Pasting results here makes the file to read difficult)
Results : Refer Excel Spread sheet Sheet : Q7
*/


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
       ROUND(AVG(duration),2) AS Avg_Duration -- Avg Duration of the Movie
FROM   movie M
       INNER JOIN genre G
               ON M.id = G.movie_id -- Join two tables
GROUP  BY genre -- Combine by genre
ORDER  BY genre ASC; -- Ordering by genre ascending


/*
Output : 
Refer Excel Spread sheet Sheet : Q8
*/

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

WITH genre_rank AS
(
	SELECT genre, 
		   COUNT(movie_id) AS movie_count,
		   RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS genre_rank
	FROM genre
	GROUP BY genre
)
SELECT *
FROM genre_rank
WHERE genre='Thriller'; 

/*
Answer : 3
*/

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


SELECT MIN(avg_rating) AS min_avg_rating,
	   MAX(avg_rating) AS max_avg_rating,
       MIN(total_votes) AS min_total_votes,
       MAX(total_votes) AS max_total_votes,
       MIN(median_rating) AS min_median_rating,
       MAX(median_rating) AS max_median_rating
FROM ratings;   /* the minimum and maximum values in each column of the ratings table are in the expected range. This implies there are no outliers in the table. */

/*
OUTPUT :
min_avg_rating	max_avg_rating	min_total_votes	max_total_votes	min_median_rating	max_median_rating
1		10		100		725138		1			10

Results : Refer Excel Spread sheet Sheet : Q10
*/

    

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


WITH ratings_ranked AS
(
	SELECT  title,
			avg_rating,
			DENSE_RANK() OVER(window_rating) as movie_rank -- ranking movies by avg_rating
	FROM ratings AS r
	INNER JOIN movie AS m   -- joining ratings and movies tables
	ON r.movie_id= m.id
	WINDOW window_rating AS (ORDER BY avg_rating DESC) -- creating a window for ranking movies by avg_rating
)
SELECT * 
FROM ratings_ranked
WHERE movie_rank<=10;  -- SELECTING movies upto rank 10

/*
OutPut : total 14 rows

Results : Refer Excel Spread sheet Sheet : Q11
*/

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


SELECT median_rating,
	   COUNT(DISTINCT id) AS movie_count -- finding movies count for each rating
FROM ratings AS r 
INNER JOIN movie AS m -- joining ratings and movies tables
		ON r.movie_id= m.id
GROUP BY median_rating  -- grouping by rating
ORDER BY median_rating ASC;  -- movies with median rating 7 are the highest in number

/*
Output :
1	94
2	119
3	283
4	479
5	985
6	1975
7	2257
8	1030
9	429
10	346
*/

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/


WITH HIT_Movies AS  -- finding all hit movies and their production companies that have avg_rating higher than 8
(
	SELECT  production_company,   
			id,
			title,
			avg_rating
	FROM movie AS m   
	INNER JOIN ratings AS r      -- joining movies and ratings tables
	ON m.id = r.movie_id
	WHERE avg_rating > 8  -- a movie is considered a hit if it has an avg_rating>8
	AND production_company IS NOT NULL
)
SELECT  production_company,
		COUNT(DISTINCT id) as movie_count,      -- count of hit movies produced by each production house
        DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT id) DESC) as prod_company_rank  -- ranking production companies by the number of hit movies they produced
FROM HIT_Movies
GROUP BY production_company
ORDER BY movie_count DESC;    

/*
-- Answer :Dream Warrior Pictures or National Theatre Live , Rank 1 


-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */


WITH movies_usa AS
(
	SELECT    id, -- filters all movies released in March 2017 in USA and total votes greater than 1000
			  year,
			  date_published,
			  country,
			  genre,
			  total_votes
	FROM       movie AS m
	INNER JOIN genre AS g
	ON         m.id= g.movie_id -- joining movie and genre tables
	INNER JOIN ratings AS r     -- now joining with ratings table
	ON         m.id= r.movie_id
	WHERE      year= 2017
	AND        country regexp 'USA'
	AND        total_votes>1000
	AND        MONTH(date_published)=3 
)
SELECT   genre,
         COUNT(id) AS movie_count -- count of movies per genre
FROM     movies_usa
GROUP BY genre
ORDER BY movie_count DESC;            

/*
--OutPut : Drama genre has the highest number of movies produced during March 2017 in USA more than 1000 votes =24
*/


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


SELECT title,
       avg_rating,
       genre
FROM   movie AS m
       INNER JOIN genre AS g
               ON m.id = g.movie_id -- joining movie and genre tables
       INNER JOIN ratings AS r -- now joining with ratings table
               ON m.id = r.movie_id
WHERE  title LIKE 'The%'
       AND avg_rating > 8 -- filtering movies that start with 'The' and has average rating > 8
ORDER  BY genre; -- ordering by genre

/*
--OUTPUT : Total Row 15




-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT COUNT(DISTINCT id) AS movie_count -- count of movies
FROM   movie AS m
INNER JOIN ratings AS r -- joining movies and ratings tables
		ON m.id = r.movie_id
WHERE  (date_published BETWEEN '2018-04-01' AND '2019-04-01')
       AND median_rating = 8; -- filtering for movies released between 1 April 2018 and 1 April 2019 that were given a median rating of 8        

-- Answer : Total 361 Movies were given median rating as 8 between the period 1 April 2018 and 1 April 2019

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

-- Approach 1: By Language

WITH German_movie_votes AS
(
SELECT languages,
	   SUM(total_votes) AS total_votes
FROM movie
INNER JOIN ratings
ON movie.id = ratings.movie_id
WHERE languages LIKE '%German%'
GROUP BY languages
)
,
Italian_movie_votes AS
(
SELECT languages,
	   SUM(total_votes) AS total_votes
FROM movie
INNER JOIN ratings
ON movie.id = ratings.movie_id
WHERE languages LIKE '%Italian%'
GROUP BY languages
)
SELECT  (SELECT SUM(total_votes)
		FROM German_movie_votes) AS German_votes,
		(SELECT SUM(total_votes)
		FROM Italian_movie_votes) AS Italian_votes;        

/*
Output 1:
German_votes	Italian_votes
4421525	2559540
*/

-- Approach 2: By Country
SELECT country,
       Sum(total_votes) AS votes_count -- count of German movies
FROM   movie AS m
       INNER JOIN ratings AS r -- joining movies and ratings tables
               ON m.id = r.movie_id
WHERE  country IN ( 'Germany', 'Italy' )
GROUP  BY country; -- Grouping by Country

/* 
OutPut 2:
Germany		106710
Italy		77965
*/

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

SELECT SUM(CASE
             WHEN NAME IS NULL THEN 1
             ELSE 0
           END) AS name_nulls, -- Using case statement to find null count for name
       SUM(CASE
             WHEN height IS NULL THEN 1
             ELSE 0
           END) AS height_nulls, -- Using case statement to find null count for height
       SUM(CASE
             WHEN date_of_birth IS NULL THEN 1
             ELSE 0
           END) AS date_of_birth_nulls, -- Using case statement to find null count for date of birth
       SUM(CASE
             WHEN known_for_movies IS NULL THEN 1
             ELSE 0
           END) AS known_for_movies_nulls -- Using case statement to find null count for Know for Movies    
FROM   names; 

/* OUTPUT:
name_nulls	height_nulls	date_of_birth_nulls	known_for_movies_nulls
0	17335	13431	15226
*/

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


WITH top_genre AS
(
	SELECT     g.genre,
			   COUNT(g.movie_id) AS movie_count
	FROM       genre             AS g
	INNER JOIN ratings           AS r
	ON         g.movie_id = r.movie_id
	WHERE      avg_rating > 8
	GROUP BY   genre
	ORDER BY   movie_count DESC 
    LIMIT 3 
), 
top_director AS
(
	SELECT     n.name                                             AS director_name,
			   COUNT(g.movie_id)                                  AS movie_count,
			   ROW_NUMBER() OVER(ORDER BY Count(g.movie_id) DESC) AS director_row_rank
	FROM       names                                              AS n
	INNER JOIN director_mapping                                   AS dm
	ON         n.id = dm.name_id
	INNER JOIN genre AS g
	ON         dm.movie_id = g.movie_id
	INNER JOIN ratings AS r
	ON         r.movie_id = g.movie_id,
			   top_genre
	WHERE      g.genre IN (top_genre.genre)
	AND        avg_rating > 8
	GROUP BY   director_name
	ORDER BY   movie_count DESC 
)
SELECT *
FROM   top_director
WHERE  director_row_rank <= 3 
LIMIT 3;

/*
--OUTPUT:
director_name	movie_count	director_row_rank
James Mangold	4	1
Soubin Shahir	3	2
Joe Russo		3	3
*/

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


WITH actors AS   -- finding all actors whose movies that have median rating higher than or equal to 8
( 
	SELECT     n.NAME AS actor_name,
			   rm.name_id,
			   rm.movie_id,
			   r.median_rating
	FROM       role_mapping AS rm
	INNER JOIN names        AS n    -- joinig role_mapping with names table to get the names of the actors
	ON         rm.name_id = n.id
	INNER JOIN ratings AS r         -- joining ratings table as well to get the median rating values
	ON         rm.movie_id = r.movie_id
	WHERE      category = 'actor'
	AND        median_rating >= 8   -- filtering by all actors whose movies that have median rating higher than or equal to 8
)
SELECT   actor_name,
         Count(DISTINCT movie_id) AS movie_count -- movie count
FROM     actors
GROUP BY actor_name
ORDER BY movie_count DESC  -- ordering the top 2 actors who made the most movies with median rating >=8
LIMIT 2;                   -- limiting to top 2 actors
         
-- OUTPUT
-- Mammootty = 8
-- Mohanlal = 5 are the two top actors

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

-- ranking production houses by the total votes received
SELECT * 
FROM   (                                                  
		SELECT m.production_company,
			   SUM(r.total_votes)                    AS votes_count,      -- sum of total votes per production house
			   ROW_NUMBER()
				OVER(ORDER BY Sum(r.total_votes) DESC) AS prod_comp_rank  -- rank of each production house in terms of total votes received
		FROM   movie AS m
			   INNER JOIN ratings AS r                                    -- joining ratings table to get the total votes
					   ON m.id = r.movie_id
		GROUP  BY production_company                                      -- grouping by production house 
		ORDER  BY votes_count DESC                                        -- ordering by total votes received
		) TOP_Production_By_votes
WHERE  prod_comp_rank <= 3;                                           -- filtering the top 3 production houses in terms of total votes received

/*
OutPut:
Marvel Studio is the 1st prodctuion company based on number of votes received by movies
Twentieth Century Fox is the 2nd prodctuion company based on number of votes received by movies
Warner Bros is the 3rd prodctuion company based on number of votes received by movies
production_company 	votes_count 	prod_comp_rank  
Marvel Studios			2656967			1
Twentieth Century Fox	2411163			2
Warner Bros.			2396057			3
*/


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?


/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

DROP VIEW IF EXISTS ACTORS;        -- Drop Actor VIEW if exists in Database
DROP VIEW IF EXISTS movies_India;  -- Drop movies_India VIEW if exists in Database

CREATE VIEW actors AS              -- This table will for store details of actors
SELECT     *
FROM       role_mapping AS rm
INNER JOIN names        AS n
ON         rm.name_id= n.id
WHERE      category='actor';

CREATE VIEW movies_india AS         -- This table will store details of movies in India
SELECT *
FROM   movie
WHERE  country IN ('India');

SELECT     a.NAME                                                   					AS actor_name,
           SUM(r.total_votes)                                      						AS total_votes,
           COUNT(DISTINCT a.movie_id)                               					AS movie_count,
           (SUM(r.avg_rating* r.total_votes)/SUM(r.total_votes))    					AS actor_avg_rating, -- finding weighted average rating for each actor using total votes as weight
           RANK() 
			OVER(ORDER BY (SUM(r.avg_rating* r.total_votes)/SUM(r.total_votes)) DESC) 	AS actor_rank        
FROM       actors               AS a
INNER JOIN movies_india         AS mi -- joining the view ACTORS with the view movies_India
ON         a.movie_id = mi.id
INNER JOIN ratings AS r               -- joining ratings
ON         a.movie_id = r.movie_id
GROUP BY   actor_name                 -- grouping by actor
HAVING     movie_count >= 5 
LIMIT 1;

/*
NOTE: We can create TEMP tables as weel to store actor and Movies in India values instead creating Views
OUtput:
actor_name		total_votes	movie_count	actor_avg_rating 	actor_rank 
Vijay Sethupathi	23114		5		8.41673012		1

Answer : Vijay Sethupathi
*/

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

DROP VIEW IF EXISTS ACTRESSES;          -- Drop ACTRESSES VIEW if exists in Database
DROP VIEW IF EXISTS hindi_movies_India; -- Drop hindi_movies_India VIEW if exists in Database

CREATE VIEW ACTRESSES AS                -- This view will store details of ACTRESSES
SELECT *
FROM role_mapping AS rm
INNER JOIN names AS n
ON rm.name_id= n.id
WHERE category='actress';

CREATE VIEW hindi_movies_India AS       -- This view store details of hindi movies in India
SELECT *
FROM movie
WHERE country='India' and languages='Hindi';  -- filtering movies by country India and languages Hindi

SELECT     a.NAME                                                 AS actress_name,
           SUM(r.total_votes)                                     AS total_votes,
           COUNT(DISTINCT a.movie_id)                             AS movie_count,
           (SUM(r.avg_rating* r.total_votes)/SUM(r.total_votes))  AS actress_avg_rating, -- finding weighted average rating for each actress using total votes as weight
           DENSE_RANK() 
			OVER(ORDER BY (SUM(r.avg_rating* r.total_votes)/SUM(r.total_votes)) DESC) AS actress_rank 
FROM       actresses            AS a
INNER JOIN hindi_movies_india   AS mi -- joining the view ACTRESSES with the view hindi_movies_India
ON         a.movie_id= mi.id
INNER JOIN ratings              AS r  -- joining ratings
ON         a.movie_id= r.movie_id
GROUP BY   actress_name               -- grouping by actresses
HAVING     movie_count>=3 
LIMIT 5;    						  -- limit to top 5 actresses

/*
NOTE: 
We can create TEMP tables as weel to store actor and Movies in India values instead creating Views
The data have only 4 Actress who are top five actresses acted in Hindi movies atleast in three Indian movies released in India based on their average ratings

OUtput:
actress_name	total_votes	movie_count	actress_avg_rating	actress_rank
Taapsee Pannu	18061		3		7.736919329		1
Divya Dutta	8579		3		6.884403777		2
Kriti Kharbanda	2549		3		4.803138486		3
Sonakshi Sinha	4025		4		4.181242236		4
*/


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/


WITH thriller_movies AS 
(
SELECT DISTINCT title,
                genre,
				avg_rating
         FROM   movie AS m
                INNER JOIN ratings AS r      -- joining movie and ratings tables
                        ON r.movie_id = m.id
                INNER JOIN genre AS g        -- joining genre table
						USING (movie_id)
         WHERE  genre = 'Thriller'        -- filtering by thriller movies
)
SELECT *,
       CASE                                  -- classifying the movies into different categories based on their avg_rating
         WHEN avg_rating > 8 THEN 'Superhit movies'
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         ELSE 'Flop movies'
       END AS avg_rating_category
FROM   thriller_movies; 
                         

/*
OUTPUT:
Total Rows : 1482



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

WITH avg_duration_per_genre AS
(                                                                                    -- finding the avg_duration per genre
	SELECT     genre,
			   AVG(duration) AS avg_duration
	FROM       movie         AS m
	INNER JOIN genre         AS g
	ON         m.id= g.movie_id
	GROUP BY   genre 
)
SELECT   genre,
         ROUND(avg_duration,2)              AS avg_duration,
         SUM(ROUND(avg_duration,2)) OVER w1 AS running_total_duration,              -- finding cumulative sum of avg_duration of genres.
         AVG(ROUND(avg_duration,2)) OVER w2 AS moving_avg_duration                  -- finding moving averages of avg_duration of genres.
FROM     avg_duration_per_genre 
WINDOW   w1  AS (ORDER BY genre ROWS UNBOUNDED PRECEDING), 							-- window for cumulative sum
		 w2  AS (ORDER BY genre ROWS UNBOUNDED PRECEDING); 							-- window for moving average
         



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


-- Top 3 Genres based on most number of movies
WITH top_3_genre AS
(
	SELECT     genre,
			   COUNT(movie_id) AS number_of_movies
	FROM       genre           AS g
	INNER JOIN movie           AS m
	ON         g.movie_id = m.id
	GROUP BY   genre
	ORDER BY   COUNT(movie_id) DESC 
    LIMIT 3 
), 
top_5_movies AS
(
	SELECT     genre,
			   year,
			   title AS movie_name,
			   worlwide_gross_income,
			   DENSE_RANK() OVER(partition BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
	FROM       movie                                                                    AS m
	INNER JOIN genre                                                                    AS g
	ON         m.id = g.movie_id
	WHERE      genre IN
					(SELECT genre
					 FROM   top_3_genre) 
)
SELECT *
FROM   top_5_movies
WHERE  movie_rank <= 5;

/*
OUTPUT:
Total 17 Rows
Results : Refer Excel Spread Sheet : Q26
*/

           
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


SELECT     production_company,
           Count(m.id)                                AS movie_count,
           ROW_NUMBER() OVER(ORDER BY Count(id) DESC) AS prod_comp_rank
FROM       movie                                      AS m
INNER JOIN ratings                                    AS r
ON         m.id=r.movie_id
WHERE      median_rating >= 8
AND        production_company IS NOT NULL
AND        languages LIKE '%,%'-- this will fetch where Loangues contains any comma
GROUP BY   production_company 
LIMIT 2;

/*
OUTPUT
production_company	movie_count	prod_comp_rank
Star Cinema		7		1
Twentieth Century Fox	4		2
*/



-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/


SELECT  n.name, 
		SUM(total_votes) AS total_votes,
		COUNT(rm.movie_id) AS movie_count,
        g.genre,
		ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actress_avg_rating,
        DENSE_RANK() OVER(ORDER BY COUNT(rm.movie_id) DESC) AS actress_rank
FROM names AS n
INNER JOIN role_mapping AS rm
ON n.id = rm.name_id
INNER JOIN genre AS g
ON rm.movie_id = g.movie_id
LEFT OUTER JOIN ratings AS r
ON r.movie_id = g.movie_id
WHERE category = 'actress' AND avg_rating > 8 AND genre = 'Drama'
GROUP BY name
LIMIT 3;

/*
Output:
name	total_votes	movie_count	genre	actress_avg_rating	actress_rank
Parvathy Thiruvothu	4974	2	Drama	8.25	1
Susan Brown	656	2	Drama	8.94	1
Amanda Lawrence	656	2	Drama	8.94	1
*/
-- Parvathy Thiruvothu, Susan Brown and Amanda Lawrence are the top 3 actresses based on number of super hit movies

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

WITH movie_date_info AS
(
	SELECT     d.name_id,
			   name,
			   d.movie_id,
			   m.date_published,
			   LEAD(date_published, 1) OVER(partition BY d.name_id ORDER BY date_published, d.movie_id) AS next_movie_date
	FROM       director_mapping d
	INNER JOIN names AS n
	ON         d.name_id = n.id
	INNER JOIN movie AS m
	ON         d.movie_id = m.id 
), 
date_difference AS
(
	SELECT *,
		   DATEDIFF(next_movie_date, date_published) AS diff
	FROM   movie_date_info 
), 
avg_inter_days AS
(
	 SELECT   name_id,
			  Avg(diff) AS avg_inter_movie_days
	 FROM     date_difference
	 GROUP BY name_id 
), 
final_result AS
(
	SELECT     d.name_id                                          AS director_id,
			   NAME                                               AS director_name,
			   COUNT(d.movie_id)                                  AS number_of_movies,
			   ROUND(avg_inter_movie_days)                        AS inter_movie_days,
			   ROUND(Avg(avg_rating),2)                           AS avg_rating,
			   SUM(total_votes)                                   AS total_votes,
			   MIN(avg_rating)                                    AS min_rating,
			   MAX(avg_rating)                                    AS max_rating,
			   SUM(duration)                                      AS total_duration,
			   ROW_NUMBER() OVER(ORDER BY Count(d.movie_id) DESC) AS director_row_rank
	FROM       names                                              AS n
	INNER JOIN director_mapping                                   AS d
	ON         n.id = d.name_id
	INNER JOIN ratings AS r
	ON         d.movie_id = r.movie_id
	INNER JOIN movie AS m
	ON         m.id = r.movie_id
	INNER JOIN avg_inter_days AS a
	ON         a.name_id = d.name_id
	GROUP BY   director_id 
)
SELECT *
FROM   final_result LIMIT 9;



