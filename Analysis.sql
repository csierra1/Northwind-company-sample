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
Order by ProductID;

--5. A salesperson of the company is going on a business trip to visit some customers, she needs a list of customers by region

Select CustomerID,CompanyName,ContactName,Region, 
Case
	When Region IS NULL then 1
	else 0

End as 'Ordering'
From Customers
Order by Ordering,CustomerID;
