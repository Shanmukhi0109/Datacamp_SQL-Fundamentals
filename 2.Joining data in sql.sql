---1.Inner Join

----statement to keep only the name of the city, the name of the country, and the name of the region the country resides in.
SELECT cities.name as city,countries.name as country,region
FROM cities
  INNER JOIN countries
    ON cities.country_code = countries.code;
---- get data from both the countries and economies tables to examine the inflation rate for both 2010 and 2015.
SELECT c.code AS country_code, name, year, inflation_rate
FROM countries AS c
  inner JOIN economies as e
    ON c.code=e.code;
----for each country, you want to get the country name, its region, the fertility rate, and the unemployment rate for both 2010 and 2015.
SELECT c.code, name, region, e.year, fertility_rate, unemployment_rate
  FROM countries AS c
  INNER JOIN populations AS p
    ON c.code = p.country_code
  INNER JOIN economies AS e
  on c.code=e.code and p.year=e.year ;

---2.Inner join with using

----get country name, continent,language name and official or not
select c.name as country,continent,l.name as language,official
from countries as c
inner join languages as l
using (code);

---3.Self-join

----use the populations table to perform a self-join to calculate the percentage increase in population from 2010 to 2015 for each country code!
-- Select fields with aliases
SELECT p1.country_code,
       p1.size AS size2010,
       p2.size AS size2015,
       -- Calculate growth_perc
       ((p2.size - p1.size)/p1.size * 100.0) AS growth_perc
-- From populations (alias as p1)
FROM populations AS p1
  -- Join to itself (alias as p2)
  INNER JOIN populations AS p2
    -- Match on country code
    ON p1.country_code = p2.country_code
        -- and year (with calculation)
        AND p1.year = p2.year - 5;

---4.Case when and then

----Using the countries table, create a new field AS geosize_group that groups the countries into three groups:If surface_area is greater than 2 million, geosize_group is 'large'.If surface_area is greater than 350 thousand but not larger than 2 million, geosize_group is 'medium'.Otherwise, geosize_group is 'small'.
SELECT name, continent, code, surface_area,
    -- First case
    CASE WHEN surface_area > 2000000 THEN 'large'
        -- Second case
        WHEN surface_area > 350000 and surface_area<2000000 THEN 'medium'
        -- Else clause + end
        ELSE 'small' END
        -- Alias name
        AS geosize_group
-- From table
FROM countries;

---5.Inner Challenge

----Using the populations table focused only for the year 2015, create a new field aliased as popsize_group to organize population size into'large' (> 50 million),'medium' (> 1 million), and'small' groups.Select only the country code, population size, and this new popsize_group as fields.
SELECT country_code, size,
    -- First case
    CASE WHEN size > 50000000 THEN 'large'
        -- Second case
        WHEN size > 1000000 THEN 'medium'
        -- Else clause + end
        ELSE 'small' END
        -- Alias name (popsize_group)
        AS popsize_group
-- From table
FROM populations
-- Focus on 2015
WHERE year = 2015;

---6.Left JOIN

----explore the differences between performing an inner join and a left join using the cities and countries tables.
SELECT c1.name AS city, code, c2.name AS country,
       region, city_proper_pop
-- From left table (with alias)
FROM cities AS c1
  -- Join to right table (with alias)
  INNER JOIN countries AS c2
    -- Match on country code
    ON c1.country_code = c2.code
-- Order by descending country code
ORDER BY code desc;

SELECT c1.name AS city, code, c2.name AS country,
       region, city_proper_pop
FROM cities AS c1
  -- Join right table (with alias)
  left JOIN countries AS c2
    -- Match on country code
    ON c1.country_code = c2.code
-- Order by descending country code
ORDER BY code DESC;

----another example comparing an inner join to its corresponding left join.
select  c.name AS country, local_name, l.name AS language, percent
-- From left table (alias as c)
FROM countries AS c
  -- Join to right table (alias as l)
  inner JOIN languages AS l
    -- Match on fields
    ON c.code=l.code
-- Order by descending country
ORDER BY country desc;

select  c.name AS country, local_name, l.name AS language, percent
-- From left table (alias as c)
FROM countries AS c
  -- Join to right table (alias as l)
  inner JOIN languages AS l
    -- Match on fields
    ON c.code=l.code
-- Order by descending country
ORDER BY country desc;

----left join to determine the average gross domestic product (GDP) per capita by region in 2010.
SELECT name,region,gdp_percapita
-- From countries (alias as c)
FROM countries AS c
  -- Left join with economies (alias as e)
  LEFT JOIN economies AS e
    -- Match on code fields
    ON c.code=e.code
-- Focus on 2010
WHERE year=2010;

---7.Right JOIN
SELECT cities.name AS city, urbanarea_pop, countries.name AS country,
       indep_year, languages.name AS language, percent
FROM languages
  RIGHT JOIN countries
    ON languages.code=countries.code
  RIGHT JOIN cities
    ON countries.code = cities.country_code
ORDER BY city, language;

---8.Full JOIN

----examine how your results differ when using a full join versus using a left join versus using an inner join with the countries and currencies tables.You will focus on the North American region and also where the name of the country is missing
SELECT name AS country, code, region, basic_unit
-- From countries
FROM countries
  -- Join to currencies
  FULL JOIN currencies
    -- Match on code
    USING (code)
-- Where region is North America or null
WHERE region = 'North America' OR region IS null
-- Order by region
ORDER BY region;

SELECT name AS country, code, region, basic_unit
-- From countries
FROM countries
  -- Join to currencies
  left join  currencies
    -- Match on code
    using (code)
-- Where region is North America or null
WHERE region = 'North America' OR region IS NULL
-- Order by region
ORDER BY region;

SELECT name AS country, code, region, basic_unit
-- From countries
FROM countries
  -- Join to currencies
  inner Join currencies
    -- Match on code
    USING (code)
-- Where region is North America or null
WHERE region = 'North America' OR region IS NULL
-- Order by region
ORDER BY region;

----investigate a similar exercise to the last one, but this time focused on using a table with more records on the left than the right. You'll work with the languages and countries tables.
SELECT countries.name, code, languages.name AS language
-- From languages
FROM languages
  -- Join to countries
  full JOIN countries
    -- Match on code
    USING (code)
-- Where countries.name starts with V or is null
WHERE countries.name LIKE 'V%' OR countries.name IS null
-- Order by ascending countries.name
ORDER BY countries.name;

SELECT countries.name, code, languages.name AS language
-- From languages
FROM languages
  -- Join to countries
  left Join countries
    -- Match on code
    USING (code)
-- Where countries.name starts with V or is null
Where countries.name LIKE 'V%' OR countries.name IS NULL
-- Order by ascending countries.name
ORDER BY countries.name;

SELECT countries.name, code, languages.name AS language
-- From languages
FROM languages
  -- Join to countries
  inner Join countries
    -- Match using code
    USING (code)
-- Where countries.name starts with V or is null
WHERE countries.name LIKE 'V%' OR countries.name IS NULL
-- Order by ascending countries.name
order by countries.name;

---- explore using two consecutive full joins on the three tables you worked with in the previous two exercises.
-- Select fields (with aliases)
SELECT c1.name AS country, region, l.name AS language,
       basic_unit,frac_unit
-- From countries (alias as c1)
FROM countries AS c1
  -- Join with languages (alias as l)
  FULL JOIN languages AS l
    -- Match on code
    USING (code)
  -- Join with currencies (alias as c2)
  FULL JOIN currencies AS c2
    -- Match on code
    USING (code)
-- Where region like Melanesia and Micronesia
WHERE region LIKE 'M%esia';

---9.Cross JOIN

----exercise looks to explore languages potentially and most frequently spoken in the cities of Hyderabad, India and Hyderabad, Pakistan.
-- Select fields
SELECT c.name AS city, l.name as language
-- From cities (alias as c)
FROM cities AS c
  -- Join to languages (alias as l)
  CROSS JOIN languages AS l
-- Where c.name like Hyderabad
WHERE c.name LIKE 'Hyder%';

-- Select fields
SELECT c.name AS city, l.name as language
-- From cities (alias as c)
FROM cities AS c
  -- Join to languages (alias as l)
inner JOIN languages AS l
on c.country_code=l.code
-- Where c.name like Hyderabad
WHERE c.name LIKE 'Hyder%';

---10. Outer Challenge

----In terms of life expectancy for 2010, determine the names of the lowest five countries and their regions.
select c.name as country,region,life_expectancy as life_exp
-- From countries (alias as c)
from countries as c
  -- Join to populations (alias as p)
  left join populations as p
    -- Match on country code
  on c.code=p.country_code
-- Focus on 2010
where year=2010
-- Order by life_exp
order by life_exp
-- Limit to 5 records
limit 5;

---11.Union

----Combine the two new tables into one table containing all of the fields in economies2010 and 2015.Sort this resulting single table by country code and then by year, both in ascending order.
-- Select fields from 2010 table
Select *
  -- From 2010 table
  from economies2010
	-- Set theory clause
	union
-- Select fields from 2015 table
select *
  -- From 2015 table
  from economies2015
-- Order by code and year
order by code,year;

----Determine all (non-duplicated) country codes in either the cities or the currencies table. The result should be a table with only one field called country_code.Sort by country_code in alphabetical order.
-- Select field
Select country_code
  -- From cities
from cities
	-- Set theory clause
	union
-- Select field
select code
  -- From currencies
  from currencies
-- Order by country_code
order by country_code;

---12.Union All

----As you saw, duplicates were removed from the previous two exercises by using UNION.To include duplicates, you can use UNION ALL.
-- Select fields
SELECT code,year
  -- From economies
  FROM economies
	-- Set theory clause
	union all
-- Select fields
SELECT country_code,year
  -- From populations
  FROM populations
-- Order by code, year
ORDER BY code, year;

---13. Intersect

----Use INTERSECT to determine the records in common for country code and year for the economies and populations tables.
-- Select fields
SELECT code,year
  -- From economies
  FROM economies
  -- Set theory clause
  intersect
-- Select fields
SELECT country_code,year
  -- From populations
      FROM populations
-- Order by code, year
ORDER BY code, year;

----which countries also have a city with the same name as their country name?
-- Select fields
select name
  -- From countries
  from countries
	-- Set theory clause
	intersect
-- Select fields
select name
  -- From cities
  from cities;

---14.Except

----Get the names of cities in cities which are not noted as capital cities in countries as a single field result.
-- Select field
SELECT name
  -- From cities
  FROM cities
	-- Set theory clause
	except
-- Select field
SELECT capital
  -- From countries
  FROM countries
-- Order by result
ORDER BY name;

----Determine the names of capital cities that are not listed in the cities table.
-- Select field
select capital
  -- From countries
  from countries
	-- Set theory clause
	except
-- Select field
select name
  -- From cities
  from cities
-- Order by ascending capital
order by capital;

---15.Semi-Join

----use the concept of a semi-join to identify languages spoken in the Middle East.
SELECT  distinct name
  FROM languages
-- Where in statement
where code in
  -- Subquery
  (SELECT code
   FROM countries
   WHERE region = 'Middle East')
-- Order by name
order by name;

---16.Anti-Join

---- Your goal is to identify the currencies used in Oceanian countries!
-- Select fields
Select code,name
  -- From Countries
  from countries
  -- Where continent is Oceania
  where continent='Oceania'
  	-- And code not in
  	and code not in
  	-- Subquery
  	(select code from currencies);

---16. set theory Challenge

----Identify the country codes that are included in either economies or currencies but not in populations.Use that result to determine the names of cities in the countries that match the specification .
-- Select the city name
Select name
  -- Alias the table where city name resides
  from cities  AS c1
  -- Choose only records matching the result of multiple set theory clauses
  WHERE country_code IN
(
    -- Select appropriate field from economies AS e
    SELECT e.code
    FROM economies AS e
    -- Get all additional (unique) values of the field from currencies AS c2
    union
    SELECT c2.code
    FROM currencies AS c2
    -- Exclude those appearing in populations AS p
    except
    SELECT p.country_code
    FROM populations AS p
);

---17. Subquery inside where

----which countries had high average life expectancies (at the country level) in 2015.
-- Select fields
SELECT *
  -- From populations
  FROM populations
-- Where life_expectancy is greater than
WHERE life_expectancy >
  -- 1.15 * subquery
  1.15 * (SELECT AVG(life_expectancy)
   FROM populations
   WHERE year = 2015) AND
  year = 2015;

----get the urban area population for only capital cities.
select name,country_code, urbanarea_pop
	  -- From cities
	from cities
	-- Where city name in the field of capital cities
	where name IN
	  -- Subquery
	  (select capital from countries)
	ORDER BY urbanarea_pop DESC;

---18.Subquery inside select

----query selects the top nine countries in terms of number of cities appearing in the cities table.
SELECT countries.name AS country,
  -- Subquery
  (SELECT count(*)
   FROM cities
   WHERE countries.code = cities.country_code) AS cities_num
FROM countries
ORDER BY cities_num desc,country
LIMIT 9;

---19.Subquery inside from

---- determine the number of languages spoken for each country, identified by the country's local name! (Note this may be different than the name field and is stored in the local_name field.)
-- Select fields
select local_name,subquery.lang_num
  -- From countries
  from countries,
  	-- Subquery (alias as subquery)
  	(SELECT code, COUNT(*) AS lang_num
  	 FROM languages
  	 GROUP BY code) AS subquery
  -- Where codes match
  where countries.code=subquery.code
-- Order by descending number of languages
order by lang_num desc;

---20. Advanced subquery

----for each of the six continents listed in 2015, you'll identify which country had the maximum inflation rate, and how high it was, using multiple subqueries.
-- Select fields
SELECT name, continent, inflation_rate
  -- From countries
  FROM countries
	-- Join to economies
	INNER JOIN economies
	-- Match on code
	using (code)
  -- Where year is 2015
  WHERE year = 2015
    -- And inflation rate in subquery (alias as subquery)
    and inflation_rate in  (
        SELECT MAX(inflation_rate) AS max_inf
        FROM (
             SELECT name, continent, inflation_rate
             FROM countries
             INNER JOIN economies
             using (code)
             WHERE year = 2015) AS subquery
      -- Group by continent
        GROUP BY continent);

---21. Subquery Challenge

----Use a subquery to get 2015 economic data for countries that do not havegov_form of 'Constitutional Monarchy' or 'Republic' in their gov_form.
-- Select fields
SELECT code, inflation_rate,unemployment_rate
  -- From economies
  FROM economies
  -- Where year is 2015 and code is not in
  WHERE year = 2015 AND code not in
  	-- Subquery
  	(SELECT code
  	 FROM countries
  	 WHERE (gov_form = 'Constitutional Monarchy' OR gov_form LIKE '%Republic%'))
-- Order by inflation rate
ORDER BY inflation_rate;

---22. Final Challenge

----get the country names and other 2015 data in the economies table and the countries table for Central American countries with an official language.
-- Select fields
SELECT DISTINCT c.name, total_investment, imports
  -- From table (with alias)
  FROM countries AS c
    -- Join with table (with alias)
    LEFT JOIN economies AS e
      -- Match on code
      ON (c.code = e.code
      -- and code in Subquery
        AND c.code IN (
          SELECT l.code
          FROM languages AS l
          WHERE official='true'
        ) )
  -- Where region and year are correct
  WHERE region='Central America' AND year=2015
-- Order by field
ORDER BY c.name;

----calculate the average fertility rate for each region in 2015.
-- Select fields
SELECT region, continent, avg(fertility_rate) AS avg_fert_rate
  -- From left table
  FROM countries AS c
    -- Join to right table
    INNER JOIN populations  AS p
      -- Match on join condition
      ON c.code=p.country_code
  -- Where specific records matching some condition
  WHERE year=2015
-- Group appropriately
GROUP BY region,continent
-- Order appropriately
ORDER BY avg_fert_rate;

----determining the top 10 capital cities in Europe and the Americas in terms of a calculated percentage using city_proper_pop and metroarea_pop in cities.
-- Select fields
SELECT name,country_code,city_proper_pop,metroarea_pop,
      -- Calculate city_perc
      city_proper_pop/metroarea_pop*100 as city_perc
  -- From appropriate table
  FROM cities
  -- Where
  WHERE name IN
    -- Subquery
    (SELECT capital
     FROM countries
     WHERE (continent = 'Europe'
        OR continent LIKE '%America'))
       AND metroarea_pop is not null
-- Order appropriately
ORDER BY city_perc desc
-- Limit amount
limit 10;
