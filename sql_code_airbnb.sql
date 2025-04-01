/** Analysis of New York City Airbnb Open dataset **/

# 1.Basic Exploration
#Check the total number of listings:
select count(*) AS total_listings
 from airbnb_table;

#Get the number of unique hosts:
select count(distinct host_id) as Unique_host
 from airbnb_table;

#Find the total number of listings per neighborhood_group:
select neighbourhood_group,count(*) as total_number_listings
 from airbnb_table 
 group by neighbourhood_group 
 order by total_number_listings desc;


#2. Host Analysis

#Find the top 10 hosts with the most listings:
select host_id ,count(*) as total_number_listings
 from airbnb_table 
 group by host_id 
 order by total_number_listings desc;

#Check the average number of listings per host:
select avg(total) as avg_listing
 from (select host_id,count(*) as total
		from airbnb_table
        group by host_id) t;
 
#Identify hosts with multiple unique names: 
select host_id,count(distinct host_name) as total
 from airbnb_table
 group by host_id 
 having total>1; 

#Identify host_names with multiple host_id : 
select host_name,count(distinct host_id) as total 
from airbnb_table 
group by host_name 
having total>1
  order by total desc; 

#Identify total host_name with multiple unique host_id: 
select count(distinct host_name)
 from (select host_name ,count(distinct host_id) as tot
		from airbnb_table 
        group by host_name
        having tot>1 
        order by tot
	   )t;



# 3.Pricing Analysis

#Find the average price per neighborhood:
select neighbourhood,avg(price)
 from airbnb_table
 group by neighbourhood
 order by avg(price) desc;

#Find the average price per neighborhood_group:
select neighbourhood_group,avg(price)
 from airbnb_table 
 group by neighbourhood_group
 order by avg(price) desc;

#Get the top 10 most expensive listings
with cte_rank as (
select id,name,price,
dense_rank() over(order by price desc) as rank_price
 from airbnb_table )

select id,name,price,rank_price
 from cte_rank
 where rank_price<=10;

# Average price per room type (Private room, Entire home/apt, Shared room).
select room_type,avg(price) as average_price
from airbnb_table 
group by room_type order by average_price desc;

# 4.Availability & Booking Trends
#Find the average availability per listing:
select round(avg(availability_365),2) 
from airbnb_table;


#Get listings that are available year-round:
select id,name 
from airbnb_table 
where availability_365 =365; 

#Get the total number of listings that are available year-round:
select count(distinct id) from 
(select id,name 
from airbnb_table 
where availability_365 =365)t; 

# Find the top 10 listings with the highest number of reviews:
with cte_number_of_reviews as (
select id,name,number_of_reviews,
  dense_rank() over(order by number_of_reviews desc) as denserank
  from airbnb_table 
)
select id,name,number_of_reviews,denserank
 from cte_number_of_reviews
 where denserank <=10;

#Identify listings with zero reviews:
select id,name ,number_of_reviews
 from airbnb_table 
 where number_of_reviews =0;

#Identify total listing  with zero reviews:
select count(distinct id) from 
(select id,name ,number_of_reviews 
from airbnb_table
 where number_of_reviews =0)t;

#5. Customer Engagement & Ratings
#Find the average reviews per listing
select round(avg(number_of_reviews),2)
 from airbnb_table; 

#Check the most reviewed neighborhoods:
select neighbourhood, sum(number_of_reviews) as totalreview 
from airbnb_table
 group by neighbourhood 
 order by totalreview desc;

#Check the most reviewed neighborhood_group:
select neighbourhood_group, sum(number_of_reviews) as totalreview 
from airbnb_table 
group by neighbourhood_group
order by totalreview desc;


#Find the correlation between price and number of reviews:
select price, avg(number_of_reviews) as avg_reviews
from airbnb_table
group by price
order by avg_reviews desc;

#6. Geographic Distribution

#Find the top 5 neighborhoods with the most listings:
with cte_top5neighborhoods as (
select neighbourhood,count(*) as total_listing,
 dense_rank() over(order by count(*) desc ) as rank_neigh
 from airbnb_table group by neighbourhood
)
select neighbourhood,total_listing,rank_neigh from cte_top5neighborhoods where rank_neigh<=5;

#Identify the distribution of room types across neighborhoods:
select neighbourhood,room_type,count(*) as total
 from airbnb_table
 group by neighbourhood,room_type
 order by total desc;

#7. Time-based Analysis

#Find the most recent review date:
select max(last_review) as most_recent_review_date from airbnb_table;

#Find the number of listings reviewed per month:
select DATE_FORMAT(last_review, '%Y-%m') as review_month, COUNT(*) as total_reviews
from airbnb_table
where last_review is not null 
group by review_month
order by total_reviews desc;

#Find the number of listings reviewed per year
select DATE_FORMAT(last_review, '%Y') as review_year, COUNT(*) as total_reviews
from airbnb_table
where last_review is not null
group by review_year
order by total_reviews desc;
 
#Monthly Average Reviews Per Listing
 select date_format(last_review, '%Y-%m') as review_month, round(avg(reviews_per_month),2) as avg_review_permonth
 from airbnb_table
 group by review_month
 order by review_month desc ;


#8. Identifying Data Quality Issues

#Check for duplicate listings based on name, latitude, and longitude
select name,latitude,longitude,count(*) as dup
 from airbnb_table
 group by name,latitude,longitude 
 having dup >1;

/** Conclusion:
Performed a comprehensive analysis of the Airbnb dataset using MySQL, covering basic exploration, host insights, 
price trends, availability and booking patterns, customer engagement, geographic distribution, time-based analysis, and data quality assessment.

Key Observations:
1.Basic Exploration:

	* The dataset contains a total of 48,895 listings.

	* There are 37,457 unique host IDs.

	* Manhattan has the highest number of listings, totaling 21,661 in the neighbouthood_group.

2.Host Analysis:

	* Host ID 219517861 has the highest number of listings, with a total of 327.

	* Each host ID is associated with only one host name.

	* 3,132 records have more than one unique host ID.

	* The host name Michael is linked to the highest number of unique host IDs (336).

	* The average number of listings per host is 1.31.

3.Price Analysis:

	* 'Fort Wadsworth' has the highest average price of $800 among neighborhoods.

	* 'Manhattan' has the highest average price of $196.88 among neighborhood groups.

	* The most expensive listings include: Listing ID 22436899: '1-BR Lincoln Center',Listing ID 13894339: 'Luxury 1 bedroom apt. - stunning Manhattan views' & Listing ID 7003697: 'Furnished room in Astoria apartment'

'	* Entire home/apt' room type has the highest average price of $211.79.

4.Availability & Booking Trends:

	* The average availability per listing is 112.78 days per year.

	* A total of 1,295 listings are available year-round.

	* The listing 'Room near JFK Queen Bed' (ID: 9145202) has the highest number of reviews (629).

	* 10,052 listings have zero reviews.

5.Customer Engagement & Ratings:

	* The average number of reviews per listing is 23.27.

	* Bedford-Stuyvesant is the most reviewed neighborhood with 110,352 total reviews.

	* Brooklyn has the highest total reviews among neighborhood groups with 486,574 reviews.

6.Geographic Distribution:

	* The top 5 neighborhoods with the most listings: Williamsburg, Bedford-Stuyvesant, Harlem, Bushwick, and Upper West Side.

	* Bedford-Stuyvesant has the highest number of 'private room' listings, totaling 2,038.

7.Time-Based Analysis:

	* The most recent review date is July 8, 2019.

	* The highest number of reviews was recorded in 2019 (25,209 reviews).

	* June 2019 received the highest number of reviews in a single month (12,601).

	* July 2019 had the highest monthly average reviews per listing (3.16).

8.Data Quality Issues:

	* No duplicate listings based on name, latitude, and longitude were found.
 
 
 **/