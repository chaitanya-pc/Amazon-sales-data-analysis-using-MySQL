create database amazon_sales;
use amazon_sales;
select * from amazon;
ALTER TABLE amazon
RENAME COLUMN `Invoice ID` TO Invoice_ID,
RENAME COLUMN `Product line` TO Product_line,
RENAME COLUMN `Unit price` TO Unit_price,
RENAME COLUMN `Tax 5%` TO Vat
;
ALTER TABLE amazon
RENAME COLUMN `gross margin percentage` TO gross_margin_percentage,
RENAME COLUMN `gross income` TO gross_income
;

--  Feature Engineering
/* Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening.
 This will help answer the question on which part of the day most sales are made.*/
 
 ALTER TABLE amazon
ADD COLUMN timeofday VARCHAR(10);

UPDATE amazon
SET timeofday = CASE
                    WHEN TIME(Time) BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
                    WHEN TIME(Time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
                    ELSE 'Evening'
                END;

--  Add a new column named dayname to extract the day of the week:

ALTER TABLE amazon
ADD COLUMN dayname VARCHAR(10);

UPDATE amazon
SET dayname = UPPER(DATE_FORMAT(Date, '%a'));

--  Add a new column named monthname to extract the month of the year:

ALTER TABLE amazon
ADD COLUMN monthname VARCHAR(10);

UPDATE amazon
SET monthname = UPPER(DATE_FORMAT(Date, '%b'));

select * from amazon;

-- 1. What is the count of distinct cities in the dataset?

select count(distinct city) as no_of_cities from amazon;

-- 2. For each branch, what is the corresponding city?

select branch , city from amazon
group by branch, city;

-- 3. What is the count of distinct product lines in the dataset?
select count(distinct product_line)  as distinct_product_lines from amazon;

-- 4. Which payment method occurs most frequently?
select payment from amazon
group by payment
order by payment desc
limit 1;

-- 5. Which product line has the highest sales?
select product_line , round(sum(total),2) as total_sales from amazon
group by product_line
order by total_sales desc
limit 1;

-- 6 . How much revenue is generated each month?
select monthname ,round(sum(total),2) as total_sales from amazon
group by monthname;

-- 7. In which month did the cost of goods sold reach its peak?
select monthname , round(sum(cogs),2) as total_cogs from amazon
group by monthname
order by total_cogs desc
limit 1;

-- 8. Which product line generated the highest revenue?
select product_line ,   round(sum(gross_income),2) as total_revenue from amazon
group by product_line
order by total_revenue desc
limit 1;

-- 9. In which city was the highest revenue recorded?
select city ,   round(sum(gross_income),2) as total_revenue from amazon
group by city
order by total_revenue desc
limit 1;

-- 10. Which product line incurred the highest Value Added Tax?
select product_line ,   round(sum(vat),2) as total_vat from amazon
group by product_line
order by total_vat desc
limit 1;

-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT
    *,
    CASE 
        WHEN Total > avg_sales THEN 'Good'
        ELSE 'Bad'
    END AS sales_performance
FROM (
    SELECT 
        Product_line,
        Total,
        (SELECT round(AVG(Total),2) FROM amazon) AS avg_sales
    FROM 
        amazon
) AS subquery_alias;

-- 12. Identify the branch that exceeded the average number of products sold.

SELECT
    branch,
    SUM(quantity) AS total_quantity_sold,
    AVG(quantity) AS avg_quantity_sold,
    CASE 
        WHEN SUM(quantity) > (SELECT AVG(quantity) FROM amazon) THEN 'Exceeded'
        ELSE 'Did not exceed'
    END AS quantity_comparison
FROM 
    amazon
GROUP BY 
    branch;
-- 13. Which product line is most frequently associated with each gender?
select *
from(
select gender, product_line, count(*)as frequent
from amazon
where gender = 'male'
group by product_line
order by frequent desc
limit 1) as male
union
(select gender, product_line, count(*)as frequent_female
from amazon
where gender = 'female'
group by product_line
order by frequent_female desc
limit 1) ;


-- 14. Calculate the average rating for each product line.

select product_line, round(avg(rating),2) as avg_rating
from amazon
group by product_line;

-- 15. Count the sales occurrences for each time of day on every weekday.

select timeofday, count(invoice_id)
from amazon
where dayname not in ('sat', 'sun')
group by timeofday;

-- 16. Identify the customer type contributing the highest revenue.
select `customer type` , round(sum(total),2) as total_revenue
from amazon
group by `customer type`;

-- 17. Determine the city with the highest VAT percentage.

select city, round(sum(vat),2) as vat_total
from amazon
group by city
order by vat_total desc
limit 1;

-- 18. Identify the customer type with the highest VAT payments.

select `customer type` , round(sum(vat),2) as total_vat_payments
from amazon
group by `customer type`
order by total_vat_payments desc
limit 1;

-- 19. What is the count of distinct customer types in the dataset?

select count(distinct `customer type` ) as unique_customer_type
from amazon;

-- 20. What is the count of distinct payment methods in the dataset?
 
 select count(distinct payment ) as unique_payment_type
from amazon;

-- 21. Which customer type occurs most frequently?

select `customer type` , count(*) as frequent
from amazon
group by `customer type`
order by frequent desc
limit 1;

-- 22. Identify the customer type with the highest purchase frequency.

select `customer type` , count(invoice_id) as frequent
from amazon
group by `customer type`
order by frequent desc
limit 1;

-- 23. Determine the predominant gender among customers.

select gender , count(*) as predominant_gender
from amazon
group by gender 
order by predominant_gender desc
limit 1;


-- 24. Examine the distribution of genders within each branch.

select branch, gender, count(*) as gender_count
from amazon
group by branch, gender
order by branch ;

-- 25. Identify the time of day when customers provide the most ratings.

select timeofday , count(*)as rating_count
from amazon
group by timeofday
order by rating_count desc;

-- 26. Determine the time of day with the highest customer ratings for each branch.

with rankedtimes as(
select branch, timeofday,max(rating),
row_number() over(partition by branch order by max(rating) desc ) as ranking
from amazon
group by branch , timeofday
)
select branch, timeofday, ranking
from rankedtimes
where ranking = 1;

-- 27. Identify the day of the week with the highest average ratings.

select dayname, round(avg(rating),2) as avg_rating
from amazon
group by dayname
order by avg_rating desc
limit 1;

-- 28. Determine the day of the week with the highest average ratings for each branch.

select *
from (
select branch, dayname,round(avg(rating),2) as avg_rating,
rank() over(partition by branch order by avg(rating) desc) as ranked
from amazon
group by branch, dayname 
) as sub
where 
ranked = 1;
