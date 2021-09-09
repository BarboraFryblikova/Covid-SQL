-- TEMPLATE TABLE 1  - temp_cov19_eco_dem_project

-- spojeni dat z tabulek covid19_basic_differences, covid19_tests, countries, economies, life_expectancy

CREATE TABLE temp_cov19_eco_dem_project
WITH base AS (
	SELECT
		date,
		CASE WHEN country = 'Czechia' THEN 'Czech Republic' 
		     ELSE country END AS country,
		CASE WHEN confirmed IS NULL THEN 0 
		     ELSE confirmed END AS confirmed,
		CASE WHEN WEEKDAY (date) IN (5,6) THEN 1
		 	 ELSE 0 END AS weekend,
		CASE WHEN date BETWEEN '2020-01-01' AND '2020-02-29' THEN 3
		  	 WHEN date BETWEEN '2020-03-01' AND '2020-05-31' THEN 0
		  	 WHEN date BETWEEN '2020-06-01' AND '2020-08-31' THEN 1
		  	 WHEN date BETWEEN '2020-09-01' AND '2020-11-30' THEN 2
		  	 WHEN date BETWEEN '2020-12-01' AND '2020-12-31' THEN 3
		     ELSE 'nothing' END AS year_season 	 
	FROM covid19_basic_differences cbd
),
base2 AS (
	SELECT
		date,
		country,
		tests_performed
	FROM covid19_tests
	ORDER BY date
),
case1 AS (
	SELECT 
		country,
		population,
		population_density,
		median_age_2018
	FROM countries
),
case2 AS (	
	SELECT
		country,
		year,
		GDP,
		population,
		mortaliy_under5,
		CASE WHEN gini IS NULL THEN 0 ELSE gini END AS gini
	FROM economies
	WHERE year = 2019
),
case3 AS (
	SELECT 
		country,
		YEAR,
		life_expectancy
	FROM life_expectancy le 
	WHERE YEAR = 1965
),
case4 AS(
	SELECT 
		country,
		YEAR,
		life_expectancy
	FROM life_expectancy le 
	WHERE YEAR = 2015
)
SELECT
	base.date,
	base.country,
	base.confirmed,
	CASE WHEN base2.tests_performed IS NULL THEN 0
		     ELSE base2.tests_performed END AS tests_performed,
	base.weekend,
	base.year_season,
	case1.population_density,
	ROUND(case2.GDP / case2.population, 2) AS GDP_per_resident,
	case2.mortaliy_under5,
	case1.median_age_2018,
	CASE WHEN case2.gini IS NULL THEN 0 
	     ELSE case2.gini END AS gini,
	case3.life_expectancy AS life_exp_1965,
	case4.life_expectancy AS life_exp_2015,
	case4.life_expectancy - case3.life_expectancy AS life_exp_diff
FROM base AS base
LEFT JOIN base2 AS base2
  ON base.date = base2.date
 AND base.country = base2.country
LEFT JOIN case1 AS case1 
  ON base.country = case1.country
LEFT JOIN case2 AS case2 
  ON base.country = case2.country
LEFT JOIN case3 AS case3
  ON base.country = case3.country
LEFT JOIN case4 AS case4
  ON base.country = case4.country
;


-- TEMPLATE TABLE 2 - temp_religion_project

-- uprava dat z tabulky religions do potrebne podoby 

CREATE TABLE temp_religion_project
WITH d1  AS(
	SELECT 
		country,
		SUM(population) AS population
	FROM religions r 
	WHERE `year` = '2020'
	GROUP BY country
),
Christianity AS (
	SELECT 
		country,
		population,
		religion 
	FROM religions
	WHERE year = '2020'
	  AND religion = 'Christianity'	
),
Islam AS(	
	SELECT 
		country,
		population,
		religion 
	FROM religions
	WHERE year = '2020'
	  AND religion = 'Islam'
),
Buddhism AS(	
	SELECT 
		country,
		population,
		religion 
	FROM religions
	WHERE year = '2020'
	  AND religion = 'Buddhism'
),
Folk_Religions AS(	
	SELECT 
		country,
		population,
		religion 
	FROM religions
	WHERE year = '2020'
	  AND religion = 'Folk Religions'
),
Hinduism AS(	
	SELECT 
		country,
		population,
		religion 
	FROM religions
	WHERE year = '2020'
	  AND religion = 'Hinduism'
),
Judaism AS(	
	SELECT 
		country,
		population,
		religion 
	FROM religions
	WHERE year = '2020'
	  AND religion = 'Judaism'
),
Other_Religions AS(	
	SELECT 
		country,
		population,
		religion 
	FROM religions
	WHERE year = '2020'
	  AND religion = 'Other Religions'
)
SELECT 
	d1.country,
	ROUND(c.population/d1.population, 5) * 100 AS christianity_perc,
	ROUND(i.population/d1.population, 5) * 100 AS islam_perc,
	ROUND(b.population/d1.population, 5) * 100 AS buddhism_perc,
	ROUND(f.population/d1.population, 5) * 100 AS folk_rel_perc,
	ROUND(h.population/d1.population, 5) * 100 AS hinduism_perc,
	ROUND(j.population/d1.population, 5) * 100 AS judaism_perc,
	ROUND(o.population/d1.population, 5) * 100 AS other_rel_perc
FROM d1 AS d1 
LEFT JOIN Christianity AS c
  ON d1.country = c.country
LEFT JOIN Islam AS i 
  ON d1.country = i.country
LEFT JOIN Buddhism AS b 
  ON d1.country = b.country
LEFT JOIN Folk_religions AS f 
  ON d1.country = f.country
LEFT JOIN Hinduism AS h 
  ON d1.country = h.country
LEFT JOIN Judaism AS j 
  ON d1.country = j.country
LEFT JOIN Other_Religions AS o 
  ON d1.country = o.country
;


-- TEMPLATE TABLE 3 - temp_weather_project

-- spojeni a uprava dat z tabulek countries a weather

CREATE TABLE temp_weather_project AS
WITH w1 AS (
	SELECT 
		capital_city,
		country
	FROM countries c 
	WHERE capital_city IS NOT NULL
	ORDER BY capital_city 
),
w2 AS (
	SELECT 
		SUBSTRING(date,1,10) AS datum,
		city,
		AVG(CAST(SUBSTRING_INDEX(temp, ' ', 1) AS INT)) AS temp_day
	FROM weather w
	WHERE time BETWEEN '06:00' AND '18:00'
	  AND city IS NOT NULL
	GROUP BY datum,
			 city
),
w3 AS (
	SELECT 
		SUBSTRING(date,1,10) AS datum,
		city,
		SUM(CASE WHEN rain = '0.0 mm' THEN 0 ELSE 3 END) AS hours_rain_day
	FROM weather w
	WHERE city IS NOT NULL
	GROUP BY datum,
			 city
),
w4 AS (
SELECT
	SUBSTRING(date,1,10) AS datum,
	city,
	MAX(CAST((SUBSTRING_INDEX(wind,' ',1)) AS INT)) AS wind_km_per_h
FROM weather
WHERE date BETWEEN '2020-01-01 00:00:00' AND '2020-12-31 00:00:00'
  AND city IS NOT NULL 
GROUP BY datum,
		 city
)
SELECT 
	w2.datum AS date,
	w1.country,
	w1.capital_city AS city,
	w2.temp_day,
	w3.hours_rain_day,
	w4.wind_km_per_h
FROM countries AS w1
LEFT JOIN w2 AS w2
	   ON w1.capital_city = w2.city
LEFT JOIN w3 AS w3
 	   ON w1.capital_city = w3.city
 	  AND w2.datum = w3.datum
LEFT JOIN w4 AS w4
	   ON w1.capital_city = w4.city
	  AND w2.datum = w4.datum
;


-- FINAL TABLE

-- spojeni template tabulek do vysledne tabulky

CREATE TABLE t_barbora_fryblikova_projekt_SQL_final AS
SELECT 
 	temp1.date AS date,
	temp1.country AS country,
	temp1.confirmed AS confirmed,
	temp1.tests_performed AS tests_performed,
	temp1.weekend AS weekend,
	temp1.year_season AS year_season,
	ROUND(temp1.population_density,2) AS population_density,
	ROUND(temp1.GDP_per_resident,2) AS GDP_per_resident,
	temp1.mortaliy_under5 AS mortaliy_under5,
	temp1.median_age_2018 AS median_age_2018,
	temp1.gini AS gini,
	temp1.life_exp_1965 AS life_exp_1965,
	temp1.life_exp_2015 AS life_exp_2015,
	temp1.life_exp_diff AS life_exp_diff,
	temp2.christianity_perc AS christianity_perc,
	temp2.islam_perc AS islam_perc,
	temp2.buddhism_perc AS buddhism_perc,
	temp2.folk_rel_perc AS folk_rel_perc,
	temp2.hinduism_perc AS hinduism_perc,
	temp2.judaism_perc AS judaism_perc,
	temp2.other_rel_perc AS other_rel_perc,
	temp3.temp_day AS temp_day,
	temp3.hours_rain_day AS hours_rain_day,
	temp3.wind_km_per_h	AS wind_km_per_h	
FROM temp_cov19_eco_dem_project AS temp1
LEFT JOIN temp_religion_project AS temp2
       ON temp1.country = temp2.country 
LEFT JOIN temp_weather_project AS temp3
       ON temp1.date = temp3.date
      AND temp1.country = temp3.country
;

