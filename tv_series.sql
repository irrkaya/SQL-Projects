--Discovering the data

SELECT * FROM tv_series..comedy_series$

-- FIND COMEDY GENRE

SELECT Title, Genre , Rating
FROM tv_series..comedy_series$

-- Order by Rating

SELECT Title, Genre , Rating, [IMDb ID]
FROM tv_series..comedy_series$
ORDER BY Rating DESC

-- DELETE DUPLICATE VALUES 

--Discover duplicate rows

SELECT Title, Genre, Rating, ROW_NUMBER() OVER (
PARTITION BY [IMDb ID]
ORDER BY Title
) row_num
FROM tv_series..comedy_series$
order by row_num desc

-- use CTE and delete duplicate rows

WITH cte AS (
SELECT Title, Genre, Rating, ROW_NUMBER() OVER (
PARTITION BY [IMDb ID]
ORDER BY Title
) row_num
FROM tv_series..comedy_series$
) 
DELETE FROM cte
WHERE row_num>1

