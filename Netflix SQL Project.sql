--Netflix Data Analysis Using SQL

drop table if exists netflix;
create table netflix 
(
   show_id varchar(6),
   type  varchar(10),
   title varchar(150),
   director varchar(208),
   casts varchar(1000),
   country varchar(150),
   date_added varchar(50),
   release_year int,
   rating varchar(10),	
   duration varchar(15),
   listed_in varchar(100),
   description varchar(250)
);
select *from netflix;


select 
     count(*)  as total_content
from netflix	 

select 
     distinct type from netflix;
	 
-- 15 Business Problems

--1.count The Number of Movies vs TV Shows	

select 
     type,
	 count(*)
from netflix
group by 1

--2.Find The Most Common Rating For Movies and TV Shows 

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

--3. List All Movies Released in a Specific Year (e.g. 2020)

select *from netflix 
where release_year =2020

--4. Find The Top 10 Countries With The Most Content on Netflix

select * from
(
      select 
	  unnest(string_to_array(country, ',')) as 
	  country,
	  count(*)as
	  total_content 
from netflix group by 1
) as t1
where country is not null
order by total_content desc 
limit 10
--5. Identify The Longest Movie
select *from netflix
where type = 'Movie'
order by split_part (duration,' ',1):: int desc

--6 Find Content Added in the last 5 year

select *from netflix
where to_date(date_added, 'Month DD, YYYY') >= current_date - Interval '5 years'

--7. Find All The Movies/TV Shows by director 'Rajiv Chilaka'.!

select *from (
      select * ,
	  unnest(string_to_array (director, ','))
as director_name
from netflix
)
    where director_name = 'Rajiv Chilaka'

--8. List All TV Show With More Than 5 Seasons

select *from netflix
where 
    type = 'TV Show'
	and 
	split_Part(duration, ' ',1)::int > 5

--9. Count the Numbers of content items in each genre

select 
     unnest(string_to_array(listed_in,' '))
	 as genre,
count (*) as total_content
from netflix group by 1

--10. Find each year and the avg number og content releases in India on Netflix

select
     country,
	 release_year,
	 count(show_id) as total_realease,
round(
     count(show_id):: numeric/
(select count (show_id) from netflix where country = 'India'):: numeric* 100,2)
 as avg_release
 from netflix
 where country = 'India'
 group by country,2 
 order by avg_release desc 
 limit 10

 --11. List All Movies That are documentaries

   select * from netflix
   where listed_in like '%Documentaries'

--12. Find The All The content without The director

SELECT * FROM netflix
WHERE director IS NULL

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
      SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
      SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2

-- End of reports
