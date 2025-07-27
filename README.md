##SQL Exploratory Data Analysis: Global Layoffs
(See 'Exploratory_Data_Analysis.sql')

Project Overview

This project performs an exploratory data analysis (EDA) on a cleaned dataset of global company layoffs. The primary goal was to explore the data to identify trends, uncover patterns, and derive insights into the layoff landscape between 2020 and 2023 without a predefined hypothesis. This project is the second part of a two-stage process, using the cleaned data from the SQL Data Cleaning Project.

Dataset
The analysis was conducted on a cleaned dataset containing information about company layoffs, including company name, location, industry, number of employees laid off, date, and funding raised.

Tools Used
SQL (MySQL Workbench): Used for all data querying, transformation, and analysis.

Exploratory Analysis & Insights
The exploration was guided by a series of questions to understand the magnitude and distribution of layoffs across different dimensions.

1. High-Level Overview
First, I looked at the overall scale of the layoffs.

Maximum Layoffs: The single largest layoff event involved 12,000 employees.

Company Closures: Several companies laid off 100% of their workforce, indicating they went out of business.

Timeline: The dataset covers the period from March 2020 to March 2023.

-- Looking at the highest layoff and percentage layoffs.
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Companies that laid off 100% of their staff
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

2. Layoffs by Industry, Country, and Company Stage
I aggregated the data to see which sectors were most affected.

Top Industries: The Consumer and Retail industries saw the highest number of layoffs, followed closely by the Transportation and Finance sectors.

Top Countries: The United States had the highest number of total layoffs by a significant margin.

Company Stage: Post-IPO companies (large, publicly traded corporations) accounted for the largest number of layoffs.

-- Layoffs by Industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Layoffs by Country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Layoffs by Company Stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

3. Layoffs Over Time (Trend Analysis)
To understand the timeline of events, I analyzed layoffs by year and created a rolling monthly total.

Yearly Trends: Layoffs peaked significantly in 2022, with the first few months of 2023 showing a continued high rate.

Rolling Monthly Total: A Common Table Expression (CTE) and a Window Function were used to calculate the cumulative sum of layoffs month-over-month, showing a steep increase in the rate of layoffs starting in 2022.

-- Total layoffs per year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Calculating the rolling total of layoffs by month
WITH Rolling_Total AS
(
    SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`,1,7) IS NOT NULL
    GROUP BY `MONTH`
    ORDER BY 1
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

4. Ranking Companies by Layoffs Per Year
Finally, I wanted to identify which specific companies had the highest number of layoffs each year.

Top Companies by Year: Using a CTE and the DENSE_RANK() window function, I ranked the top 5 companies with the most layoffs for each year. This revealed different major companies leading the layoffs in different years, such as Uber in 2020 and Meta in 2022.

-- Ranking the top 5 companies by layoffs for each year
WITH company_year (company, years, total_laid_off) AS
(
    SELECT company, YEAR(`date`), SUM(total_laid_off)
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
), Company_year_rank AS
(
    SELECT *,
    DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
    FROM company_year
    WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE Ranking <= 5;

Key SQL Concepts Applied
Aggregate Functions: SUM(), MAX(), MIN()

Data Grouping: GROUP BY to aggregate data by different categories.

Sorting: ORDER BY to present data logically.

Date/String Manipulation: YEAR(), SUBSTRING() to extract parts of a date.

Common Table Expressions (CTEs): WITH ... AS to create temporary, readable result sets for complex queries.

Window Functions: SUM() OVER() for rolling totals and DENSE_RANK() OVER(PARTITION BY ...) for ranking within specific categories.

Conclusion
This exploratory analysis provided a comprehensive overview of the layoff trends across various sectors and time periods. The insights reveal the significant impact of economic factors on the job market, particularly in the tech, retail, and consumer industries, with a notable acceleration of layoffs in 2022 and 2023.

This project was completed as part of the Alex The Analyst SQL Bootcamp.
