-- Returns total amount for a specific order
-- use case: checkout, invoice, dashboard
CREATE OR ALTER FUNCTION fn_TotalOrderAmount(@OrderId INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2);

    SELECT @Total = SUM(Quantity * Price)
    FROM sales.OrderItems
    WHERE OrderId = @OrderId;

    RETURN @Total;
END;
GO

-- Test query for order #18
SELECT dbo.fn_TotalOrderAmount(18) AS TotalAmount;





-- Returns all products in a given category
-- use case: category page, filtering products
CREATE OR ALTER FUNCTION fn_ProductsByCategory(@CategoryId INT)
RETURNS TABLE
AS
RETURN
    SELECT 
        Id, 
        Name, 
        Price, 
        Stock, 
        IsActive
    FROM catalog.Products
    WHERE CategoryId = @CategoryId;
GO

-- Test query for category #8, only active products
SELECT * 
FROM fn_ProductsByCategory(8)
WHERE IsActive = 1;