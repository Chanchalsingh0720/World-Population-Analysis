CREATE DATABASE WORLDPOPULATIONANALYSIS

USE WorldPopulationAnalysis


SELECT * FROM WORLDPOPULATION
	-- Checking for Duplicates
	SELECT * FROM
	(
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY COUNTRY ORDER BY COUNTRY) AS ROW_NUM
	FROM WorldPopulation) AS X
	WHERE
		ROW_NUM>1;
	
	
	--  % Increase In population From Previous Population census
	
	SELECT
		Country,
		pop1980,
		pop2000,
		pop2010,
		pop2022,
		cast(100.0*(pop2000 - pop1980)/ pop1980 as decimal(18,2)) AS '%_CHANGE_1980_TO_2000',
		cast(100*(pop2010 - pop2000)/ pop2000 as decimal(18,2)) AS '%_CHANGE_2000_TO_2010',
		cast(100.0*(pop2022 - pop2010)/ pop2010 as decimal(18,2)) AS '%_CHANGE_2010_TO_2022'
	FROM
		WorldPopulation;
	
	
	/*Top 3 Countries With Highest Population In 1980, 2000, 2010, 2022 */

	WITH CTE AS(
		SELECT TOP 3
			'1980' as year, Country AS Top3_Most_Populated_country, pop1980 AS POPULATION
		from WorldPopulation
		ORDER BY pop1980 DESC ),
	
	CTE2 AS(
		SELECT TOP 3
			'2000' as year, Country AS Top3_Most_Populated_country, pop2000 AS POPULATION
		from WorldPopulation
		ORDER BY pop2000 DESC ),
	
	CTE3 AS(
		SELECT TOP 3 
			'2010' AS YEAR, Country AS Top3_Most_Populated_country, pop2010 AS POPULATION
		FROM WorldPopulation
		ORDER BY pop2010 DESC ),
	
	CTE4 AS(
		SELECT
		TOP 3
			'2022' AS YEAR, Country AS Top3_Most_Populated_country, pop2022 AS POPULATION
		FROM WorldPopulation
		ORDER BY pop2022 DESC )	

	SELECT * FROM CTE
	UNION
	SELECT * FROM CTE2
	UNION
	SELECT * FROM CTE3
	UNION
	SELECT * FROM CTE4;
	
	
	-- Showing World's Population In All Population Census Years
	WITH CTE AS (
		SELECT '1980' AS Year, SUM(pop1980) AS World_Population
		FROM WorldPopulation
		UNION ALL
		SELECT '2000' AS Year, SUM(pop2000) AS World_Population
		FROM WorldPopulation
		UNION ALL
		SELECT '2010' AS Year, SUM(pop2010) AS World_Population
		FROM WorldPopulation
		UNION ALL
		SELECT '2022' AS Year, SUM(pop2022) AS World_Population
		FROM WorldPopulation
	),
	CTE2 AS (
		SELECT *, 
			LAG(World_Population, 1) OVER (ORDER BY Year) AS Previous_Year_Population
		FROM CTE
	)
	SELECT 
		Year, 
		World_Population, 
		CASE 
			WHEN Previous_Year_Population IS NULL THEN '0'
			ELSE CAST(((World_Population * 1.0 - Previous_Year_Population) / Previous_Year_Population * 100) AS DECIMAL(10, 2))
		END AS Population_Change_Percentage
	FROM CTE2;

	
	/*Showing Growth Rate Of World Population In Each Census Year*/

	with CTE as
	(
	SELECT
	    SUM(pop1980) AS POP_1980,
	    SUM(pop2000) AS POP_2000,
	    SUM(pop2010) AS POP_2010,
	    SUM(pop2022) AS POP_2022
	FROM WorldPopulation),
	CTE2 AS(
		SELECT '2022' AS YEAR, POP_2022 AS POPULATION FROM CTE UNION
		SELECT '2010' AS YEAR, POP_2010 AS POPULATION FROM CTE UNION
		SELECT '2000' AS YEAR, POP_2000 AS POPULATION FROM CTE UNION
		SELECT '1980' AS YEAR, POP_1980 AS POPULATION FROM CTE ),
	CTE3 AS(
		SELECT *,
			LEAD(POPULATION,1,0) OVER(ORDER BY YEAR DESC) AS PREVIOUS_YEAR_POPULATION
		FROM CTE2
	)
		SELECT *,
		CASE 
			WHEN PREVIOUS_YEAR_POPULATION = 0 THEN NULL
			ELSE CAST(100.0*(POPULATION - PREVIOUS_YEAR_POPULATION) / PREVIOUS_YEAR_POPULATION AS DECIMAL(18,2)) 
			END AS GROWTH_RATE			
		FROM
			CTE3

	
	-- Showing top 10 Densly Populated countries Over in 2022
	
	SELECT 
		top 10
		Country,
		CAST(pop2022/landAreaKm AS decimal(18,2)) AS Population_Density_2022
	FROM 
		WorldPopulation
	order by
		Population_Density_2022 desc
	
	
	--  Top 10 Countries With Rapid Population Growth in years from 1980 to 2022
	
	SELECT
		TOP 10
		Country,
		pop1980,
		pop2022,
		cast(100.0 * (pop2022-pop1980)/pop1980 as decimal(18,2)) AS GROWTH_RATE_PERCENTAGE
	FROM
		WorldPopulation
	ORDER BY
		GROWTH_RATE_PERCENTAGE DESC
	

	-- Showing countries with Population Decline in years from 1980-2022
	
	SELECT
		Country,
		pop1980,
		pop2022,
		CAST(100*(pop2022-pop1980)/pop1980 AS DECIMAL(18,2)) AS DECLINE_RATE_PERCENTAGE
	FROM
		WorldPopulation
	ORDER BY
		DECLINE_RATE_PERCENTAGE ASC
	
	
	-- Showing Top 10 Countries Which are Expected to Grow Rapidly by 2050

	SELECT
		top 10
		Country,
		pop2022,
		pop2050,
		CAST( 100.0* (pop2050 - pop2022) / pop2022 AS decimal(18,2)) AS GROWTH_RATE_PERCENTAGE
	FROM
		WorldPopulation
	ORDER BY
		GROWTH_RATE_PERCENTAGE DESC
	
	
	-- Showing Top 10 Countries Which are Expected to Decline Rapidly by 2050
	
	SELECT TOP 10
		COUNTRY,
		pop2022,
		pop2050,
		CAST(100*(pop2050 - pop2022)/pop2022 AS decimal(18,2)) AS DECLINE_RATE_PERCENTAGE
	FROM
		WorldPopulation
	ORDER BY
		DECLINE_RATE_PERCENTAGE ASC;

	
	-- Showing the Population Estimation of 3 Most Populous Country By 2030 & 2050 i.e. China, India, US

	WITH CTE AS (
		SELECT
			Country,
			pop2022 AS POP_2022,
			pop2030 AS POP_2030,
			pop2050 AS POP_2050
		FROM
			WorldPopulation
		WHERE
			Country IN ('INDIA', 'CHINA', 'UNITED STATES')
	),
	CTE2 AS (
		SELECT Country, '2022' AS YEAR, POP_2022 AS POPULATION FROM CTE
		UNION
		SELECT Country, '2030' AS YEAR, POP_2030 AS POPULATION FROM CTE
		UNION
		SELECT Country, '2050' AS YEAR, POP_2050 AS POPULATION FROM CTE
	),
	CTE3 AS (
		SELECT *,
			LEAD(POPULATION, 1, 0) OVER(PARTITION BY Country ORDER BY YEAR DESC) AS PREVIOUS_YEAR_POPULATION
		FROM CTE2
	)
	SELECT
		Country,
		YEAR,
		POPULATION,
		CASE
			WHEN PREVIOUS_YEAR_POPULATION = 0 THEN NULL
			ELSE ROUND(100 * (POPULATION - PREVIOUS_YEAR_POPULATION) / PREVIOUS_YEAR_POPULATION, 2)
		END AS POPULATION_GROWTH_RATE
	FROM CTE3;


	-- Showing 10 Most Populous Expected Countries By 2050

	SELECT
		TOP 10
		Country,
		pop2050 AS POPULATION_BY_2050
	FROM
		WorldPopulation
	ORDER BY
		POPULATION_BY_2050 DESC
	
	-- Showing 10 Most Populous Countries In 2022

	SELECT
		TOP 10
		Country,
		pop2022
	FROM
		WorldPopulation
	ORDER BY
		pop2022 DESC

	
	-- Expected Population Of World By 2030 & 2050

	SELECT
		SUM(pop2030) AS WORLD_POPULATION_2030,
		SUM(POP2050) AS WORLD_POPULATION_2050
	FROM
		WorldPopulation
