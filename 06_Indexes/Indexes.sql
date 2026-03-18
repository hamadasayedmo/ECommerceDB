
-- 1. Orders per User (JOINs / filters on UserId)
CREATE INDEX IX_Orders_UserId
ON sales.Orders(UserId);

-- 2. OrderItems per Product (aggregations)
CREATE INDEX IX_OrderItems_ProductId_Quantity
ON sales.OrderItems(ProductId)
INCLUDE (Quantity);

-- 3. Total Revenue per User (covering for SUM queries)
CREATE INDEX IX_Orders_UserId_TotalAmount
ON sales.Orders(UserId)
INCLUDE (TotalAmount);

-- 4. Orders + OrderItems multi-join
CREATE INDEX IX_Orders_UserId_Id
ON sales.Orders(UserId)
INCLUDE (Id);

CREATE INDEX IX_OrderItems_OrderId_ProductId
ON sales.OrderItems(OrderId, ProductId);

-- 5. Latest Orders per User (ORDER BY optimization)
CREATE INDEX IX_Orders_UserId_OrderDate
ON sales.Orders(UserId, OrderDate DESC);

-- 6. Products by Category
CREATE INDEX IX_Products_CategoryId
ON catalog.Products(CategoryId);

-- 7. Active Products per Category (filtered index)
CREATE INDEX IX_Products_Active_Category
ON catalog.Products(CategoryId)
WHERE IsActive = 1;

-- 8. Orders by Status (aggregations for dashboard)
CREATE INDEX IX_Orders_Status
ON sales.Orders(Status);

-- 9. Product Sales + Revenue (covering for SUM Quantity*Price)
CREATE INDEX IX_OrderItems_ProductId_Price
ON sales.OrderItems(ProductId)
INCLUDE (Quantity, Price);

-- 10. Cart per User
CREATE INDEX IX_Cart_UserId
ON sales.CartItems(UserId);