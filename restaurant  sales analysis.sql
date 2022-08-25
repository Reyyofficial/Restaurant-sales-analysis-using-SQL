use RestaurantProject

--To check for NULL values in the dataset
select * 
from Orders_Data
select Customer_name 
from Orders_Data 
where Customer_Name is null
select Restaurant_ID 
from Orders_Data 
where Restaurant_ID is null
select Quantity_of_Items 
from Orders_Data 
where Quantity_of_Items is null
select Order_Amount 
from Orders_Data 
where Order_Amount is null
select Payment_Mode 
from Orders_Data 
where Payment_Mode is null
select Delivery_Time 
from Orders_Data 
where Delivery_Time is null
select Customer_Rating_food 
from Orders_Data 
where Customer_Rating_food is null
select Customer_Rating_delivery 
from Orders_Data 
where Customer_Rating_delivery is null
select Order_Time 
from Orders_Data 
where Order_Time is null

--Check for null values in the second table 
select * 
from Restaurant_Details
select Restaurant_Name 
from Restaurant_Details 
where Restaurant_Name is null
select Cuisine 
from Restaurant_Details 
where Cuisine is null
select Zone 
from Restaurant_Details 
where Zone is null
select Category 
from Restaurant_Details 
where Category is null

--To make adjustments to the table.
--created a new column and converted the date and time formats 
alter table Orders_Data
add New_Order_Date Date
update Orders_Data 
set New_Order_Date = CONVERT(Date, Order_Date)
update Orders_Data 
set New_Order_Time = CONVERT(Time, Order_Date, 120)
alter table Orders_Data 
drop column New_Order_Time
alter table Orders_Data 
drop column Order_Date

--used basic aggregate functions to get a total summary of the analysis.
select avg(Customer_Rating_food) as 'Average Customer Rating' 
from Orders_Data
select sum(Quantity_of_items) as 'Total Items Sold' 
from Orders_Data
select sum(Order_Amount) as 'Total Orders' 
from Orders_Data
select avg(Delivery_Time)as 'Average Delivery Time' 
from Orders_Data

--Join the two two tables together 
select * 
from Orders_Data od
inner join Restaurant_Details rd
on od.Restaurant_ID = rd.Restaurant_ID

--Created a CTE with the joined tables to make referencing the joined tables easier.
--To  get the amount of customers in each zone.
with Merged_Table as
(select Restaurant_Name,
        Cuisine, 
        Zone, 
        Category, 
		Payment_Mode,
		Customer_Name, 
		Order_Amount, 
		Quantity_of_Items, 
		Delivery_Time
  from Orders_Data od
  inner join Restaurant_Details rd
  on od.Restaurant_ID = rd.Restaurant_ID)
select COUNT(distinct(Customer_Name)) as 'Total Customers', 
Zone 
from Merged_Table
group by Zone
order by COUNT(distinct(Customer_Name)) desc

--To know the restaurant with the highest orders.
--It was limited to the top 5 restaurants
with Merged_Table as
(select 
       Restaurant_Name, 
	   Cuisine, 
	   Zone, 
	   Category, 
	   Payment_Mode,
	   Customer_Name, 
	   Order_Amount, 
	   Quantity_of_Items, 
	   Delivery_Time
from Orders_Data od
inner join Restaurant_Details rd
on od.Restaurant_ID = rd.Restaurant_ID)
select top 5 sum(Order_Amount) as 'Total Orders', 
      Restaurant_Name
from  Merged_Table
group by Restaurant_Name
order by SUM(Order_Amount) desc

--To know the total orders of each customer 
--It was limited to the top 5 highest ordering customers
with Merged_Table as
(select 
       Restaurant_Name,
	   Cuisine, 
	   Zone, 
	   Category, 
	   Payment_Mode,
	   Customer_Name, 
	   Order_Amount, 
	   Quantity_of_Items, 
	   Delivery_Time
from Orders_Data od
inner join Restaurant_Details rd
on od.Restaurant_ID = rd.Restaurant_ID)
select top 5 sum(Order_Amount) as 'Total Orders', 
Customer_Name 
from Merged_Table
group by Customer_Name
order by SUM(Order_Amount) desc

--To get get the total orders for each zone
with Merged_Table as
(select 
       Restaurant_Name, 
	   Cuisine, 
	   Zone, 
	   Category, 
	   Payment_Mode,
	   Customer_Name, 
	   Order_Amount, 
	   Quantity_of_Items, 
	   Delivery_Time
from Orders_Data od
inner join Restaurant_Details rd
on od.Restaurant_ID = rd.Restaurant_ID)
select Sum(Order_Amount) as 'Total Orders',
Zone 
from Merged_Table
group by Zone
order by Sum(Order_Amount) desc

--To know which payment mode was used.
--I decided to group it into just two categories using Case statement.
with Mode_Of_Payment as 
(Select Payment_Mode,
case 
when Payment_Mode = 'Debit Card' then 'Card'
when Payment_Mode = 'Credit Card' then 'Card'
else 'Cash'
end as Mode_of_Payment
from Orders_Data)
select count(Mode_of_Payment) as 'Quantity', 
Mode_of_Payment 
from Mode_Of_Payment
group by Mode_of_Payment
order by count(Mode_of_Payment) desc

--To get the most liked cuisine using the amount of orders.
with Merged_Table as
(select Restaurant_Name, Cuisine, Zone, Category, Payment_Mode,Customer_Name, Order_Amount, Quantity_of_Items, Delivery_Time
from Orders_Data od
inner join Restaurant_Details rd
on od.Restaurant_ID = rd.Restaurant_ID)
select top 5 sum(Order_Amount) as 'Total Orders', 
             Cuisine 
from Merged_Table
group by Cuisine
order by sum(Order_Amount) desc


--To get the time of day customers ordered the most.
--I tegorized the times into Morning, Afternoon and Night
with TOD as 
(select 
case
when Order_Time between '12:00:00' and '17:59:00' then 'Afternoon'
when Order_Time between '18:00:00' and '23:59:00' then 'Night'
else 'Morning'
end as 'Time_of_Day'
from Orders_Data)
select Time_of_Day, count(Time_of_Day) as 'Orders by time of day' 
from TOD
group by Time_of_Day
order by count(Time_of_Day) desc
