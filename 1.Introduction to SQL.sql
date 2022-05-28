---1.SELECTing single columns

----Select the title column from the films table.
select title from films;
----Select the release_year column from the films table.
select release_year from films;
----Select the name of each person in the people table.
select name from people;

---2.SELECTing multiple columns

----Get the title of every film from the films table.
select title from films;
----Get the title and release year for every film.
SELECT title,release_year
FROM films;
----Get the title, release year and country for every film.
SELECT title, release_year,country
FROM films;
----Get all columns from the films table.
SELECT *
FROM films;

---3.SELECT DISTINCT

----Get all the unique countries represented in the films table.
select distinct country from films;
----Get all the different film certifications from the films table.
SELECT distinct certification from films;
----Get the different types of film roles from the roles table.
SELECT distinct role from roles;

---4.Practice with COUNT

----Count the number of rows in the people table.
select count(*) from people;
----Count the number of (non-missing) birth dates in the people table.
SELECT COUNT(birthdate)
FROM people;
----Count the number of unique birth dates in the people table.
SELECT COUNT( distinct birthdate)
FROM people;
----Count the number of unique languages in the films table.
select count(distinct language) from films;
----Count the number of unique countries in the films table.
select count(distinct country) from films;

---5.Simple filtering of numeric values

----Get all details for all films released in 2016.
select * from films where release_year=2016;
----Get the number of films released before 2000.
select count(*) from films where release_year<2000;
----Get the title and release year of films released after 2000.
select title,release_year from films where release_year>2000;

---6.Simple filtering of text

----Get all details for all French language films.
select * from films where language='French';
----Get the name and birth date of the person born on November 11th, 1974. Remember to use ISO date format ('1974-11-11')!
select name,birthdate from people where birthdate='1974-11-11';
----Get the number of Hindi language films.
select count(*) from films where language='Hindi';
----Get all details for all films with an R certification.
select * from films where certification='R';

---7.WHERE AND

----Get the title and release year for all Spanish language films released before 2000.
select title,release_year from films where language='Spanish' and
release_year<2000;
----Get all details for Spanish language films released after 2000.
select *from films where language='Spanish' and
release_year>2000;
----Get all details for Spanish language films released after 2000, but before 2010.
select *from films where language='Spanish' and
release_year>2000 and release_year<2010;

---8.WHERE AND OR (2)

----write a query to get the title and release year of films released in the 90s which were in French or Spanish and which took in more than $2M gross.
SELECT title, release_year
FROM films
WHERE (release_year >= 1990 AND release_year < 2000)
AND (language = 'French' OR language = 'Spanish')
and gross>2000000;

---9.BETWEEN (2)

----get the title and release year of all Spanish or French language films released between 1990 and 2000 (inclusive) with budgets over $100 million.
SELECT title, release_year
FROM films
WHERE release_year BETWEEN 1990 AND 2000
AND budget > 100000000
AND (language = 'Spanish' or language='French');

---10.WHERE IN

----Get the title and release year of all films released in 1990 or 2000 that were longer than two hours. Remember, duration is in minutes!
select title,release_year
from films
where release_year in (1990,2000)
and duration>120;
----Get the title and language of all films which were in English, Spanish, or French.
select title, language
from films
where language in ('English','Spanish','French');
----Get the title and certification of all films with an NC-17 or R certification.
select title, certification
from films
where certification in ('NC-17','R');

---11.NULL and IS NULL

----Get the names of people who are still alive, i.e. whose death date is missing.
select name from people where deathdate is null;
----Get the title of every film which doesn't have a budget associated with it.
select title from films where budget is null;
----Get the number of films which don't have a language associated with them.
select count(*) from films where language is null;

---12.LIKE and NOT LIKE

----Get the names of all people whose names begin with 'B'. The pattern you need is 'B%'.
select name from people where name like 'B%';
----Get the names of people whose names have 'r' as the second letter. The pattern you need is '_r%'.
select name from people where name like '_r%';
----Get the names of people whose names don't start with A. The pattern you need is 'A%'.
select name from people where name not like 'A%';

---13.Aggregate functions

----Use the SUM() function to get the total duration of all films.
select sum(duration) from films;
----Get the average duration of all films.
select avg(duration) from films;
----Get the duration of the shortest film.
select min(duration) from films;
----Get the duration of the longest film.
select max(duration) from films;

---14.Aggregate functions practice

----Use the SUM() function to get the total amount grossed by all films.
select sum(gross) from films;
----Get the average amount grossed by all films.
select avg(gross) from films;
----Get the amount grossed by the worst performing film.
select min(gross) from films;
----Get the amount grossed by the best performing film.
select max(gross) from films;

---15.Combining aggregate functions with WHERE

----Use the SUM() function to get the total amount grossed by all films made in the year 2000 or later.
select sum(gross) from films where release_year>=2000;
----Get the average amount grossed by all films whose titles start with the letter 'A'.
select avg(gross) from films where title like 'A%';
----Get the amount grossed by the worst performing film in 1994.
select min(gross) from films where release_year=1994;
----Get the amount grossed by the best performing film between 2000 and 2012, inclusive.
select max(gross) from films where release_year between 2000 and 2012;

---16.It's AS simple AS aliasing

----Get the title and net profit (the amount a film grossed, minus its budget) for all films. Alias the net profit as net_profit.
select title,(gross-budget) as net_profit from films;
----Get the title and duration in hours for all films. The duration is in minutes, so you'll need to divide by 60.0 to get the duration in hours. Alias the duration in hours as duration_hours.
select title,(duration/60.0) as duration_hours
from films;
----Get the average duration in hours for all films, aliased as avg_duration_hours.
select avg(duration)/60.0as avg_duration_hours from films;

---17.Even more aliasing

----Get the percentage of people who are no longer alive. Alias the result as percentage_dead. Remember to use 100.0 and not 100!
select count(deathdate)*100.0/count(*) as percentage_dead from people;
----Get the number of years between the newest film and oldest film. Alias the result as difference.
select (max(release_year)-min(release_year)) as difference from films;
----Get the number of decades the films table covers. Alias the result as number_of_decades. The top half of your fraction should be enclosed in parentheses.
select (max(release_year)-min(release_year))/10 as number_of_decades
from films;

---18.Sorting single columns

----Get the names of people from the people table, sorted alphabetically.
select name from people order by name;
----Get the names of people, sorted by birth date.
select name from people order by birthdate;
----Get the birth date and name for every person, in order of when they were born.
select name,birthdate from people order by birthdate;

---19.Sorting single columns (2)

----Get the title of films released in 2000 or 2012, in the order they were released.
select title from films where release_year in (2000,2012) order by release_year;
----Get all details for all films except those released in 2015 and order them by duration.
select * from films where release_year not in (2015) order by duration;
----Get the title and gross earnings for movies which begin with the letter 'M' and order the results alphabetically.
select title,gross from films where title like 'M%' order by title;

---20.Sorting single columns (DESC)

----Get the IMDB score and film ID for every film from the reviews table, sorted from highest to lowest score.
select imdb_score,film_id from reviews order by imdb_score desc;
----Get the title for every film, in reverse order.
select title from films order by title desc;
----Get the title and duration for every film, in order of longest duration to shortest.
select title,duration from films order by duration desc;

---21.Sorting multiple columns

----Get the birth date and name of people in the people table, in order of when they were born and alphabetically by name.
select name,birthdate from people order by birthdate,name;
----Get the release year, duration, and title of films ordered by their release year and duration.
select release_year,duration, title from films order by release_year,duration;
----Get certifications, release years, and titles of films ordered by certification (alphabetically) and release year.
select certification,release_year,title from films order by certification,release_year;
----Get the names and birthdates of people ordered by name and birth date.
select name,birthdate from people order by name,birthdate;

---22.GROUP BY practice

----Get the release year and count of films released in each year.
select release_year,count(*) from films group by release_year;
----Get the release year and average duration of all films, grouped by release year.
select release_year, avg(duration) from films group by release_year;
----Get the release year and largest budget for all films, grouped by release year.
select release_year, max(budget) from films group by release_year;
----Get the IMDB score and count of film reviews grouped by IMDB score in the reviews table.
select imdb_score, count(*) from reviews group by imdb_score;

---23.GROUP BY practice (2)

----Get the release year and lowest gross earnings per release year.
select release_year,min(gross) from films group by release_year;
----Get the language and total gross amount films in each language made.
select language, sum(gross) from films group by language;
----Get the country and total budget spent making movies in each country.
select country, sum(budget) from films group by country;
----Get the release year, country, and highest budget spent making a film for each year, for each country. Sort your results by release year and country.
select release_year, country, max(budget)
from films
group by release_year,country
order by release_year,country;
----Get the country, release year, and lowest amount grossed per release year per country. Order your results by country and release year.
select release_year, country, min(gross)
from films
group by release_year,country
order by country,release_year;

---24.All together now

---- write a query that returns the average budget and average gross earnings for films in each year after 1990, if the average budget is greater than $60 million.
SELECT release_year, AVG(budget) AS avg_budget, AVG(gross) AS avg_gross
FROM films
WHERE release_year > 1990
GROUP BY release_year
HAVING AVG(budget) > 60000000
order by avg_gross desc;

---25.All together now (2)

----Get the country, average budget, and average gross take of countries that have made more than 10 films. Order the result by country name, and limit the number of results displayed to 5. You should alias the averages as avg_budget and avg_gross respectively.
select country,avg(budget) as avg_budget,avg(gross)as avg_gross
from films
group by country
having count(title)>10
order by country
limit 5;
