/* Q# 1A. Describe the data in hand
Superstores are very large supermarkets or shops selling 
household goods, office supplies and other equipment.

superstoredb: It is a dataset/database where we stored all the information 
related to superstore in related table.

Here we have 5 tables in Superstore dataset
		 1. cust_dimen
         2. orders_dimen
         3. prod_dimen
         4. shipping_dimen
         5. market_fact

1. cust_dimen: It contains all information about the customers of the superstore
        A. Customer Name
        B. Customer ID
        C. Region of cutomer
		D. Customer_Segment like cunsumer/Small Business etc..
        
2. orders_dimen: It contains all the details of orders
		A. Order date - When the order was made
        B. Order Priority - If the order was made on high/low/ critical priority

3. prod_dimen: This table is containing all the details about all the products available in the superstore
		A. Product Category 
		B. Product Subcategory - If the product is a part Office supplies or Technogy category
 
4. shipping_dimen: This table is having all the shipping details
		A. Ship Date - When the shipment was done
        B. Ship Mode - Whether ship through Regular Air, Express Air or Delivery Truck

5. market_fact: This table is having the market facts for all the products customers and orders
		A. Sales Amount of each order
        B. Discount on each order
        C. Profit on each order
        D. Order Quantity 
        F. Shippig cost of each order
        G. Product Id - what is the product for each order
        F. Customer ID - Who has placed the order so on...
 */
-- Q# 1B. Identify and list the Primary Key and Foreign Key

-- Table cust_dimen: Cust_id is the primary key in this table and no Foreign Key present
-- Table orders_dimen: Ord_id is the Primary Key in this table and no Foreign Key present
-- Table prod_dimen: Prod_id is the Primary Key in this table and no Foreign Key present
-- Table shipping_dimen: Ship_id is the Primary Key in this table and no Foreign Key present
-- Table market_fact : There is no Primary Key in this table and There are 4 foreign keys in this table
          -- Ord_id is a foreign key from orders_dimen table
          -- Prod_id is a foreign key from prod_dimen table
          -- Ship_id is a foreign key from shipping_dimen table
          -- Cust_id is a foreign key from cust_dimen table
        
-- Databse connection
use superstoresdb;
         
-- Q# 2A.  Find the total and average sales
select sum(Sales) as Total_Sales, avg(Sales) as Avg_Sales from market_fact;

-- Q# 2B. Display total no. of customner in each region in decreasing order of no_of_custombers
select  Region, count(*) as no_of_custombers from cust_dimen
group by Region
order by no_of_custombers desc;

-- Q# 2C. Find the region having maximun customers

select  Region, count(*) as no_of_custombers from cust_dimen
group by Region order by no_of_custombers desc limit 1;

-- Q# 2D. Find the number and id of the products sold in decreasing order of products sold
select Prod_id, sum(Order_Quantity) as no_of_products from market_fact
group by Prod_id
order by no_of_products desc;

-- Q# 2F. Find the all the customers from Atlatic region who have purchased "TABLES" 
-- and the number of tables purchased
select Customer_Name, Sum(Order_Quantity) as Total_Table from cust_dimen
inner join market_fact on cust_dimen.Cust_id = market_fact.Cust_id
inner join prod_dimen on market_fact.Prod_id = prod_dimen.Prod_id
where cust_dimen.Region = "ATLANTIC"
and
prod_dimen.Product_Sub_Category = "TABLES"
group by Customer_Name;

-- Q# 3A. Display the product categories in descending oder of profit
select Product_Category, sum(Profit) as Profit from prod_dimen
inner join market_fact on prod_dimen.Prod_id = market_fact.Prod_id
group by Product_Category
order by Profit desc;

-- Q# 3B. Display the product category, product sub-category and the profit
-- within each product sub-category in three columns
select Product_Category,Product_Sub_Category, sum(Profit) as Profit from prod_dimen
inner join market_fact on prod_dimen.Prod_id = market_fact.Prod_id
group by Product_Sub_Category
order by Profit;

-- Q# 3C. Where is the least profitable product sub-category shipped the most ?? For the least
-- profitable product sub-category, display the region-wise no_of_shipments and the profit made
-- in each region in decreasing order of profit
select Region, count(Ship_id) as no_of_shipments , sum(Profit) as Profit from cust_dimen
inner join market_fact on cust_dimen.Cust_id = market_fact.Cust_id
inner join prod_dimen on prod_dimen.Prod_id = market_fact.Prod_id
where prod_dimen.Product_Sub_Category = "TABLES"
group by Region
order by no_of_shipments desc;


