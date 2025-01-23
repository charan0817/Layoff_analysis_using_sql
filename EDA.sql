-- Eploratory Data Ananlysis
select * 
from layoff_cleaned;
 
-- Let's look at the companies whith most number of layoffs
select company, sum(total_laid_off)
from layoff_cleaned
group by company
order by 2 desc;

-- Similary let's check which idustries laid off their employees the most
select industry, sum(total_laid_off)
from layoff_cleaned
group by industry
order by 2 desc;

select company, sum(total_laid_off)
from layoff_cleaned
group by company
order by 2 desc;



-- companies which completly laid off their employees
select company, industry, percentage_laid_off
from layoff_cleaned
where percentage_laid_off = 1;




-- Let's caluclate the rolling total of layoffs over every month
with Rolling_total as (
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_layoffs
from layoff_cleaned
where substring(`date`,1,7) is not NULL
group by `month`
order by 1 ASC
)
select `month`,sum(total_layoffs)  over(order by `month`) as rolling_total
from Rolling_total;



-- Top 5 companies with the highest layoffs in each year.
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoff_cleaned
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 5
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

select country, sum(total_laid_off)
from layoff_cleaned
group by country
order by 2 desc;




-- Top total layoffs around the world each year
WITH country_ranking AS (
    SELECT 
        country, 
        YEAR(`date`) AS year, 
        SUM(total_laid_off) AS total_layoffs,
        RANK() OVER (PARTITION BY YEAR(`date`) ORDER BY SUM(total_laid_off) DESC) AS ranking
    FROM layoff_cleaned
    WHERE `date` IS NOT NULL
    GROUP BY country, YEAR(`date`)
)
SELECT 
    country, 
    total_layoffs, 
    year, 
    ranking
FROM country_ranking
WHERE ranking <= 5
ORDER BY year ASC, total_layoffs DESC;





-- Distribution of total layoffs over each month
SELECT 
    YEAR(date) AS year,
    MONTH(date) AS month,
    SUM(total_laid_off) AS total_layoffs
FROM layoff_cleaned
GROUP BY YEAR(date), MONTH(date)
ORDER BY total_layoffs desc;

