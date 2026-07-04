# select all query
use Swiggydb;
select * from Swiggy;



#search for dublicates
select state, city, Order_date, Restaurant_name, location, 
		category, Dish_name, Price, Rating, Rating_Count, Count(*) as cnt from Swiggy
	GROUP by state, city, Order_date, Restaurant_name, location, 
		category, Dish_name, Price, Rating, Rating_Count
		having cnt>1;

# remove dublicates
CREATE INDEX idx_swiggy_dupes 
ON swiggy (state, city, Order_Date, Restaurant_Name, Dish_Name, ID);
    # this didn't work
	DELETE s1 FROM  swiggy s1, swiggy s2
	WHERE s1.state = s2.state and s1.city = s2.city and s1.Order_Date = s2.Order_Date and
	      s1.Restaurant_Name = s2.Restaurant_Name and s1.Dish_Name=s2.Dish_Name and s1.ID > s2.ID;



# Dim Date table
CREATE TABLE dim_date(
  date_id int AUTO_INCREMENT PRIMARY KEY, 
  full_Date date,
  year int,
  month INT,
  month_name varchar(20),
  quater int,
  day int,
  week int	
  );

#dim_location
CREATE TABLE dim_location (
location_id INT AUTO_INCREMENT PRIMARY KEY, State VARCHAR(100),
City VARCHAR(100),
Location VARCHAR(200)
);

#dim_restaurant
CREATE TABLE dim_restaurant (
restaurant_id INT AUTO_INCREMENT PRIMARY KEY, Restaurant_Name VARCHAR(200)
);

#dim_category
CREATE TABLE dim_category ( category_id INT AUTO_INCREMENT PRIMARY KEY, Category VARCHAR(200));

#dim_dish
CREATE TABLE dim_dish (
dish_id INT AUTO_INCREMENT PRIMARY KEY, Dish_Name VARCHAR(200));

#fact table
CREATE TABLE fact_swiggy_orders (
order_id INT auto_increment PRIMARY KEY,
date_id INT,
Price_INR DECIMAL(10,2),
Rating DECIMAL (4,2),
Rating_Count INT,
location_id INT,
restaurant_id INT,
category_id INT,
dish_id INT,
FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
FOREIGN KEY (location_id) REFERENCES dim_location (location_id),
FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant (restaurant_id),
FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);

# inserting data in dim_date
INSERT INTO dim_date (Full_date, year, month, month_name, quater, day, week)
SELECT DISTINCT 
    Order_Date, 
    YEAR(Order_Date), 
    MONTH(Order_Date), 
    MONTHNAME(Order_Date), 
    QUARTER(Order_Date), 
    DAY(Order_Date), 
    WEEK(Order_Date)
FROM swiggy 
WHERE Order_Date IS NOT NULL;
select * from dim_date;

# inserting data in dim_location
insert into dim_location(state,city,location)
SELECT DISTINCT state, city, location from Swiggy;
select * from dim_location;

# inserting data in dim_restaurant
insert INTO dim_restaurant(Restaurant_Name) select distinct Restaurant_Name from swiggy;
select * from dim_restaurant;

# inserting data in dim_category
insert into dim_category(Category) select distinct Category FROM  swiggy;
select * from dim_category;

# inserting data in dim_dish
insert into dim_dish(Dish_Name) select distinct Dish_Name from swiggy;
select * from dim_dish;

#inserting data in fact table

ALTER TABLE swiggy ADD INDEX (Order_Date);
ALTER TABLE swiggy ADD INDEX (state, city, location);
ALTER TABLE swiggy ADD INDEX (Restaurant_Name);
ALTER TABLE swiggy ADD INDEX (Category);
ALTER TABLE swiggy ADD INDEX (Dish_Name);
ALTER TABLE dim_date ADD INDEX (Full_date);
ALTER TABLE dim_location ADD INDEX (state, city, Location);
ALTER TABLE dim_restaurant ADD INDEX (Restaurant_Name);
ALTER TABLE dim_category ADD INDEX (Category);
ALTER TABLE dim_dish ADD INDEX (Dish_Name);

INSERT INTO fact_swiggy_orders (
    date_id, Price_INR, Rating, Rating_Count, 
    location_id, Restaurant_id, category_Id, dish_id
)
SELECT 
    dd.date_id,
    s.Price,          
    s.Rating,         
    s.Rating_Count,   
    dl.location_id,   
    dr.restaurant_id, 
    dc.category_id,   
    dsh.dish_id       
FROM swiggy s
INNER JOIN dim_date dd 
    ON dd.Full_date = s.Order_Date
INNER JOIN dim_location dl 
    ON dl.state = s.state 
   AND dl.city = s.city 
   AND dl.Location = s.location
INNER JOIN (
    -- Safely gets only ONE unique ID per restaurant name
    SELECT Restaurant_Name, MIN(restaurant_id) as restaurant_id 
    FROM dim_restaurant 
    GROUP BY Restaurant_Name
) dr ON dr.Restaurant_Name = s.Restaurant_Name 
INNER JOIN (
    -- Safely gets only ONE unique ID per category
    SELECT Category, MIN(category_id) as category_id 
    FROM dim_category 
    GROUP BY Category
) dc ON dc.Category = s.Category
INNER JOIN (
    -- Safely gets only ONE unique ID per dish
    SELECT Dish_Name, MIN(dish_id) as dish_id 
    FROM dim_dish 
    GROUP BY Dish_Name
) dsh ON dsh.Dish_Name = s.Dish_Name;
select * from fact_swiggy_orders;


SELECT * FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
JOIN dim_category c ON f.category_id = c.category_id
JOIN dim_dish di ON f.dish_id = di.dish_id;





#kpi

#Total orders
select count(*) as Total_order from fact_swiggy_orders;

#Total Revenue
select sum(price_inr) as total_revenue from fact_swiggy_orders;

#Avg dish price
select round(AVG(price_inr),2) as avg_revenue from fact_swiggy_orders;

#Avg rating
select round(AVG(Rating),2) as avg_rating from fact_swiggy_orders;





#Business analysis

#Monthly orders placed
SELECT dd.year, dd.month, dd.month_name, count(*) as Total_order, sum(price_inr) as Sum_Total
from fact_swiggy_orders f
join dim_date dd on f.date_id = dd.date_id 
group by dd.year, dd.month, dd.month_name;

#quaterly trends
SELECT dd.year, dd.quater, count(*) as Total_order, sum(price_inr) as Sum_Total
from fact_swiggy_orders f
join dim_date dd on f.date_id = dd.date_id 
group by dd.year, dd.quater;

#yearly trend
SELECT dd.year, count(*) as Total_order, sum(price_inr) as Sum_Total
from fact_swiggy_orders f
join dim_date dd on f.date_id = dd.date_id 
group by dd.year;

#order by day of the week
SELECT
    DAYNAME(d.full_date) AS day_name,
    COUNT(*) AS total_orders, sum(price_inr) as Sum_Total
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY DAYNAME(d.full_date), WEEKDAY(d.full_date)
ORDER BY WEEKDAY(d.full_date);





# Location analysis

# Top 10 cities by order volume
Select l.city , count(*) as Total_orders from fact_swiggy_orders f
join dim_location l on l.location_id = f.location_id group by l.city 
order by count(*) desc LIMIT 10;

# Top state by order volume
Select l.state , count(*) as Total_orders from fact_swiggy_orders f
join dim_location l on l.location_id = f.location_id group by l.state
order by count(*);




#food analysis

#top 10 resturant by orders
Select r.restaurant_name, count(*) as Total_orders from fact_swiggy_orders f
join dim_restaurant r on r.restaurant_id = f.restaurant_id group by r.restaurant_name
order by count(*) desc limit 10;

#top 10 categories
Select c.category, count(*) as Categories from fact_swiggy_orders f
join dim_category c on c.category_id = f.category_id group by c.category
order by count(*) desc limit 10;

#50 Most Ordered Dishes
SELECT d.dish_name, COUNT(*) AS order_count FROM fact_swiggy_orders f
JOIN dim_dish d ON f.dish_id= d.dish_id GROUP BY d.dish_name ORDER BY order_count DESC limit 50;



#Cuisine Performance (Orders + Avg Rating)
SELECT c.category, COUNT(*) AS total_orders, round(AVG(f.rating),2) AS Avg_Rating FROM fact_swiggy_orders f
JOIN dim_category c ON f.category_id = c.category_id 
GROUP BY c.category ORDER BY total_orders DESC;


#Total Orders by Price Range
SELECT
	CASE
	WHEN price_inr < 100 THEN 'Under 100'
	WHEN price_inr BETWEEN 100 AND 199 THEN '100 - 199'
	WHEN price_inr BETWEEN 200 AND 299 THEN '200 - 299'
	WHEN price_inr BETWEEN 300 AND 499 THEN '300 - 499'
	ELSE '500+'
END AS price_range,
COUNT(*) AS total_orders FROM fact_swiggy_orders
GROUP BY
	CASE
	WHEN price_inr < 100 THEN 'Under 100'
	WHEN price_inr BETWEEN 100 AND 199 THEN '100 - 199'
	WHEN price_inr BETWEEN 200 AND 299 THEN '200 - 299'
	WHEN price_inr BETWEEN 300 AND 499 THEN '300 - 499'
	ELSE '500+'
	END
ORDER BY total_orders DESC;

#Rating Count Distribution (1-5)
SELECT rating, COUNT(*) AS rating_count FROM fact_swiggy_orders
GROUP BY rating ORDER BY COUNT(*) DESC;




