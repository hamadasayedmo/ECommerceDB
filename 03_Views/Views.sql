
-- Shows all orders with user info and product details
-- uses fn_TotalOrderAmount to calculate total per order
CREATE OR ALTER VIEW vw_OrderDetails AS
SELECT 
    o.Id AS OrderId,
    u.FullName AS UserName,
    p.Name AS ProductName,
    o.OrderDate,
    oi.Quantity,
    oi.Price,
    dbo.fn_TotalOrderAmount(o.Id) AS TotalAmount -- calculate total per order

FROM sales.Orders o
JOIN [identity].Users u
    ON o.UserId = u.Id

JOIN sales.OrderItems oi
    ON o.Id = oi.OrderId

JOIN catalog.Products p
    ON oi.ProductId = p.Id;
GO

-- Test query for a single order
SELECT * 
FROM vw_OrderDetails
WHERE OrderId = 250;




-- Shows top selling products by total quantity
-- good for dashboards or analytics pages
CREATE OR ALTER VIEW vw_TopSellingProducts AS
SELECT 
    p.Id AS ProductId,
    p.Name AS ProductName,
    SUM(oi.Quantity) AS TotalSold
FROM sales.OrderItems oi
JOIN catalog.Products p
    ON oi.ProductId = p.Id
GROUP BY p.Id, p.Name;
GO

-- Test queries
SELECT * FROM vw_TopSellingProducts;
SELECT TOP 10 *
FROM vw_TopSellingProducts
ORDER BY TotalSold DESC;




-- Shows the most recent order for each user
-- useful for admin dashboard or user profile
CREATE OR ALTER VIEW vw_LatestOrdersPerUser AS
SELECT 
    o.Id AS OrderId,
    o.OrderDate,
    u.Id AS UserId,
    u.FullName AS UserName,
    o.TotalAmount,
    o.Status

FROM sales.Orders o
JOIN [identity].Users u
    ON o.UserId = u.Id

WHERE o.OrderDate = (
    SELECT MAX(OrderDate)
    FROM sales.Orders
    WHERE UserId = u.Id
);
GO

-- Test query
SELECT TOP(10) *
FROM vw_LatestOrdersPerUser
ORDER BY OrderDate DESC;