-- DML Commands

use zomato_analysis;

-- GENERAL INSIGHTS
-- 1. What is the total number of restaurants in the dataset?

select count(*) as total_no_of_restaurants 
from restaurant;

-- 2. Count of restaurants per country.

select c.country, r.country_code, count(r.Restaurant_ID) as total_restaurants
from restaurant r
join country c on r.country_code=c.country_code
group by country_code ;


-- 3. Count of restaurants per city (top 10 cities with most restaurants).

select c.city_id, c.city, count(r.restaurant_id) as Total_restaurants
from restaurant r 
join city c on r.city_id=c.city_id
group by c.city_id
order by Total_restaurants desc
limit 10;

-- 4. List of unique cuisines served globally.

select distinct cuisine from cuisine;

-- 5. Number of restaurants that offer online delivery vs. those that don’t.

select has_online_delivery, count(restaurant_id) as total_restaurants
from restaurant
group by has_online_delivery;

-- 6. Number of restaurants offering table booking.

select count(restaurant_id)
from restaurant
where has_table_booking = "Yes";

-- 7. Average rating of all restaurants in a country.
select c.country, r.country_code, round(avg(aggregate_rating),2) as average_rating
from restaurant r
join country c on r.country_code=c.country_code
group by country_code ;

-- 8. Total votes received across all restaurants in a city.

select c.city_id, c.city, sum(votes) as total_votes
from restaurant r 
join city c on r.city_id=c.city_id
group by c.city_id;


-- COST ANALYSIS
-- 9. Average average_cost_for_two across countries.

select c.country, round(avg(average_cost_for_two),2) Country_wise_average_cost_for_two
from restaurant r 
join country c on r.country_code=c.country_code
group by c.country_code, c.country
order by Country_wise_average_cost_for_two desc ;

-- 10. Country with the highest average average_cost_for_two.

select c.country_code, c.country, round(avg(average_cost_for_two),2) as Country_wise_average_cost_for_two
from restaurant r 
join country c on r.country_code=c.country_code 
group by c.country_code, c.country
order by Country_wise_average_cost_for_two desc
limit 1;

-- 11. List of countries with average average_cost_for_two less than $50.

select c.country, round(avg(average_cost_for_two),2) Country_wise_average_cost_for_two
from restaurant r 
join country c on r.country_code=c.country_code
group by c.country_code, c.country
having Country_wise_average_cost_for_two<50
order by Country_wise_average_cost_for_two desc ;

-- 12. Top 10 cities with the highest average cost for two.

select c.city, round(avg(average_cost_for_two),2) City_wise_average_cost_for_two
from restaurant r 
join city c on r.city_id=c.city_id
group by c.city_id, c.city
order by City_wise_average_cost_for_two desc 
limit 10;

-- 13. Correlation between price range and average rating.

select price_range, round(avg(aggregate_rating),2) as Average_rating
from restaurant 
group by price_range
order by price_range;

-- 14. Average cost for two based on cuisines.

select rc.cuisine, round(avg(average_cost_for_two),2) Cuisine_wise_average_cost_for_two
from restaurant r 
join restaurant_cuisine rc on r.restaurant_id=rc.restaurant_id
group by rc.cuisine_id, rc.cuisine;


-- COUNTRY & CURRENCY ANALYSIS
-- 15. List of countries and their respective currencies.

select country, currency from country
order by country_code;

-- 16. Country with the most number of restaurants accepting online delivery.

select c.country_code, c.country, 
sum(case when Has_Online_delivery="Yes" then 1 else 0 end) as online_delivery_restaurants
from restaurant r 
join country c on r.country_code=c.country_code
group by c.country_code
order by online_delivery_restaurants desc
limit 1 ;

-- Alternate way 
select c.country_code, c.country, count(*) AS online_delivery_restaurants
from restaurant r 
join country c ON r.country_code = c.country_code
where r.Has_Online_delivery = "Yes"
group by c.country_code, c.country
order by online_delivery_restaurants desc
limit 1;

-- 17. Country-wise average ratings of restaurants.

select c.country_code, c.country, round(avg(aggregate_rating),2) as Average_rating
from restaurant r 
join country c on r.country_code=c.country_code
group by c.country_code
order by c.country_code;

-- 18. Number of restaurants in India vs. the rest of the world.

select "India", count(*)
from restaurant r
join country c on r.country_code=c.country_code
where c.country="India"
UNION ALL
select "Rest of the World", count(*)
from restaurant r
join country c on r.country_code=c.country_code
where c.country!="India";

-- 19. Number of restaurants in each country with table booking options vs. those without.

SELECT c.country,
SUM(CASE WHEN r.has_table_booking = 'Yes' THEN 1 ELSE 0 END) AS has_table_booking_count,
SUM(CASE WHEN r.has_table_booking = 'No' THEN 1 ELSE 0 END) AS no_table_booking_count
from restaurant r
join country c ON r.country_code = c.country_code
group by c.country;


-- RATINGS AND VOTES ANALYSIS
-- 20. Top 10 restaurants with the highest rating.

select restaurant_id, restaurant_name, aggregate_rating as rating
from restaurant 
order by aggregate_rating desc
limit 10;

-- 21. Top 10 restaurants with the highest votes.

select restaurant_id, restaurant_name, votes
from restaurant 
order by votes desc
limit 10;

-- 22. List of restaurants with zero ratings or votes (identify potential inactive listings).

select restaurant_id, restaurant_name 
from restaurant
where aggregate_rating = 0 or votes = 0;

-- 23. Average rating per cuisine globally.

select rc.cuisine, round(avg(aggregate_rating),2)
from restaurant r
join restaurant_cuisine rc on r.restaurant_id=rc.restaurant_id
group by rc.cuisine_id, rc.cuisine;

-- 24. Countries with the highest and lowest average ratings.

select "Highest" as label, country, Average_rating
from
(select c.country, round(avg(aggregate_rating),2) Average_rating
from restaurant r
join country c on r.country_code=c.country_code
group by c.country_code, c.country
order by Average_rating desc
limit 1) as highest
UNION ALL
select "Lowest" as label, country, Average_rating
from
(select c.country, round(avg(aggregate_rating),2) Average_rating
from restaurant r
join country c on r.country_code=c.country_code
group by c.country_code, c.country
order by Average_rating 
limit 1) as lowest;

-- Alternative way
with country_avg_rating as (
select c.country, round(avg(aggregate_rating),2) Average_rating
from restaurant r
join country c on r.country_code=c.country_code
group by c.country_code, c.country)

(select "Highest" as label, country, Average_rating
from country_avg_rating
order by Average_rating desc
limit 1)
union all
(select "Lowest" as label, country, Average_rating
from country_avg_rating
order by Average_rating 
limit 1);

-- 25. Identify if restaurants with table booking have higher average ratings than those without

select 
(case when has_table_booking="Yes"then "has_table_booking" else "don't_have_table_booking" end) as Label,
round(avg(aggregate_rating),2) as Average_rating
from restaurant 
group by has_table_booking;


-- CUISINE ANALYSIS
-- 26. Most popular cuisines globally (by count).

select cuisine, count(*) cuisine_count
from restaurant_cuisine
group by cuisine_id, cuisine
order by cuisine_count desc;

-- 27. Most popular cuisines per country.

with cuisine_counts as(
select c.country, rc.cuisine, count(rc.cuisine_id) as cuisine_count, 
rank() over(partition by c.country order by count(rc.cuisine_id) desc) as rn
from restaurant_cuisine rc
join restaurant r on rc.restaurant_id=r.restaurant_id
join country c on r. country_code=c.country_code
group by c.country_code, c.country, rc.cuisine
order by c.country_code) 

select country, cuisine, cuisine_count, rn
from cuisine_counts
where rn=1;

-- 28. Most expensive cuisines on average.

select rc.cuisine, round(avg(Price_range),2) Average_price
from restaurant_cuisine rc
join restaurant r on rc.restaurant_id=r.restaurant_id
group by rc.cuisine_id, rc.cuisine
order by Average_price desc
limit 1;

-- 29. Cuisine with the highest average votes.

select rc.cuisine, round(avg(votes),2) Average_votes
from restaurant_cuisine rc
join restaurant r on rc.restaurant_id=r.restaurant_id
group by rc.cuisine_id, rc.cuisine
order by Average_votes desc
limit 1;

-- BUSINESS STRATEGY ORIENTED
-- 30. Which countries have a large number of restaurants (above global average) but a rating below 3.5 — indicating scale but quality issues?

with global_avg as(
select avg(restaurant_count) global_average
from (
select c.country_code, count(*) as restaurant_count
from restaurant r
join country c on r.country_code=c.country_code
group by c.country_code
) as sub
),
restaurant_data as(
select c.country_code, c.country, count(*) as no_of_restaurants, round(avg(aggregate_rating),2) as Average_rating
from restaurant r
join country c on r.country_code=c.country_code
group by c.country_code, c.country) 

select rd.country_code, rd.country, no_of_restaurants, Average_rating
from restaurant_data rd
join global_avg ga on 1=1
where no_of_restaurants> ga.global_average and Average_rating<3.5 ;

-- ADVANCED SEGMENTATION
-- 31. Identify the top 10 cuisines by rating within India.

select c.country, rc.cuisine, round(avg(aggregate_rating),2) as Average_rating
from restaurant r
join restaurant_cuisine rc on r.restaurant_id=rc.restaurant_id
join country c on r.country_code=c.country_code
group by c.country_code, c.country, rc.cuisine_id, rc.cuisine
having country="India"
order by Average_rating desc
limit 10;

-- 32. Identify top 20 cities with the most diverse cuisines available.

select co.country, c.city, count(distinct rc.cuisine_id) as no_of_cuisines
from restaurant r
join city c on r.city_id=c.city_id
join restaurant_cuisine rc on r.restaurant_id=rc.restaurant_id
join country co on c.country_code=co.country_code
group by c.city_id, c.city, co.country
order by no_of_cuisines desc
limit 20;

-- 33. Compare average costs of North Indian cuisine across countries.

select c.country, rc.cuisine, round(avg(average_cost_for_two),2) as average_cost
from restaurant r 
join restaurant_cuisine rc on r.restaurant_id=rc.restaurant_id
join country c on r.country_code=c.country_code
WHERE rc.cuisine = "North Indian"
group by c.country_code, c.country, rc.cuisine_id, rc.cuisine;

-- 34. Identify the price sensitivity of customers in each country (votes vs. price range analysis).

select c.country, r.price_range, round(avg(r.votes),2) as Average_votes
from restaurant r
join country c on r.country_code=c.country_code
group by c.country_code, c.country, r.price_range
order by c.country_code,r.price_range;
