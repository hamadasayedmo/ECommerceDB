
-- Returns all orders of a specific user with product details
-- Use case: user order history page
CREATE OR ALTER PROCEDURE sp_GetUserOrders
    @UserId INT
AS
BEGIN
    SELECT 
        o.Id AS OrderId,
        o.OrderDate,
        o.TotalAmount,
        o.Status,
        p.Name AS ProductName,
        oi.Quantity,
        oi.Price
    FROM sales.Orders o
    JOIN sales.OrderItems oi
        ON o.Id = oi.OrderId 
    JOIN catalog.Products p
        ON oi.ProductId = p.Id
    WHERE o.UserId = @UserId
    ORDER BY o.OrderDate DESC;
END
GO

-- Test query
EXEC sp_GetUserOrders @UserId = 6;




-- Add review for product by user
-- Validation: user must have purchased the product
-- Use case: product review system
CREATE OR ALTER PROCEDURE sp_AddProductReview
    @UserId INT,
    @ProductId INT,
    @Rating INT,
    @Comment NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    -- check if user bought the product
    IF NOT EXISTS (
        SELECT 1
        FROM sales.OrderItems oi
        JOIN sales.Orders o ON oi.OrderId = o.Id
        WHERE o.UserId = @UserId AND oi.ProductId = @ProductId
    )
    BEGIN
        RAISERROR('User has not purchased this product', 16, 1);
        RETURN;
    END

    INSERT INTO catalog.ProductReviews(ProductId, UserId, Rating, Comment)
    VALUES (@ProductId, @UserId, @Rating, @Comment);
END
GO

-- Test query
EXEC sp_AddProductReview 
    @UserId = 5, 
    @ProductId = 3, 
    @Rating = 5, 
    @Comment = 'Excellent product very fast delivery';
GO




-- Adds product to user cart
-- If already exists, increments quantity
-- Use case: shopping cart system
CREATE OR ALTER PROCEDURE sp_AddToCart
    @UserId INT,
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM sales.CartItems 
        WHERE UserId = @UserId AND ProductId = @ProductId
    )
    BEGIN
        UPDATE sales.CartItems
        SET Quantity = Quantity + @Quantity
        WHERE UserId = @UserId AND ProductId = @ProductId;
    END
    ELSE
    BEGIN
        INSERT INTO sales.CartItems(UserId, ProductId, Quantity)
        VALUES (@UserId, @ProductId, @Quantity);
    END
END
GO

-- Test query
EXEC sp_AddToCart @UserId = 5, @ProductId = 2, @Quantity = 3;
SELECT * FROM sales.CartItems WHERE UserId = 5;




-- Converts cart items to an order
-- Features:
-- 1. Transaction (commit/rollback)
-- 2. Stock validation
-- 3. Prevent empty cart
-- 4. Updates stock
-- 5. Calculates total amount
-- Use case: checkout process
CREATE OR ALTER PROCEDURE sp_Checkout
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OrderId INT;

        -- check empty cart
        IF NOT EXISTS (SELECT 1 FROM sales.CartItems WHERE UserId = @UserId)
        BEGIN
            RAISERROR('Cart is empty', 16, 1);
            ROLLBACK;
            RETURN;
        END

        -- check stock
        IF EXISTS (
            SELECT 1
            FROM sales.CartItems c
            JOIN catalog.Products p ON c.ProductId = p.Id
            WHERE c.UserId = @UserId AND c.Quantity > p.Stock
        )
        BEGIN
            RAISERROR('Insufficient stock for one or more products', 16, 1);
            ROLLBACK;
            RETURN;
        END

        -- create order
        INSERT INTO sales.Orders(UserId, OrderDate, TotalAmount, Status)
        VALUES (@UserId, GETDATE(), 0, 'Pending');
        SET @OrderId = SCOPE_IDENTITY();

        -- insert order items
        INSERT INTO sales.OrderItems(OrderId, ProductId, Quantity, Price)
        SELECT 
            @OrderId,
            c.ProductId,
            c.Quantity,
            p.Price
        FROM sales.CartItems c
        JOIN catalog.Products p ON c.ProductId = p.Id
        WHERE c.UserId = @UserId;

        -- update product stock
        UPDATE p
        SET p.Stock = p.Stock - c.Quantity
        FROM catalog.Products p
        JOIN sales.CartItems c ON p.Id = c.ProductId
        WHERE c.UserId = @UserId;

        -- update total amount
        UPDATE sales.Orders
        SET TotalAmount = (
            SELECT SUM(Quantity * Price)
            FROM sales.OrderItems
            WHERE OrderId = @OrderId
        )
        WHERE Id = @OrderId;

        -- clear cart
        DELETE FROM sales.CartItems WHERE UserId = @UserId;

        COMMIT;

        PRINT 'Order created successfully';
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- Test flow
SELECT TOP 5 Id, Name, Price, Stock FROM catalog.Products;

-- add products to cart
EXEC sp_AddToCart @UserId = 6, @ProductId = 1, @Quantity = 3;
EXEC sp_AddToCart @UserId = 6, @ProductId = 2, @Quantity = 7;

-- checkout
EXEC sp_Checkout @UserId = 6;

-- check cart is empty
SELECT * FROM sales.CartItems WHERE UserId = 6;