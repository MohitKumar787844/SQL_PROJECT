CREATE DATABASE Pizza_Castle;
USE Pizza_Castle;
CREATE TABLE orders(
row_id INT PRIMARY KEY,
order_id VARCHAR(10),
created_at DATETIME,
item_id VARCHAR(10),
address_id INT,
quantity INT,
customer_id INT,
delivery BOOLEAN)
;
CREATE TABLE customer(
customer_id INT REFERENCES orders(customer_id),
customer_first_name VARCHAR(50),
customer_last_name VARCHAR(50))
;
CREATE TABLE address(
address_id INT REFERENCES orders(address_id),
delivery_address VARCHAR(200),
delivery_city VARCHAR(50),
delivery_zipcode VARCHAR(20))
;
CREATE TABLE items(
item_id VARCHAR(10) REFERENCES orders(item_id),
stock_keeping_units VARCHAR(20),
item_name VARCHAR(50),
item_cat VARCHAR(50),
item_size VARCHAR(20),
item_price DECIMAL(5,2))
;
CREATE TABLE recipe(
row_id INT PRIMARY KEY,
recipe_id VARCHAR(20) REFERENCES items(stocl_keeping_units),
ing_id VARCHAR(10),
quantity INT)
;
CREATE TABLE ingredient(
ing_id VARCHAR(10) REFERENCES recipe(ing_id),
ing_name VARCHAR(50),
ing_weight INT,
ing_meas VARCHAR(20),
ing_prices DECIMAL(5,2))
;
CREATE TABLE inventory(
inv_id INT PRIMARY KEY,
item_id VARCHAR(10) REFERENCES recipe(ing_id),
quantity INT)
;
CREATE TABLE staff(
staff_id VARCHAR(20) PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
position VARCHAR(100),
hourly_rate decimal(5,2))
;
CREATE TABLE rotation(
row_id INT PRIMARY KEY,
rota_id VARCHAR(20),
date DATETIME REFERENCES orders(created_at),
shift_id VARCHAR(20),
staff_id VARCHAR(20) REFERENCES staff(staff_id))
;
CREATE TABLE shift(
shift_id VARCHAR(20) REFERENCES rotation(shift_id),
day_of_week VARCHAR(10),
start_time TIME,
end_time TIME)
;

----------------------------------------------------- Custom SQL Queries ------------------------------------------------------------------------

-- Query for ORDER ACTIVITIES
SELECT 
order_id,
Item_price,
quantity,
item_cat,
item_name,
created_at,
delivery_address,
delivery_city,
delivery_zipcode,
delivery
FROM
orders
LEFT JOIN items ON orders.item_id = items.item_id
LEFT JOIN address ON orders.address_id =  address.address_id
;

-- Queries for INVENTORY MANAGEMENT

-- Questions to be answered through this Query:
-- 1) Total quantity by ingredient
-- 2) Total cost of ingredient
-- 3) Calculated cost of Pizza
SELECT 
s1.item_id,
s1.item_name,
s1.ing_id,
s1.ing_name,
s1.ing_weight,
s1.ing_prices,
s1.order_quantity,
s1.recipe_quantity,
s1.order_quantity*s1.recipe_quantity as ordered_weight,
s1.ing_prices/s1.ing_weight as unit_cost,
(s1.order_quantity*s1.recipe_quantity)*(s1.ing_prices/ing_weight) as ingredient_cost
FROM
(SELECT
items.item_id,
stock_keeping_units,
item_name,
recipe.ing_id,
ingredient.ing_name,
recipe.quantity as recipe_quantity,
sum(orders.quantity) as order_quantity,
ingredient.ing_weight,
ingredient.ing_prices
FROM
orders
LEFT JOIN items ON orders.item_id = items.item_id
LEFT JOIN recipe ON orders.row_id = recipe.row_id
LEFT JOIN ingredient ON recipe.ing_id = ingredient.ing_id
GROUP BY 
items.item_id,
stock_keeping_units,
item_name,
recipe.ing_id,
ing_name,
ingredient.ing_weight,
ingredient.ing_prices) as s1
;

-- Creating a VIEW of last Query for next Query

CREATE VIEW stock AS
SELECT 
s1.item_id,
s1.item_name,
s1.ing_id,
s1.ing_name,
s1.ing_weight,
s1.ing_prices,
s1.order_quantity,
s1.recipe_quantity,
s1.order_quantity*s1.recipe_quantity as ordered_weight,
s1.ing_prices/s1.ing_weight as unit_cost,
(s1.order_quantity*s1.recipe_quantity)*(s1.ing_prices/ing_weight) as ingredient_cost
FROM
(SELECT
items.item_id,
stock_keeping_units,
item_name,
recipe.ing_id,
ingredient.ing_name,
recipe.quantity as recipe_quantity,
sum(orders.quantity) as order_quantity,
ingredient.ing_weight,
ingredient.ing_prices
FROM
orders
LEFT JOIN items ON orders.item_id = items.item_id
LEFT JOIN recipe ON orders.row_id = recipe.row_id
LEFT JOIN ingredient ON recipe.ing_id = ingredient.ing_id
GROUP BY 
items.item_id,
stock_keeping_units,
item_name,
recipe.ing_id,
ing_name,
ingredient.ing_weight,
ingredient.ing_prices) as s1
;

-- Questions to be answered through this Query:
-- 1) Percentage stock remaining by Ingredient
-- 2) List of Ingredient to Re-order based on remaining inventory
SELECT
ingredient.ing_name,
ordered_weight,
inventory.quantity,
ing_weight*inventory.quantity as total_inventory_weight,
(ing_weight * inventory.quantity) - ing_weight as remaining_weight
FROM
(SELECT
ing_id,
ing_name,
inventory.item_id,
inventory.quantity,
SUM(ordered_weight) as ordered_weight
FROM
stock
LEFT JOIN inventory ON stock.item_id = inventory.item_id
GROUP BY
ing_id,
inventory.item_id,
inventory.quantity,
ing_name) as s2
LEFT JOIN inventory ON inventory.item_id = s2.item_id
LEFT JOIN ingredient ON ingredient.ing_id = s2.ing_id
;

-- Query for Staff Management
-- Questions to be answered through this Query:
-- 1) Start and End time for per employee
-- 2) Per employee hours in Shift
-- 3) Per employee cost to Company
SELECT
rotation.date,
staff.first_name,
staff.last_name,
staff.hourly_rate,
shift.start_time,
shift.end_time,
(((timediff(shift.end_time,shift.start_time))*60) + (minute(timediff(shift.end_time,shift.start_time))))/60 as hours_in_shift,
(((timediff(shift.end_time,shift.start_time))*60) + (minute(timediff(shift.end_time,shift.start_time))))/60 * hourly_rate as staff_cost
FROM
rotation
LEFT JOIN staff ON rotation.staff_id = staff.staff_id
LEFT JOIN shift ON rotation.shift_id = shift.shift_id
;




