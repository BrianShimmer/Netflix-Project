SELECT * FROM netflix.netflix_data;


CREATE TABLE netflix (
id int,
   show_id varchar(255),
   type varchar(255),
   title varchar(255),
   director varchar(255),
   country varchar(255),
   date_added varchar(255),
   release_year varchar(255),
   rating varchar(255),
   duration varchar(255),
   listed_in varchar(255)
);

insert into netflix values

use netflix;

/*SQL Project*/

/*Segment 1*/

 /*Determine the number of rows in each table within the schema.*/

SELECT COUNT(*) AS Row_Count
FROM netflix;

 /*Identify and handle any missing values in the dataset. */
SELECT
    'Netflix' AS table_name,
    SUM(CASE WHEN show_id IS NULL THEN 1 ELSE 0 END) AS missing_show_id,
    SUM(CASE WHEN type IS NULL THEN 1 ELSE 0 END) AS missing_type,
    SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS missing_title,
    SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS missing_director,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN date_added IS NULL THEN 1 ELSE 0 END) AS missing_date_added,
    SUM(CASE WHEN release_year IS NULL THEN 1 ELSE 0 END) AS missing_release_year,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS missing_rating,
    SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS missing_duration,
    SUM(CASE WHEN listed_in IS NULL THEN 1 ELSE 0 END) AS missing_listed_in
FROM
    Netflix;

/*Segment 2*/
/*-	Analyse the distribution of content types (movies vs. TV shows) in the dataset.*/
SELECT TYPE,COUNT(show_id)*100/(select count(show_id) from netflix) as percentage 
FROM netflix 
GROUP by TYPE;

/*-	Determine the top 10 countries with the highest number of productions on Netflix.*/
SELECT country,count(country) as count
FROM netflix
GROUP BY country
ORDER BY count Desc
LIMIT 10;

/*-	Investigate the trend of content additions over the years.*/
SELECT DISTINCT listed_in,release_year,count(release_year) AS content_additions
FROM netflix
GROUP BY listed_in,release_year
ORDER BY listed_in, release_year desc;

/*-	Analyse the relationship between content duration and release year.*/
SELECT DISTINCT release_year,SUM(duration)
FROM netflix
GROUP BY release_year
ORDER BY release_year desc;

/*-	Identify the directors with the most content on Netflix.*/
SELECT DISTINCT director,count(*) as count
FROM netflix
WHERE director NOT IN(SELECT director FROM netflix WHERE director='not given')
GROUP BY director
ORDER BY count desc;

/*Segment 3*/
/*-	Determine the unique genres and categories present in the dataset.*/
SELECT TYPE as categories,listed_in as genres 
FROM netflix 
GROUP BY type,listed_in; 

/*-	Calculate the percentage of movies and TV shows in each genre.*/
SELECT distinct listed_in AS genres,COUNT(show_id)*100/(SELECT COUNT(show_id) FROM netflix) AS percentage 
FROM netflix 
GROUP BY listed_in;

/*-	Identify the most popular genres/categories based on the number of productions.*/
SELECT * FROM
(
SELECT Distinct type, listed_in,
COUNT(*) OVER (PARTITION BY type, listed_in) AS co_occurence
FROM netflix
) t
WHERE co_occurence > 1
ORDER BY co_occurence desc;


/*-	Calculate the cumulative sum of content duration within each genre.*/
SELECT listed_in as Categories,sum(duration) as cumulative_sum 
FROM netflix 
GROUP BY Categories
ORDER BY cumulative_sum DESC;

/*Segment 4*/

/*Determine the distribution of content releases by month and year.*/
SELECT
    MONTH(STR_TO_DATE(date_added, '%m/%d/%Y')) AS month,
    YEAR(STR_TO_DATE(date_added, '%m/%d/%Y')) AS year,
    COUNT(*) AS count
FROM Netflix
WHERE date_added IS NOT NULL
GROUP BY month, year;

  /*Analyse the seasonal patterns in content releases. */
SELECT
    MONTH(STR_TO_DATE(date_added, '%m/%d/%Y')) AS month,
    YEAR(STR_TO_DATE(date_added, '%m/%d/%Y')) AS year,
    COUNT(*) AS count
FROM Netflix
WHERE date_added IS NOT NULL
GROUP BY month, year
ORDER BY year, month;

  /*Identify the months and years with the highest number of releases.*/
SELECT
    MONTH(STR_TO_DATE(date_added, '%m/%d/%Y')) AS month,
    YEAR(STR_TO_DATE(date_added, '%m/%d/%Y')) AS year,
    COUNT(*) AS Highest_release
FROM Netflix
WHERE date_added IS NOT NULL
GROUP BY month, year
ORDER BY Highest_release DESC;

/*Segment 5*/
/*1 Investigate the distribution of ratings across different genres*/
SELECT type,rating,COUNT(*) AS rating_count
FROM netflix
GROUP BY type,rating
ORDER BY rating_count desc;

/*Analyse the relationship between ratings and content duration*/
SELECT distinct rating,sum(duration) as Total_duration,
       COUNT(*) AS rating_count
FROM netflix
GROUP BY rating
ORDER BY Total_duration desc;
/*Recommendations
*Duration plays a role in rating though there are discrepancies in data with some inference
not being consistent with the data
/*Segment 6*/
/*-	Identify the most common pairs of genres/categories that occur together in content.*/
SELECT * FROM
(
SELECT Distinct type, listed_in,
count(*) OVER (PARTITION BY type, listed_in) AS co_occurence
FROM netflix
) t
WHERE co_occurence > 1
ORDER BY type, listed_in;

/*-	Analyse the relationship between genres/categories and content duration*/
SELECT * FROM
(
SELECT DISTINCT type,listed_in,duration,
COUNT(*) OVER (PARTITION BY type,listed_in,duration) AS co_occurence
FROM netflix
) t
WHERE co_occurence>1
ORDER BY type,listed_in,duration;

/*Segment 7*/
/* -	Identify the countries where Netflix has expanded its content offerings.*/
SELECT distinct country
FROM netflix.netflix
WHERE date_added IS NOT NULL;

/* -	Analyse the distribution of content types in different countries.*/
SELECT country,type, COUNT(*) AS content_count
FROM netflix.netflix
GROUP BY country, type
ORDER BY content_count DESC, country;

/* -	Investigate the relationship between content duration and country of production.*/
SELECT country,
       AVG(CASE WHEN type = 'Movie' THEN duration_minutes END) AS avg_movie_duration,
       AVG(CASE WHEN type = 'TV Show' THEN duration_seasons END) AS avg_tv_show_duration
FROM (
    SELECT *,
           CASE WHEN type = 'Movie' THEN CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) END AS duration_minutes,
           CASE WHEN type = 'TV Show' THEN CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) END AS duration_seasons
    FROM netflix.netflix
) AS data
GROUP BY country;

/*Segment 8*/

/*Recommendations for Content Strategy Based on the analysis, provide recommendations for the types of content Netflix should focus on producing.*/

/*Recommendations

*Focusing on dramas and international movies top the chart, hence emphasis on them could be given for more profitability
*Documentaries and Stand-Up Comedy play an important part of the entertainment industry and there seems to be a rsing production on their part which can imply their growing popularity , as one of the top producing categories, exploration on the two can bring about substantial development .
*Children,family movies are vital players in the field which means to explain their evergreen property in a world where families and Children are always present.
*There has been a growing incidence of duration increase in production except during the period of covid where there was significant decline in production, as this can be attributed to unprecedent situation present during that time but considering the effect of loss because of that, effective measures to find new methods of alternate productions or genres can be introduced as COVID forced people to stay at home but that rather affected the entertainment industry when in reality it could have made significant profit.



  /*Identify potential areas for expansion and growth based on the analysis of the dataset.*/

/*Recommendations
Categories of Focus:
*Action, thrillers , crime TV shows show huge potential
*korean Tv Shows also show promise.

Countries of Focus:
*Movies:  India, Canada have an increased presence of movies
*TV shows:  Pakistan, Japan have strong growth potential in TV shows

*/
