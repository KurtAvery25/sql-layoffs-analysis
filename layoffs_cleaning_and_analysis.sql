-- SQL_Layoffs_Analysis

-- Database Setup

CREATE DATABASE sql_project_1;

DROP TABLE IF EXISTS layoffs;
CREATE TABLE layoffs 
	(
		company	TEXT,
		location TEXT,	
		industry TEXT,	
		total_laid_off FLOAT,	
		percentage_laid_off DECIMAL,	
		date DATE,
		stage TEXT,	
		country TEXT,	
		funds_raised_millions INT
	);


COPY layoffs FROM 'D:\Data Analyst Portfolios\sql-layoffs-cleaning-and-analysis\layoffs.csv'
WITH (FORMAT csv, HEADER true, NULL 'NULL')


-- Data Cleaning and Exploration

CREATE TABLE new_layoffs AS
SELECT DISTINCT * FROM layoffs;

DROP TABLE layoffs;
ALTER TABLE new_layoffs RENAME to layoffs;

SELECT total_laid_off FROM layoffs
WHERE total_laid_off <> FLOOR(total_laid_off); -- Check for decimal values

ALTER TABLE layoffs
ALTER COLUMN total_laid_off TYPE INTEGER 
USING total_laid_off::INTEGER;

SELECT * FROM layoffs
WHERE industry = 'Unknown'

SELECT COUNT(*) FROM layoffs

UPDATE layoffs
SET country = 'United States'
WHERE country = 'United States.';


-- Data Analysis

-- 1. Write an SQL query to find the top 5 companies with the highest number of layoffs.

SELECT 
	company,
	SUM(total_laid_off)
FROM layoffs
WHERE total_laid_off IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 2. Write an SQL query to determine the total layoffs per industry.

UPDATE layoffs
SET industry = NULL
WHERE industry = '';

UPDATE layoffs
SET industry = 'Unknown'
WHERE industry IS NULL;

SELECT 
	industry,
	SUM(total_laid_off) AS total_layoffs
FROM layoffs
WHERE total_laid_off IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Write an SQL query to find the year with the highest total layoffs.

SELECT	
	EXTRACT (YEAR FROM date) AS year,
	SUM(total_laid_off) as total_layoffs
FROM layoffs
WHERE 
	total_laid_off IS NOT NULL
	AND 
	date IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 4. Write an SQL query to identify companies that had layoffs in multiple years.

SELECT
	company,
	COUNT(DISTINCT EXTRACT (YEAR FROM date)) AS years_layoffs
FROM layoffs
WHERE date IS NOT NULL
GROUP BY 1
HAVING COUNT(DISTINCT EXTRACT (YEAR FROM date)) > 1
ORDER BY 2 DESC;

-- 5. Write an SQL query to calculate the percentage of layoffs per country.

SELECT
	country,
	SUM(total_laid_off) AS total_layoffs,
	ROUND(SUM((total_laid_off)/(NULLIF(percentage_laid_off, 0)))) AS total_employees,
	ROUND((SUM(total_laid_off) * 100)/((SUM((total_laid_off)/NULLIF(percentage_laid_off, 0)))),2) AS total_percentage
FROM layoffs
WHERE total_laid_off IS NOT NULL 
	AND
	percentage_laid_off IS NOT NULL
GROUP BY 1
ORDER BY 4 DESC;


-- 6. Write an SQL query to find the month with the highest layoffs across all years.

SELECT
	EXTRACT (MONTH FROM date) AS month,
	SUM(total_laid_off) AS total_layoffs
FROM layoffs
WHERE 
	total_laid_off IS NOT NULL 
	AND
	EXTRACT (YEAR FROM date) IS NOT NULL
	AND
	EXTRACT (MONTH FROM date) IS NOT NULL
	AND
	date IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 7. Write an SQL query to check if there is a correlation between company size and layoffs.

WITH company_layoffs AS 
	(
		SELECT
			company,
			SUM(total_laid_off) AS total_layoffs,
			SUM(ROUND((total_laid_off)/NULLIF(percentage_laid_off, 0))) AS total_employees
		FROM layoffs
		WHERE ROUND((total_laid_off)/NULLIF(percentage_laid_off, 0)) IS NOT NULL
		GROUP BY 1
		ORDER BY 2 DESC
	)
	
SELECT corr(total_layoffs, total_employees) AS correlation
FROM company_layoffs

-- 8. Write an SQL query to list the industries that had layoffs every year.

SELECT DISTINCT(EXTRACT (YEAR FROM date)) AS year -- Check unique years available
FROM layoffs
WHERE EXTRACT (YEAR FROM date) IS NOT NULL
ORDER BY 1 DESC;

SELECT 
	industry,
	COUNT(DISTINCT(EXTRACT (YEAR FROM date))) AS year
FROM layoffs
GROUP BY 1
HAVING COUNT(DISTINCT(EXTRACT (YEAR FROM date))) = 4;

-- 9. Write an SQL query to identify the country with the highest layoffs in tech companies.

SELECT
	country,
	SUM(total_laid_off) AS total_layoffs
FROM layoffs
WHERE industry IN 
	(
		'Crypto',
		'Crypto Currency',
		'Data',
		'Hardware',
		'Product',
		'Infrastructure',
		'Security'
	)
	AND
	total_laid_off IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;



