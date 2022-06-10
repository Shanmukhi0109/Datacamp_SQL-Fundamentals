--1. Case statement

--identify matches played between FC Schalke 04 and FC Bayern Munich.
SELECT
	CASE WHEN hometeam_id = 10189 THEN 'FC Schalke 04'
        WHEN hometeam_id = 9823 THEN 'FC Bayern Munich'
         ELSE 'Other' END AS home_team,
	COUNT(id) AS total_matches
FROM matches_germany
GROUP BY home_team;

-- list of matches in the 2011/2012 season where Barcelona was the home team.
SELECT
	m.date,
	t.team_long_name AS opponent,
	CASE WHEN m.home_goal > m.away_goal THEN 'Barcelona win!'
         WHEN m.home_goal < m.away_goal THEN 'Barcelona loss :('
         ELSE 'Tie' END AS outcome
FROM matches_spain AS m
LEFT JOIN teams_spain AS t
ON m.awayteam_id = t.team_api_id
WHERE m.hometeam_id = 8634;

--query to determine the outcome of Barcelona's matches where they played as the away team.
SELECT
	m.date,
	t.team_long_name AS opponent,
	case when m.home_goal <m.away_goal  then 'Barcelona win!'
        WHEN m.home_goal > m.away_goal  then 'Barcelona loss :('
        else 'Tie' end as outcome
FROM matches_spain AS m
LEFT JOIN teams_spain AS t
ON m.hometeam_id = t.team_api_id
WHERE m.awayteam_id =8634;

--retrieve information about matches played between Barcelona (id = 8634) and Real Madrid (id = 8633).
SELECT
	date,
	CASE WHEN hometeam_id = 8634 THEN 'FC Barcelona'
         ELSE 'Real Madrid CF' END as home,
	CASE WHEN awayteam_id = 8634 THEN 'FC Barcelona'
         ELSE 'Real Madrid CF' END as away,
	-- Identify all possible match outcomes
	case when home_goal> away_goal and hometeam_id = 8634 then'Barcelona win!'
        WHEN home_goal > away_goal and hometeam_id = 8633 then 'Real Madrid win!'
        WHEN home_goal < away_goal and awayteam_id = 8634 then 'Barcelona win!'
        WHEN home_goal < away_goal and awayteam_id = 8633 then 'Real Madrid win!'
        else  'Tie!' end as outcome
FROM matches_spain
WHERE (awayteam_id = 8634 OR hometeam_id = 8634)
      AND (awayteam_id = 8633 OR hometeam_id = 8633);

--generate a list of matches won by Italy's Bologna team!
SELECT
	season,
    date,
	home_goal,away_goal
FROM matches_italy
WHERE
-- Exclude games not won by Bologna
	case when hometeam_id = 9857 and home_goal > away_goal then'Bologna Win'
		when awayteam_id = 9857 and  away_goal>home_goal then 'Bologna Win'
		end IS NOT null;

--count the number of matches played in each country during the 2012/2013, 2013/2014, and 2014/2015 match seasons.
SELECT
	c.name AS country,
    -- Count matches in each of the 3 seasons
	count(case when m.season = '2012/2013' then m.id end) AS matches_2012_2013,
	count(case when m.season = '2013/2014' then m.id end) AS matches_2013_2014,
	count(case when m.season = '2014/2015' then m.id end) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
-- Group by country name alias
group by country;

--total number of matches won by the home team in each country during the 2012/2013, 2013/2014, and 2014/2015 seasons.
SELECT
	c.name AS country,
    -- Sum the total records in each season where the home team won
	sum(case when m.season = '2012/2013' AND m.home_goal> m.away_goal
        THEN 1 ELSE 0 end) AS matches_2012_2013,
 	sum(case when m.season = '2013/2014' AND m.home_goal> m.away_goal
        THEN 1 ELSE 0 end) AS matches_2013_2014,
	sum(case when m.season = '2014/2015' AND m.home_goal> m.away_goal
        THEN 1 ELSE 0 end)AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
-- Group by country name alias
GROUP BY country;

--examine the number of wins, losses, and ties in each country. The matches table is filtered to include all matches from the 2013/2014 and 2014/2015 seasons.
SELECT
	c.name AS country,
    -- Round the percentage of tied games to 2 decimal points
	round(avg(CASE WHEN m.season='2013/2014' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2013/2014' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2013_2014,
	round(avg(CASE WHEN m.season='2014/2015' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2014/2015' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2014_2015
FROM country AS c
LEFT JOIN matches AS m
ON c.id = m.country_id
GROUP BY country;

--2. subqueries

--generate a list of matches where the total goals scored (for both teams in total) is more than 3 times the average for games in the matches_2013_2014 table, which includes all games played in the 2013/2014 season.
SELECT
	-- Select the date, home goals, and away goals scored
    date,home_goal,away_goal
FROM  matches_2013_2014
-- Filter for matches where total goals exceeds 3x the average
WHERE (home_goal + away_goal) >
       (SELECT 3 * AVG(home_goal + away_goal)
        FROM matches_2013_2014);

--generate a list of teams that never played a game in their home city.
SELECT
	-- Select the team long and short names
	team_long_name,team_short_name
FROM team
-- Exclude all values from the subquery
WHERE team_api_id NOT IN
     (SELECT  DISTINCT hometeam_id  FROM match);

--list of teams that scored 8 or more goals in a home match.
SELECT
	-- Select the team long and short names
	team_long_name,team_short_name
FROM team
-- Filter for teams with 8 or more home goals
WHERE team_api_id IN
	  (SELECT hometeam_id
       FROM match
       WHERE home_goal>= 8);

--calculate information about matches with 10 or more goals in total!
SELECT
	-- Select country name and the count match IDs
    c.name AS country_name,
    COUNT(sub.id) AS matches
FROM country AS c
-- Inner join the subquery onto country
-- Select the country id and match id columns
inner join (SELECT country_id,id
           FROM match
           -- Filter the subquery by matches with 10+ goals
           WHERE (home_goal+away_goal) >= 10) AS sub
ON c.id = sub.country_id
GROUP BY country_name;

--matches in the database where 10 or more goals were scored overall. when they were played, during which seasons, and how many of the goals were home versus away goals.
SELECT
	-- Select country, date, home, and away goals from the subquery
    country,
    date,
    home_goal,
    away_goal
FROM
	-- Select country name, date, home_goal, away_goal, and total goals in the subquery
	(SELECT c.name AS country,
     	    m.date,
     		m.home_goal,
     		m.away_goal,
           (m.home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN country AS c
    ON m.country_id = c.id) AS subq
-- Filter by total goals scored in the main query
WHERE total_goals >=10;

--query that calculates the average number of goals per match in each country's league.
SELECT
	l.name AS league,
    -- Select and round the league's total goals
    ROUND(avg(m.home_goal+ m.away_goal), 2) AS avg_goals,
    -- Select & round the average total goals for the season
    (SELECT ROUND(avg(home_goal+ away_goal), 2)
     FROM match
     WHERE season = '2013/2014') AS overall_avg
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
-- Filter for the 2013/2014 season
WHERE m.season = '2013/2014'
GROUP BY league;

--previous exercise, you created a column to compare each league's average total goals to the overall average goals in the 2013/2014 season. In this exercise, you will add a column that directly compares these values by subtracting the overall average from the subquery.
SELECT
	-- Select the league name and average goals scored
	l.name AS league,
	ROUND(avg(m.home_goal + m.away_goal),2) AS avg_goals,
    -- Subtract the overall average from the league average
	ROUND(AVG(m.home_goal + m.away_goal)-
		(SELECT avg(home_goal + away_goal)
		 FROM match
         WHERE season='2013/2014'),2) AS diff
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
-- Only include 2013/2014 results
WHERE m.season='2013/2014'
GROUP BY l.name;

-- average number of goals scored in each stage to the total where number of average goals in a stage exceeded the overall average number of goals in the 2012/2013 match season.
SELECT
	-- Select the stage and average goals from s
	s.stage,
    ROUND(s.avg_goals,2) AS avg_goal,
    -- Select the overall average for 2012/2013
    (select avg(home_goal + away_goal) from match  WHERE season = '2012/2013') AS overall_avg
FROM
	-- Select the stage and average goals in 2012/2013 from match
	(SELECT
		 stage,
         avg(home_goal + away_goal) AS avg_goals
	 FROM match
	 WHERE season = '2012/2013'
	 GROUP BY stage) AS s
WHERE
	-- Filter the main query using the subquery
	s.avg_goals > (SELECT avg(home_goal + away_goal)
                    FROM match WHERE season = '2012/2013');

--3.Correlated subqueries

--examine matches with scores that are extreme outliers for each country -- above 3 times the average score!
SELECT
	-- Select country ID, date, home, and away goals from match
	main.country_id,
    date,
    main.home_goal,
    main.away_goal
FROM match AS main
WHERE
	-- Filter the main query by the subquery
	(home_goal + away_goal) >
        (SELECT AVG((sub.home_goal + sub.away_goal) * 3)
         FROM match AS sub
         -- Join the main query to the subquery in WHERE
         WHERE main.country_id = sub.country_id);

--In this exercise, you're going to add an additional column for matching to answer the question -- what was the highest scoring match for each country, in each season?
SELECT
	-- Select country ID, date, home, and away goals from match
	main.country_id,
    date,
    main.home_goal,
    main.away_goal
FROM match AS main
WHERE
	-- Filter for matches with the highest number of goals scored
	(home_goal + away_goal) =
        (SELECT max(sub.home_goal + sub.away_goal)
         FROM match AS sub
         WHERE main.country_id = sub.country_id
               AND main.season = sub.season);

--4. Nested subqueries

--examine the highest total number of goals in each season, overall, and during July across all seasons.
SELECT
	-- Select the season and max goals scored in a match
	season,
    max(home_goal+ away_goal) AS max_goals,
    -- Select the overall max goals scored in a match
   (SELECT max(home_goal + away_goal) FROM match) AS overall_max_goals,
   -- Select the max number of goals scored in any match in July
   (SELECT max(home_goal + away_goal)
    FROM match
    WHERE id IN (
          SELECT id FROM match WHERE EXTRACT(MONTH FROM date) = 07)) AS july_max_goals
FROM match
GROUP BY season;

--What's the average number of matches per season where a team scored 5 or more goals? How does this differ by country?
SELECT
	c.name AS country,
    -- Calculate the average matches per season
    AVG(outer_s.matches) AS avg_seasonal_high_scores
FROM country AS c
-- Left join outer_s to country
LEFT JOIN (
  SELECT country_id, season,
         COUNT(id) AS matches
  FROM (
    SELECT country_id, season, id
	FROM match
	WHERE home_goal >= 5 OR away_goal >= 5) AS inner_s
  -- Close parentheses and alias the subquery
  GROUP BY country_id, season) AS outer_s
ON c.id = outer_s.country_id
GROUP BY country;

--5. CTE

--list of countries and the number of matches in each country with more than 10 total goals. let's rewrite a similar query using a CTE.
-- Set up your CTE
with match_list as (
    SELECT
  		country_id,
  		id
    FROM match
    WHERE (home_goal + away_goal) >= 10)
-- Select league and count of matches from the CTE
SELECT
    l.name AS league,
    COUNT(match_list.id) AS matches
FROM league AS l
-- Join the CTE to the league table
LEFT JOIN match_list ON l.id = match_list.country_id
GROUP BY l.name;

--query for matches with 10 or more goals.
-- Set up your CTE
with match_list as (
  -- Select the league, date, home, and away goals
    SELECT
  		name AS league,
     	date,
  		m.home_goal,
  		m.away_goal,
       (m.home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN league as l ON m.country_id = l.id)
-- Select the league, date, home, and away goals from the CTE
SELECT league, date, home_goal, away_goal
FROM match_list
-- Filter by total goals
WHERE total_goals >=10;

--Average no of goals of teams played in August month of 2013/2014 seasons
-- Set up your CTE
with match_list as (
    SELECT
  		country_id,
  	   (home_goal + away_goal) AS goals
    FROM match
  	-- Create a list of match IDs to filter data in the CTE
    WHERE id IN (
       SELECT id
       FROM match
       WHERE season = '2013/2014' AND EXTRACT(MONTH FROM date) = 8))
-- Select the league name and average of goals in the CTE
SELECT
	name,
    avg(goals)
FROM league AS l
-- Join the CTE onto the league table
LEFT JOIN match_list ON l.id = match_list.country_id
GROUP BY l.name;

--6.How do you get both the home and away team names into one final query result?
--(i)using subquery'
SELECT
	m.date,
    -- Get the home and away team names
    hometeam,
    awayteam,
    m.home_goal,
    m.away_goal
FROM match AS m

-- Join the home subquery to the match table
LEFT JOIN (
  SELECT match.id, team.team_long_name AS hometeam
  FROM match
  LEFT JOIN team
  ON match.hometeam_id = team.team_api_id) AS home
ON home.id = m.id

-- Join the away subquery to the match table
LEFT JOIN (
  SELECT match.id, team.team_long_name AS awayteam
  FROM match
  LEFT JOIN team
  -- Get the away team ID in the subquery
  ON match.awayteam_id = team.team_api_id) AS away
ON away.id = m.id;

--(ii)correlated Subquery
SELECT
    m.date,
    (SELECT team_long_name
     FROM team AS t
     WHERE t.team_api_id = m.hometeam_id) AS hometeam,
    -- Connect the team to the match table
    (SELECT team_long_name
     FROM team AS t
     WHERE t.team_api_id = m.awayteam_id) AS awayteam,
    -- Select home and away goals
     home_goal,
     away_goal
FROM match AS m;

--(iii)cte
WITH home AS (
  SELECT m.id, m.date,
  		 t.team_long_name AS hometeam, m.home_goal
  FROM match AS m
  LEFT JOIN team AS t
  ON m.hometeam_id = t.team_api_id),
-- Declare and set up the away CTE
away as (
  SELECT m.id, m.date,
  		 t.team_long_name AS awayteam, m.away_goal
  FROM match AS m
  LEFT JOIN team AS t
  ON m.awayteam_id = t.team_api_id)
-- Select date, home_goal, and away_goal
SELECT
	home.date,
    home.hometeam,
    away.awayteam,
    home.home_goal,
    away.away_goal
-- Join away and home on the id column
FROM home
INNER JOIN away
ON home.id = away.id;

--7.Window functions

--calculates the average number of goals scored overall and then includes the aggregate value in each row using a window function.
SELECT
	-- Select the id, country name, season, home, and away goals
	m.id,
    c.name AS country,
    m.season,
	m.home_goal,
	m.away_goal,
    -- Use a window to include the aggregate average in each row
	avg(m.home_goal + m.away_goal) over() AS overall_avg
FROM match AS m
LEFT JOIN country AS c ON m.country_id = c.id;

--Complete the window function so it calculates the rank of average goals scored across all leagues in the database.
SELECT
	-- Select the league name and average goals scored
	name AS league,
    avg(m.home_goal + m.away_goal) AS avg_goals,
    -- Rank each league according to the average goals
    rank() over(order by AVG(m.home_goal + m.away_goal)) AS league_rank
FROM league AS l
LEFT JOIN match AS m
ON l.id = m.country_id
WHERE m.season = '2011/2012'
GROUP BY l.name
-- Order the query by the rank you created
ORDER BY league_rank;

--Complete the window function to rank each league from highest to lowest average goals scored.
SELECT
	-- Select the league name and average goals scored
	name AS league,
    avg(m.home_goal + m.away_goal) AS avg_goals,
    -- Rank each league according to the average goals
    rank() over(order by AVG(m.home_goal + m.away_goal) desc) AS league_rank
FROM league AS l
LEFT JOIN match AS m
ON l.id = m.country_id
WHERE m.season = '2011/2012'
GROUP BY l.name
-- Order the query by the rank you created
order by league_rank;

-- two window functions that calculate the home and away goal averages. Partition the window functions by season to calculate separate averages for each season.
SELECT
	date,
	season,
	home_goal,
	away_goal,
	CASE WHEN hometeam_id = 8673 THEN 'home'
		 ELSE 'away' END AS warsaw_location,
    -- Calculate the average goals scored partitioned by season
    avg(home_goal) over(partition by season) AS season_homeavg,
    avg(away_goal) over(partition by season) AS season_awayavg
FROM match
-- Filter the data set for Legia Warszawa matches only
WHERE
	hometeam_id = 8673
    OR awayteam_id = 8673
ORDER BY (home_goal + away_goal) DESC;

--calculate the average number home and away goals scored Legia Warszawa, and their opponents, partitioned by the month in each season.
SELECT
	date,
	season,
	home_goal,
	away_goal,
	CASE WHEN hometeam_id = 8673 THEN 'home'
         ELSE 'away' END AS warsaw_location,
	-- Calculate average goals partitioned by season and month
    avg(home_goal) over(partition by season,
         	EXTRACT(month FROM date)) AS season_mo_home,
    avg(away_goal)over(partition by season,
         	EXTRACT(month FROM date)) AS season_mo_away
FROM match
WHERE
	hometeam_id = 8673
    OR awayteam_id = 8673
ORDER BY (home_goal + away_goal) DESC;

-- calculating the running total of goals scored by the FC Utrecht when they were the home team during the 2011/2012 season.
SELECT
	date,
	home_goal,
	away_goal,
    -- Create a running total and running average of home goals
	SUM(home_goal) OVER(ORDER BY date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(home_goal) OVER(ORDER BY date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM match
WHERE
	hometeam_id = 9908
    AND season = '2011/2012';

-- query from the previous exercise by sorting the data set in reverse order and calculating a backward running total from the CURRENT ROW to the end of the data set
SELECT
	-- Select the date, home goal, and away goals
	date,
	home_goal,
	away_goal,
    -- Create a running total and running average of home goals
    SUM(home_goal) OVER(ORDER BY date DESC
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_total,
    AVG(home_goal) OVER(ORDER BY date DESC
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_avg
FROM match
WHERE
	awayteam_id = 9908
    AND season = '2011/2012';

--generate a list of matches in which Manchester United was defeated during the 2014/2015 English Premier League season.
-- Set up the home team CTE
with home as (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
		   WHEN m.home_goal < m.away_goal THEN 'MU Loss'
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id),
-- Set up the away team CTE
away as (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Loss'
		   WHEN m.home_goal < m.away_goal THEN 'MU Win'
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id)
-- Select columns and and rank the matches by goal difference
SELECT DISTINCT
    m.date,
    home.team_long_name AS home_team,
    away.team_long_name AS away_team,
    m.home_goal, m.away_goal,
    rank() over(order by ABS(home_goal - away_goal) desc) as match_rank
-- Join the CTEs onto the match table
FROM match AS m
left JOIN home ON m.id = home.id
left JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
      AND ((home.team_long_name = 'Manchester United' AND home.outcome = 'MU Loss')
      OR (away.team_long_name = 'Manchester United' AND away.outcome = 'MU Loss'));
