   Project: Customers and Products Analysis Using SQL
The scale model cars database schema includes 8 tables: productLine, products, orderdetails, orders, payments, customers, employees and offices. 

1. ProductLine table provides information about product in details including productLine, textDescription, htmlDescription, image with productLine is a connection with the products table. 
2. Products table provides more information about productCode, productName, productLine, productScale, productVendor, productDescription, quantityInStock, buyPrice, MSRP with productCode is a connection with the orderdetails table.
3. Orderdetails table prodives information about individual order including orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber with orderNumber is a connection with the orders table. 
4. Orders table provides information about orders, shipping status and customers information includingorderNumber, orderDate, requiredDate, shippedDate, status, comments, customerNumber with customer Number as a connection with the customers table. 
5. Customers table provides detailed information about each customer" customerNumber, customerName, contactLastName, contactFirstName, phone, addressLine1, addressLine2, city, state, postalCode, country, salesRepEmployeeNumber, creditLimit with salesRepEmployeeNumber as a connection with the employees table. 
6. Employees table provides information about employees including employeeNumber, lastName, firstName, extension, email, officeCode, reportsTo, jobTitle with officeCode as a connection with the offices table. 
7. Offices table provides informaiton about officeCode, city, phone, addressLine1, addressLine2, state, country, postalCode, territory. 
8. Payments table includes 4 columns customerNumber, checkNumber, paymentDate, amount with checkNumber and customerNumber are primary keys.

Based on the database, I have to find out some answers for this business to develop strategies. Those questions are: 
Question 1: Which product is the most popular?
Question 2: Which products should we order more of or less of?
Question 3: How should we tailor marketing and communication strategies to customer behaviors?
Question 4: How much can we spend on acquiring new customers?

Below are my SQL queries to answer the questions 
   Question 1: Which product is the most popular?
To answer this question, we will find the product with the highest number of orders

--Write a query that returns the largest order quantity

SELECT p.productname ,p.productline, sum(quantityordered) as total_order
FROM products p
 JOIN orderdetails o
  ON p.productCode = o.productCode
GROUP by p.productname
order by total_order DESC
limit 1

Question 1: Which products should we order more of or less of?

To answer this question, we need to find out the products that are low in stock (product in demand) and product performance. We need to prioritze the products need to be restocked with high performance


-- Write a query to the low stock for each product
SELECT p.productname ,
       p.productcode ,
       p.productline ,
       ROUND(sum(o.quantityordered)*1.0/p.quantityinstock,2) AS low_stock
FROM products p 
 JOIN  orderdetails o
  ON p.productcode =o.productcode 
GROUP by  p.productcode
order by low_stock 
limit 10
 
 
-- Write a query to show the performance of each product 
SELECT productcode , round(sum(quantityordered*priceeach),2) as product_performance
FROM orderdetails
GROUP by productcode
limit 10



--question 1

WITH low_stock AS 
  (SELECT p.productName, 
                 p.productCode, 
				 ROUND(SUM(od.quantityOrdered)*1.0/p.quantityInStock,2) AS low_stock_products
FROM products p
  JOIN orderdetails od
      ON p.productCode = od.productCode
GROUP BY p.productCode
order by low_stock_products
LIMIT 10)

SELECT p.productCode, 
                 p.productName,
				 p.productLine,
				 ROUND(SUM(od.quantityOrdered * od.priceEach),2) AS product_performance 
FROM products p
  JOIN orderdetails od 
     ON   p.productCode = od.productCode
WHERE od.productCode IN (SELECT productCode FROM low_stock)                                                     
GROUP BY od.productCode
ORDER BY product_performance DESC
LIMIT 10



Question 2: How should we tailor marketing and communication strategies to customer behaviors? 

-- Write a query to join the products, orders, and orderdetails tables to have customers and products information in the same place

SELECT o.customernumber ,
       round(sum(od.quantityordered *(od.priceeach - p.buyprice)),2) AS Profit
FROM products p
  JOIN orderdetails od 
     ON   p.productCode = od.productCode
  JOIN orders o
     on od.ordernumber = o.ordernumber   
GROUP by o.customernumber


-- Write a query to find the top five VIP customers.
with num as (
SELECT o.customernumber ,
       round(sum(od.quantityordered *(od.priceeach - p.buyprice)),2) AS Profit
FROM products p
  JOIN orderdetails od 
     ON   p.productCode = od.productCode
  JOIN orders o
     on od.ordernumber = o.ordernumber   
GROUP by o.customernumber)

SELECT c.contactfirstname , c.contactlastname , c.city , c.country , n.Profit
from customers c 
JOIN num n
ON c.customerNumber = n.customernumber
order by n.Profit DESC 
limit 5


-- Write a query to find the top five least-engaged customers.
with num as (
SELECT o.customernumber ,
       round(sum(od.quantityordered *(od.priceeach - p.buyprice)),2) AS Profit
FROM products p
  JOIN orderdetails od 
     ON   p.productCode = od.productCode
  JOIN orders o
     on od.ordernumber = o.ordernumber   
GROUP by o.customernumber)

SELECT c.contactfirstname , c.contactlastname , c.city , c.country , n.Profit
from customers c 
JOIN num n
ON c.customerNumber = n.customernumber
order by n.Profit  
limit 5

Question 3: How much can we spend on acquiring new customers?	 
	   
In order to answer this question, we have to find out the Customer Lifetime Value  which " a metric that represents the total net profit a company can expect to generate from a customer throughout their entire relationship". 
From there we can determine how much we want to spend on acquiring new customers 

--Average customer profits       
 WITH
  profit_gen_table AS (
	SELECT os.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS prof_gen  
      FROM products pr
	  JOIN orderdetails od
	    ON pr.productCode = od.productCode
	  JOIN orders os
	    ON od.orderNumber = os.orderNumber
     GROUP BY os.customerNumber
  )
   SELECT AVG(pg.prof_gen) AS lyf_tym_val
     FROM profit_gen_table pg         




Conclusion:

Question 1: Which product is the most popular?
Answer 1: Analysis  the query results indicates that the most popular and favored product within the company is 'Classic Cars' 
         This product stands out as the most widely recognized and attracts the highest number of purchases

 
Question 2: Which products should we order more of or less of?
Answer 2: Analysing the query results of comparing low stock with product performance we can see that, 6 out 10 cars belong to 'Classic Cars' product line. 
          They sell frequently with high product performance As such we should be re-stocked these frequently


Question 3: How should we tailor marketing and communication strategies to customer behaviors?
Answer 3: Analysing the query results of top and bottom customers in terms of profit generation, we need to offer loyalty rewards and priority services for our top customers to retain them.
          Also for bottom customers we need to solicit feedback to better understand their preferences, expected pricing, discount and offers to increase our sales


Question 4: How much can we spend on acquiring new customers?
Answer 4: The average customer liftime value of our store is $ 39,040. This means for every new customer we make profit of 39,040 dollars. 
	      We can use this to predict how much we can spend on new customer acquisition,at the same time maintain or increase our profit levels.
 
PROJECT END			 




