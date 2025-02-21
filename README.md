# **SQL - Layoffs Analysis**  

## **Project Overview**  
This project focuses on analyzing layoffs data using SQL. The dataset contains information about layoffs across various companies, industries, and countries. The goal is to clean, explore, and extract insights from the data to understand patterns and trends.

**Dataset Source & Credits:** [Layoffs-MySQL-YouTube-Series](https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv)

## **Objectives**  
- Clean and preprocess the dataset to remove inconsistencies.  
- Explore the dataset to understand its structure and key attributes.  
- Perform SQL queries to extract meaningful insights related to layoffs.  

## **Project Structure**  
### **1. Database Setup**  
- Created a new table to remove duplicate records.  
- Standardized data formats and handled null values. 

```sql
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
```

### **2. Data Exploration & Cleaning**  
- Checked for missing values and handled them accordingly.  
- Converted relevant data types to ensure accuracy.  
- Standardized country names and industry labels.  

```sql
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
```

### **3. Data Analysis & Findings**  
- **Top 5 companies with the highest layoffs:**  
  - Amazon (27,150), Google (12,000), Meta (11,000), Microsoft (10,000), Salesforce (8,000).  

```sql
    SELECT 
	company,
	SUM(total_laid_off)
    FROM layoffs
    WHERE total_laid_off IS NOT NULL
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 5;
```

- **Total layoffs per industry:**  
  - Consumer (44,782), Retail (43,613), Other (36,289), Transportation (31,248), Finance (28,344).  

```sql
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
```

- **Year with the highest total layoffs:**  
  - 2022 (160,661).  

```sql
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
```

- **Companies with layoffs in multiple years:**  
  - Swiggy, Salesforce, New Relic, ShareChat, Compass (3 years each).  

```sql
    SELECT
	company,
	COUNT(DISTINCT EXTRACT (YEAR FROM date)) AS years_layoffs
    FROM layoffs
    WHERE date IS NOT NULL
    GROUP BY 1
    HAVING COUNT(DISTINCT EXTRACT (YEAR FROM date)) > 1
    ORDER BY 2 DESC;
```

- **Percentage of layoffs per country:**  
  - Denmark (74%), Switzerland (50%), Russia (40%), Portugal (35%), Myanmar (33%).  

```sql
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
```

- **Month with the highest layoffs:**  
  - January (92,037 layoffs).  

```sql
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
```

- **Correlation between company size and layoffs:**  
  - Strong correlation (0.84).  

```sql
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
```

- **Industries with layoffs every year:**  
  - 17 industries including Construction, Finance, HR, Media, Retail, Security, Transportation, etc.  

```sql
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
```

- **Countries with the highest layoffs in tech:**  
  - United States (34,242), Singapore (2,929), China (1,475), United Kingdom (819), Israel (670).  

```sql
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
```

## **Findings**  
- 2022 had the highest layoffs across industries.  
- The Consumer and Retail industries were the most affected.  
- Layoffs were highest in January, indicating seasonal trends.  
- The U.S. experienced the most layoffs in the tech industry.  
- There is a strong correlation between company size and layoffs.   

## **Conclusion**  
Layoffs have been significant in certain industries, with notable spikes in 2022 and early 2023. The findings can help businesses and analysts understand employment trends and anticipate workforce challenges.  

## **Author**  
- [Engr. Kurt Avery Santos](https://www.github.com/KurtAvery25)


