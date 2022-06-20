--1.Overview of Common Data Types

--Getting information about your database.Select all columns from the INFORMATION_SCHEMA.TABLES system database. Limit results that have a public table_schema.
-- Select all columns from the TABLES system database
SELECT *
FROM INFORMATION_SCHEMA.TABLES
-- Filter by schema
WHERE table_schema = 'public';

--Select all columns from the INFORMATION_SCHEMA.COLUMNS system database. Limit by table_name to actor
-- Select all columns from the COLUMNS system database
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'actor';

--Select the column name and data type from the INFORMATION_SCHEMA.COLUMNS system database.Limit results to only include the customer table.
-- Get the column name and data type
SELECT
 	column_name,
    data_type
-- From the system database information schema
FROM INFORMATION_SCHEMA.COLUMNS
-- For the customer table
WHERE table_name = 'customer';

--Select the rental date and return date from the rental table.Add an INTERVAL of 3 days to the rental_date to calculate the expected return date`.
SELECT
 	-- Select the rental and return dates
	rental_date,
	return_date,
 	-- Calculate the expected_return_date
	rental_date + interval '3 days' AS expected_return_date
FROM rental;

--Select the title and special features from the film table and compare the results between the two columns.
-- Select the title and special features column
SELECT
  title,
  special_features
FROM film;

--Select all films that have a special feature Trailers by filtering on the first index of the special_features ARRAY.
-- Select the title and special features column
SELECT
  title,
  special_features
FROM film
-- Use the array index of the special_features column
WHERE special_features[1] = 'Trailers'

--Now let's select all films that have Deleted Scenes in the second index of the special_features ARRAY.
-- Select the title and special features column
SELECT
  title,
  special_features
FROM film
-- Use the array index of the special_features column
WHERE special_features[2] = 'Deleted Scenes';

--Match 'Trailers' in any index of the special_features ARRAY regardless of position.
SELECT
  title,
  special_features
FROM film
-- Modify the query to use the ANY function
WHERE 'Trailers' = ANY (special_features);

--Use the contains operator to match the text Deleted Scenes in the special_features column.
SELECT
  title,
  special_features
FROM film
-- Filter where special_features contains 'Deleted Scenes'
WHERE special_features @> ARRAY['Deleted Scenes'];

--2.Working with DATE/TIME Functions and Operators

--Subtract the rental_date from the return_date to calculate the number of days_rented.
SELECT f.title, f.rental_duration,
    -- Calculate the number of days rented
    r.return_date - r.rental_date AS days_rented
FROM film AS f
     INNER JOIN inventory AS i ON f.film_id = i.film_id
     INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

--Now use the AGE() function to calculate the days_rented.
SELECT f.title, f.rental_duration,
    -- Calculate the number of days rented
	AGE(return_date,rental_date) AS days_rented
FROM film AS f
	INNER JOIN inventory AS i ON f.film_id = i.film_id
	INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

--n the previous exercise, we saw that some of the records in the results had a NULL value for the return_date. Exclude rentals with a NULL value for return_date
SELECT
	f.title,
 	-- Convert the rental_duration to an interval
    interval '1' day * rental_duration,
 	-- Calculate the days rented as we did previously
    r.return_date - r.rental_date AS days_rented
FROM film AS f
    INNER JOIN inventory AS i ON f.film_id = i.film_id
    INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
-- Filter the query to exclude outstanding rentals
WHERE r.return_date is not null
ORDER BY f.title;

--Calculating the expected return date
SELECT
    f.title,
	r.rental_date,
    f.rental_duration,
    -- Add the rental duration to the rental date
    interval '1' day * f.rental_duration + r.rental_date AS expected_return_date,
    r.return_date
FROM film AS f
    INNER JOIN inventory AS i ON f.film_id = i.film_id
    INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

--Working with the current date and time
-- Select the current timestamp
SELECT now();
-- Select the current date
SELECT current_date;
--Select the current timestamp without a timezone
SELECT cast( NOW() AS timestamp )
--Finally, let's select the current date.Use CAST() to retrieve the same result from the NOW() function.
SELECT
	-- Select the current date
	current_date,
    -- CAST the result of the NOW() function to a date
    cast( now() AS date )

--In this exercise, you will practice adding an INTERVAL to the current timestamp as well as perform some more advanced calculations.
SELECT
	CURRENT_TIMESTAMP(0)::timestamp AS right_now,
    interval '5 days' + CURRENT_TIMESTAMP(0) AS five_days_from_now;

--produce a predictive model that will help forecast DVD rental activity by day of the week.
-- Extract day of week from rental_date
SELECT
  EXTRACT(dow FROM rental_date) AS dayofweek,
  -- Count the number of rentals
  Count(*) as rentals
FROM rental
GROUP BY 1;

--modify the queries from the previous exercises Using DATE_TRUNC to aggregate rental activity.
SELECT
  DATE_TRUNC('day', rental_date) AS rental_day,
  -- Count total number of rentals
  count(*) AS rentals
FROM rental
GROUP BY 1;

--extract a list of customers and their rental history over 90 days.extract a data set that could be used to determine what day of the week customers are most likely to rent a DVD and the likelihood that they will return the DVD late.
SELECT
  c.first_name || ' ' || c.last_name AS customer_name,
  f.title,
  r.rental_date,
  -- Extract the day of week date part from the rental_date
  EXTRACT(dow FROM r.rental_date) AS dayofweek,
  AGE(r.return_date, r.rental_date) AS rental_days,
  -- Use DATE_TRUNC to get days from the AGE function
  CASE WHEN DATE_TRUNC('day', AGE(r.return_date, r.rental_date)) >
  -- Calculate number of d
    f.rental_duration * INTERVAL '1' day
  THEN TRUE
  ELSE FALSE END AS past_due
FROM
  film AS f
  INNER JOIN inventory AS i
  	ON f.film_id = i.film_id
  INNER JOIN rental AS r
  	ON i.inventory_id = r.inventory_id
  INNER JOIN customer AS c
  	ON c.customer_id = r.customer_id
WHERE
  -- Use an INTERVAL for the upper bound of the rental_date
  r.rental_date = CAST('2005-05-01' AS DATE)  + INTERVAL '90 day';

--3.Parsing and Manipulating Text

--create a query to return the customers name and email address formatted such that we could use it as a "To" field in an email script or program. This format will look like the following:Brian Piccolo <bpiccolo@datacamp.com>
SELECT first_name || ' ' || last_name || ' <' || email || '>' AS full_email
FROM customer
--or
SELECT CONCAT(first_name, ' ', last_name,  ' <', email, '>') AS full_email
FROM customer

--use the film and category tables to create a new field called film_category by concatenating the category name with the film's title.
SELECT
  -- Concatenate the category name to coverted to uppercase
  -- to the film title converted to title case
  upper(c.name)  || ': ' || initcap(f.title) AS film_category,
  -- Convert the description column to lowercase
  lower(f.description) AS description
FROM
  film AS f
  INNER JOIN film_category AS fc
  	ON f.film_id = fc.film_id
  INNER JOIN category AS c
  	ON fc.category_id = c.category_id;

--finding and replacing whitespace characters in the title column of the film table using the REPLACE() function.
SELECT
  -- Replace whitespace in the film title with an underscore
  replace(title, ' ', '_') AS title
FROM film;

--Determining the number of characters in a string
SELECT
  -- Select the title and description columns
  title,
  description,
  -- Determine the length of the description column
  char_length(description) AS desc_len
FROM film;

--Select the first 50 characters of the description column with the alias short_desc
SELECT
  -- Select the first 50 characters of description
  left(description, 50) AS short_desc
FROM
  film AS f;

-- list of all the street names where the stores are located
SELECT
  -- Select only the street name from the address table
  substring(address from position(' ' in address)+1 FOR char_length(address))
FROM
  address;

--we are going to break apart the email column from the customer table into two new derived fields.we can use the techniques to determine how many of our customers use an email from a specific domain.
SELECT
  -- Extract the characters to the left of the '@'
  left(email, position('@' IN email)-1) AS username,
  -- Extract the characters to the right of the '@'
  substring(email FROM position('@' IN email)+1 for char_length(email)) AS domain
FROM customer;

--Use padding functions to customer's first and last name separated by a single blank space and also combined the customer's full name with their email address.
-- Concatenate the first_name and last_name
SELECT
	rpad(first_name, LENGTH(first_name)+1)
    || rpad(last_name, LENGTH(last_name)+2, ' <')
    || rpad(email, LENGTH(email)+1, '>') AS full_email
FROM customer;

--Truncate the description to the first 50 characters and make sure there is no leading or trailing whitespace after truncating.
-- Concatenate the uppercase category name and film title
SELECT
  concat(upper(c.name), ': ', f.title) AS film_category,
  -- Truncate the description remove trailing whitespace
  RTRIM(LEFT(f.description, 50)) AS film_desc
FROM
  film AS f
  INNER JOIN film_category AS fc
  	ON f.film_id = fc.film_id
  INNER JOIN category AS c
  	ON fc.category_id = c.category_id;

--use the film and category tables to create a new field called film_category by concatenating the category name with the film's title. You will also practice how to truncate text fields like the film table's description column without cutting off a word.
SELECT
  UPPER(c.name) || ': ' || f.title AS film_category,
  -- Truncate the description without cutting off a word
  left(description, 50 -
    -- Subtract the position of the first whitespace character
    position(
      ' ' IN REVERSE(LEFT(description, 50))
    )
  )
FROM
  film AS f
  INNER JOIN film_category AS fc
  	ON f.film_id = fc.film_id
  INNER JOIN category AS c
  	ON fc.category_id = c.category_id;

--4.Full-text Search and PostgresSQL Extensions

--Select all columns for all records that begin with the word GOLD.
-- Select all columns
SELECT *
FROM film
-- Select only records that begin with the word 'GOLD'
WHERE title like 'GOLD%';

--select all records that end with the word GOLD
SELECT *
FROM film
-- Select only records that end with the word 'GOLD'
WHERE title like '%GOLD';

--select all records that contain the word 'GOLD'.
SELECT *
FROM film
-- Select only records that contain the word 'GOLD'
WHERE title LIKE '%GOLD%';

--Perform a full-text search on the title column for the word elf.
-- Select the title and description
SELECT title,description
FROM film
-- Convert the title to a tsvector and match it against the tsquery
WHERE to_tsvector(title) @@ to_tsquery('elf');

--Create a new enumerated data type called compass_position.Use the four positions of a compass as the values.Verify that the new data type has been created by looking in the pg_type system table.
-- Create an enumerated data type, compass_position
CREATE TYPE compass_position AS ENUM (
  	-- Use the four cardinal directions
  	'North',
  	'South',
  	'East',
  	'West'
);
-- Confirm the new data type is in the pg_type system table
SELECT *
FROM pg_type
WHERE typname='compass_position';

--Select the column_name, data_type, udt_name.Filter for the rating column in the film table.Select all columns from the pg_type table where the type name is equal to mpaa_rating.
-- Select the column name, data type and udt name columns
SELECT column_name,data_type,udt_name
FROM INFORMATION_SCHEMA.COLUMNS
-- Filter by the rating column in the film table
WHERE table_name ='film' AND column_name='rating';

SELECT *
FROM pg_type
WHERE typname='mpaa_rating'

--build a query step-by-step that can be used to produce a report to determine which film title is currently held by which customer using the inventory_held_by_customer() function.
-- Select the film title and inventory ids
SELECT
	f.title,
    i.inventory_id,
    -- Determine whether the inventory is held by a customer
    inventory_held_by_customer(i.inventory_id) as held_by_cust
FROM film as f
	INNER JOIN inventory AS i ON f.film_id=i.film_id
WHERE
	-- Only include results where the held_by_cust is not null
    inventory_held_by_customer(i.inventory_id) is not null

--Enabling extensions.Enable the pg_trgm extension.Now confirm that both fuzzystrmatch and pg_trgm are enabled by selecting all rows from the appropriate system table.
-- Enable the pg_trgm extension
CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- Select all rows extensions
SELECT *
FROM pg_extension;

--measure the similarity between the title and description from the film table of the Sakila database.
-- Select the title and description columns
SELECT
  title,
  description,
  -- Calculate the similarity
  similarity(title, description)
FROM
  film

--Calculate the levenshtein distance for the film title with the string JET NEIGHBOR.
-- Select the title and description columns
SELECT
  title,
  description,
  -- Calculate the levenshtein distance
  levenshtein(title,'JET NEIGHBOR') AS distance
FROM
  film
ORDER BY 3;

--create a tsvector from the description column in the film table. You will match against a tsquery to determine if the phrase "Astounding Drama" leads to more rentals per month. Next, create a new column using the similarity function to rank the film descriptions based on this phrase.
SELECT
  title,
  description,
  -- Calculate the similarity
  similarity(description, 'Astounding Drama')
FROM
  film
WHERE
  to_tsvector(description) @@
  to_tsquery('Astounding & Drama')
ORDER BY
similarity(description, 'Astounding Drama') DESC;
