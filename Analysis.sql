-- 1. List the number of products in each category

Select CategoryName,Count(CategoryName) as 'Products by Category'
From Products
Join Categories
On Categories.CategoryID=Products.CategoryID
group by CategoryName
order by TotalProductsByCategory DESC;

-- 2. List all the employees with their birth date and time they have been working in the company

Select FirstName+' '+LastName as 'Full_Name',CONVERT(date,BirthDate) as 'Birth Date',DATEDIFF(YEAR,HireDate,GETDATE())as 'Years_company'
From Employees
Order by BirthDate ASC;

-- 3. We want to know the orders shipped to France, Belgium or Spain during 2014

Select OrderID,CustomerID,ShipCountry
From Orders
Where ShipCountry IN ('France','Belgium','Spain') AND Year(ShippedDate)='2014';

-- 4. A list of all the Products with associated Supplier

Select ProductID,ProductName,CompanyName as Supplier
From Products
Join Suppliers
On Suppliers.SupplierID=Products.SupplierID
Order by Supplier;

--5. A salesperson of the company is going on a business trip to visit some customers, she needs a list of customers by region

Select CustomerID,CompanyName,ContactName,Region, 
Case
	When Region IS NULL then 1
	else 0

End as 'Ordering'
From Customers
Order by Ordering,CustomerID;

/*6. We want to analyse the freight charges to investigate some other shipping options, whether we can offer them lower freight charges
We take Top 3 countries with highest freights in average over time and compared with the last year*/

with alltime as(
Select ShipCountry,Avg(Freight) as Avg_Freight
From Orders
Group by ShipCountry
Order by Avg_Freight DESC OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY)

,lastyear as(
Select ShipCountry,Avg(Freight) as 'Avg Freight last year'
From Orders
Where OrderDate > DATEADD(yy,-1,(select max(OrderDate) from Orders))
Group by ShipCountry
Order by [Avg Freight last year] DESC OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY)

select alltime.ShipCountry,Avg_Freight,[Avg Freight last year]
From alltime
Join lastyear
On alltime.ShipCountry=lastyear.ShipCountry
order by Avg_Freight DESC;

--7. We want to know the customers with no orders

Select Customers.CustomerID, Orders.OrderID
From Customers
Left Join Orders
On Customers.CustomerID=Orders.CustomerID
Where Orders.CustomerID IS NULL;

/* 8. We want to send all a special gift to all our high-value customers. We defined high-value customers, those who made at least 1
order with total value of 10.000$ or more in the year 2016*/

Select Customers.CustomerID,Customers.CompanyName,'Amount'=SUM(Quantity*UnitPrice)
From Customers
Join Orders
On Customers.CustomerID=Orders.CustomerID
Join OrderDetails
On Orders.OrderID=OrderDetails.OrderID
	
Where year(Orders.OrderDate)=2016
Group by Customers.CustomerID,Customers.CompanyName
Having SUM(Quantity*UnitPrice)>=10000
Order by Amount DESC,Customers.CustomerID;

/* 9. There has been an incident with a order request, a salesperson entered a item twice in an order. We know that is a different ProductID,
with same quantity, and the quantity was 60 or more. We need to get the order and the details*/

Select OrderID,ProductID,UnitPrice,Quantity
From OrderDetails
where OrderID IN (select OrderID From OrderDetails group by OrderID,Quantity having Quantity>=60 AND COUNT(ProductID)>1)
Order by OrderID,ProductID ASC;

/*10. Some customers complained about the orders arriving late. We want to analyse what's happening?
How many orders were late? */

Select Count(OrderID) as 'Late'
From orders	
Where ShippedDate > RequiredDate;

--Analyse which salespeople have the orders arriving late and compare with number of sales (orders) they made

;With LateOrders as(
Select EmployeeID,'Late Orders'=Count(*)
From Orders
Where ShippedDate >= RequiredDate
Group by EmployeeID)

,AllOrders as(
Select EmployeeID, 'Total Orders'=Count(*)
From Orders
Group by EmployeeID)

Select Employees.EmployeeID,FirstName+' '+LastName as 'Employee Name',AllOrders.[Total Orders],'Late Orders'=ISNULL(LateOrders.[Late Orders],0)
From Employees
Join AllOrders
On AllOrders.EmployeeID=Employees.EmployeeID
Left Join LateOrders
On LateOrders.EmployeeID=Employees.EmployeeID
Order by Employees.EmployeeID;

--What is the percentage of orders late?
;With LateOrders as(
Select EmployeeID, 'Late Orders'=Count(*)
From Orders
Where ShippedDate >= RequiredDate
Group by EmployeeID)

,AllOrders as(
Select EmployeeID,'Total Orders'=Count(*)
From Orders
Group by EmployeeID)

Select Employees.EmployeeID,FirstName+' '+LastName as 'Employee Name',
'% late orders'= convert(decimal(4,4),ISNULL(LateOrders.[Late Orders],0)*1.00/AllOrders.[Total Orders])*100
From Employees
Join AllOrders
On AllOrders.EmployeeID=Employees.EmployeeID
Left Join LateOrders 
On LateOrders.EmployeeID=Employees.EmployeeID
Order by [% late orders] DESC;
