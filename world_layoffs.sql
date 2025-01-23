-- Data Cleaning
SELECT *
FROM world_layoffs.layoffs;

-- creating a secondary table to work on 
CREATE TABLE layoff_staging
LIKE layoffs;

INSERT layoff_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoff_staging;

-- Check and remove duplicates by assigning row numbers
with duplicates as 
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoff_staging
)
SELECT *
FROM duplicates
where row_num > 1;

-- creating a new table without duplicates
CREATE TABLE `layoff_cleaned` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoff_cleaned
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoff_staging;

SET SQL_SAFE_UPDATES = 0;

-- all the duplicates are being deleted.
DELETE
FROM layoff_cleaned
WHERE row_num > 1;

SELECT *
FROM layoff_cleaned;

SELECT *
FROM layoff_cleaned
WHERE row_num > 1;
SET SQL_SAFE_UPDATES = 1;

-- Standardizing 
SELECT company, trim(company), industry, TRIM(industry) # removing extra spaces around the string
from layoff_cleaned;

SET SQL_SAFE_UPDATES = 0;
update layoff_cleaned
set company = trim(company);

update layoff_cleaned
set industry = trim(industry);

select distinct industry
from layoff_cleaned
order by 1;

select *
from layoff_cleaned
where industry like 'Crypto%';

update layoff_cleaned
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct country
from layoff_cleaned
order by 1;

update layoff_cleaned
set country = trim(trailing '.' from country)
where country like 'United States%';

-- let's change the date column from text to date&time formt.
select `date`, str_to_date(`date`,'%m/%d/%Y')
from layoff_cleaned;

update layoff_cleaned
set `date` = str_to_date(`date`,'%m/%d/%Y');

select `date`
from layoff_cleaned;

select `date`
from layoff_cleaned
where `date` is null;

ALTER  TABLE layoff_cleaned
MODIFY COLUMN `date` DATE;

-- dealing with null and unknown values
select distinct *
from layoff_cleaned;

select distinct company, industry
from layoff_cleaned;


UPDATE layoff_cleaned
SET industry = NULL
WHERE REPLACE(industry, ' ', '') = '';

SELECT t1.industry, t2.industry
FROM layoff_cleaned AS t1
JOIN layoff_cleaned AS t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR TRIM(t1.industry) = '')
AND t2.industry IS NOT NULL;

update layoff_cleaned AS t1
JOIN layoff_cleaned AS t2
	ON TRIM(t1.company) = TRIM(t2.company)
set t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

select *
from layoff_cleaned
where industry is NULL;

-- Let's get rid off unwanted column
select *
from layoff_cleaned
where total_laid_off is NULL and percentage_laid_off is NULL;

# We cant populate these two coulumn as there is no information present at all, percentage could be caluclated at-least if total laid off is 
# given, so it better to just get rid of these rows which has neither percentage nor total laid off given.

DELETE 
from layoff_cleaned
where total_laid_off is NULL and percentage_laid_off is NULL;

# we can also get rid of row columns as it is not required for us
ALTER TABLE layoff_cleaned
DROP COLUMN row_num;

select * 
from layoff_cleaned;