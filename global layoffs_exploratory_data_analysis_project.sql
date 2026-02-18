SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. standardize the data
-- 3. Null values or blank values
-- 4. Remove any columns

-- 1. Remove Duplicates

CREATE TABLE layoffs_staging
LIKE layoffs;


SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country,
funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'casper';

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country,
funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country,
funds_raised_millions) AS row_num
FROM layoffs_staging;


DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1 ;

SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM layoffs_staging2;

-- Standardizing data

SELECT company, TRIM(company)
FROM layoffs_staging2;

SET SQL_SAFE_UPDATES = 0;

UPDATE
SET company = TRIM(company);


UPDATE layoffs_staging2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;                      

UPDATE layoffs_staging2
SET country =  TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'united states%';     

-- formatting date
SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y')
;

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN  `date` DATE;     

SELECT *
FROM layoffs_staging2;


-- REMOVING DUPLICATES AFTER REALIZING ALL THE DATA GOT DUPLICATED DUE TO AN UNKNOWN CAUSE

WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions) AS row_num2
FROM layoffs_staging2)
SELECT *
FROM duplicate_cte
WHERE  row_num2 > 1;       

CREATE TABLE `layoffs_staging4` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` date DEFAULT NULL,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int DEFAULT NULL, `row_num2` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging4
WHERE row_num2 > 1;


INSERT INTO layoffs_staging4
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions) AS row_num2
FROM layoffs_staging2;

DELETE
FROM layoffs_staging4
WHERE row_num2 > 1;

SELECT *
FROM layoffs_staging4
WHERE row_num2 > 1;
                 
-- NULL AND BLANK VALUES

SELECT *
FROM layoffs_staging4
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;     
         
UPDATE layoffs_staging4
SET industry = NULL
WHERE industry = '';
         
SELECT *
FROM layoffs_staging4
WHERE industry IS NULL OR industry = '';

-- populating data
SELECT *;

FROM layoffs_staging4
WHERE company LIKE 'Bally%';

SELECT t1.industry, t2.industry
FROM layoffs_staging4 AS t1
JOIN layoffs_staging4 AS t2
  ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
UPDATE layoffs_staging4 AS t1
JOIN layoffs_staging4 AS t2
  ON t1.company = t2.company
  SET t1.industry = t2.industry
  WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging4;

SELECT *
FROM layoffs_staging4
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging4
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging4;


ALTER TABLE layoffs_staging4
DROP COLUMN row_num2;

-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging4;

SELECT company, MIN(total_laid_off), MAX(total_laid_off)
FROM layoffs_staging4
GROUP BY company
;
SELECT *
FROM layoffs_staging4
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;	

SELECT company, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging4;											

-- country with the highest total laid off
SELECT country, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY country
ORDER BY 2 DESC;	
-- insight;
-- The United States recorded the highest layoffs at 256,420 in three years between march 2020 and march 2023 .

SELECT *
FROM layoffs_staging4;		

-- year with the highest layoffs
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;	
-- insights
-- layoffs peaked in 2023 with 125,677 total layoffs accross countries and industries with just 3 months of data compared to previous years


SELECT stage, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY stage
ORDER BY 2 DESC;
-- insight
-- Late-stage companies experienced the highest layoffs peaking at post-IPO with 204,073 layoffs.

-- COMPANY WITH THE HIGHEST TOTAL LAID OFF
SELECT company, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY company
ORDER BY 2 DESC;
-- insight
-- Amazon has the highest total layoffs of 18,150

SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging4
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 2 DESC;
-- insight;
-- Monthly analysis revealed a spike in january 2023 with 84,714 layoffs.

-- rolling total of total_laid_off grouped by month
WITH rolling_total AS
(
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging4
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT 	`month`, total_off,
SUM(total_off) OVER(ORDER BY `month`) AS rolling_total
FROM rolling_total;
-- insight
-- total number of global layoffs between march 2020 and march 2023 = 382,820

SELECT company, SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY company
ORDER BY 2 DESC;

-- How much company layoff per year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH company_year ( company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY company, YEAR(`date`)
)
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
ORDER BY ranking ASC;

-- TOP 5 COMPANY WITH THE TOP RANK PER YEAR OF LAYOFFS
WITH company_year ( company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging4
GROUP BY company, YEAR(`date`)
), company_year_rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;

SELECT *
FROM layoffs_staging4;	