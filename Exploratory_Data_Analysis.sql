-- Exploratory Data Analysis --
-- GOAL: Explore the layoff data and uncover insights without a strict goal in mind, just to explore the data. 
 
 SELECT *
 FROM layoffs_staging2;
 
-- Looking at the highest layoff and percentage layoffs. 
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

 SELECT *
 FROM layoffs_staging2
 WHERE percentage_laid_off = 1
 ORDER BY funds_raised_millions DESC;
 
 SELECT company, SUM(total_laid_off)
 FROM layoffs_staging2
 GROUP BY company
 ORDER BY 2 DESC;
 
 SELECT MIN(`date`), MAX(`date`)
 FROM layoffs_staging2;
 
 -- Looking at specific companies that got hit by layoffs hardest
 SELECT industry, SUM(total_laid_off)
 FROM layoffs_staging2
 GROUP BY industry
 ORDER BY 2 DESC;
 
  SELECT country, SUM(total_laid_off)
 FROM layoffs_staging2
 GROUP BY country
 ORDER BY 2 DESC;
 
 -- Looking at the total layoffs for each year.
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
 
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- Here we used substring to pinpoint the month part of the date.
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, sum(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1
;

-- Below we used the data above and created a cte to then get a rolling total column. 
	-- This adds each consecutive row on top of each other. 
-- Again, the substring here is used just to get the month only, from the XXXX-XX-XX format
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, sum(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1
)
SELECT `Month`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Looking at companies and years and the amount they laid off. 
 SELECT company, SUM(total_laid_off)
 FROM layoffs_staging2
 GROUP BY company
 ORDER BY 2 DESC;

 SELECT company, YEAR(`date`), SUM(total_laid_off)
 FROM layoffs_staging2
 GROUP BY company, YEAR(`date`)
 ORDER BY 3 DESC;


-- Below is a cte where we are looking at the company, the year and the total laid off
	-- We then are ranking with dense rank which counts ties as one place (e.g. 4th, 4th then 5th)
    -- The ranking is partitioned by years so it resets when it goes from 2022 to 2023
WITH company_year (company, years, total_laid_off) AS
(
 SELECT company, YEAR(`date`), SUM(total_laid_off)
 FROM layoffs_staging2
 GROUP BY company, YEAR(`date`)
 ORDER BY 3 DESC
 ), Company_year_rank AS
 (SELECT *, 
 DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
 FROM company_year
 WHERE years IS NOT NULL
 )
 
 SELECT * 
 FROM company_year_rank
 WHERE Ranking  <=5;





