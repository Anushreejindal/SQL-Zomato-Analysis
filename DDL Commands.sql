-- DDL Commands

create database zomato_analysis;
use zomato_analysis;


-- Creating table for importing data
create table raw_data(
ID INT PRIMARY KEY,
Restaurant_ID INT,
Restaurant_Name VARCHAR(70),
Country_Code INT,
Country VARCHAR(40),
City VARCHAR(70),
Address VARCHAR(200),
Locality VARCHAR(100),
Longitude FLOAT,
Latitude FLOAT,
Cuisines VARCHAR(200),
Average_Cost_for_two INT,
Currency VARCHAR(40),
Has_Table_booking ENUM("Yes","No"),
Has_Online_delivery ENUM("Yes","No"),
Is_delivering_now ENUM("Yes","No"),
Price_range INT,
Aggregate_rating FLOAT,
Rating_text VARCHAR(20),
Votes INT);

select * from raw_data;


-- Country table
create table country(
select distinct country_code, country, currency from raw_data order by country_code);

alter table country
add primary key (country_code);

select * from country;


-- City table
create table city
select distinct city, country_code from raw_data order by country_code, city;

alter table city
add city_id int auto_increment primary key;

alter table city
add foreign key (country_code) references country(country_code);

select * from city;


-- Restaurant table 
create table restaurant (
select r.Restaurant_ID, r.Restaurant_Name, r.Country_Code, c.City_Id, r.Address, r.Locality, r.Longitude, r.Latitude, 
r.Average_Cost_for_two, Has_Table_booking, Has_Online_delivery, r.Is_delivering_now, r.Price_range, r.Aggregate_rating, 
r.Rating_text, r.Votes
from raw_data r join city c on r.city=c.city);

alter table restaurant 
add primary key(restaurant_id);

alter table restaurant 
add foreign key(Country_code) references country(country_code);

alter table restaurant 
add foreign key(city_id) references city(city_id);

select * from restaurant;

-- Cuisines
create table cuisine_raw_data as
SELECT restaurant_id, TRIM(SUBSTRING_INDEX(cuisines, ',', 1)) AS cuisine FROM raw_data
UNION ALL
SELECT restaurant_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ',', 2), ',', -1)) FROM raw_data
UNION ALL
SELECT restaurant_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ',', 3), ',', -1)) FROM raw_data
UNION ALL
SELECT restaurant_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ',', 4), ',', -1)) FROM raw_data
UNION ALL
SELECT restaurant_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ',', 5), ',', -1)) FROM raw_data
UNION ALL
SELECT restaurant_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ',', 7), ',', -1)) FROM raw_data
UNION ALL
SELECT restaurant_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ',', 8), ',', -1)) FROM raw_data
UNION ALL
SELECT restaurant_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ',', 9), ',', -1)) FROM raw_data
UNION ALL
SELECT restaurant_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ',', 10), ',', -1)) FROM raw_data;

SET SQL_SAFE_UPDATES = 0;
delete from cuisine_raw_data where cuisine='';


-- Cuisine table
create table cuisine(
select distinct cuisine from cuisine_raw_data);

alter table cuisine
add cuisine_id int auto_increment primary key;

select * from cuisine;

-- Restaurant Cuisines
create table restaurant_cuisine(
select distinct r.restaurant_id, c.cuisine_id, r.cuisine from cuisine_raw_data r
join cuisine c on r.cuisine=c.cuisine_name
order by restaurant_id ,cuisine);

alter table restaurant_cuisine
add primary key (restaurant_id, cuisine_id);

alter table restaurant_cuisine
add foreign key (restaurant_id) references restaurant(restaurant_id);

alter table restaurant_cuisine
add foreign key(cuisine_id) references cuisine(cuisine_id);

select * from restaurant_cuisine;


drop table cuisine_raw_data;


