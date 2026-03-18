
-- Create Database
CREATE DATABASE ECommerceDB;
GO

USE ECommerceDB;
GO



-- Create Schemas (for clean structure)
CREATE SCHEMA [catalog];
GO

CREATE SCHEMA [sales];
GO

CREATE SCHEMA [identity];
GO



-- Users (store application users)
CREATE TABLE [identity].Users
(
    Id INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(20) NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO



-- Categories (used to group products)
CREATE TABLE [catalog].Categories 
(
	Id INT IDENTITY PRIMARY KEY,
	[Name] VARCHAR(100) NOT NULL,
	[Description] VARCHAR(500) NULL,
	CreatedAt DATETIME DEFAULT GETDATE()
);
GO



-- Products (main product data)
-- each product belongs to one category
CREATE TABLE [catalog].Products 
(
	Id INT IDENTITY PRIMARY KEY,
	[Name] NVARCHAR(200) NOT NULL,
	[Description] NVARCHAR(MAX),
	Price DECIMAL(10,2) NOT NULL,
	Stock INT NOT NULL,
	IsActive BIT DEFAULT 1,
	CreatedAt DATETIME DEFAULT GETDATE(),
	CategoryId INT NOT NULL,

	-- link product to category
	CONSTRAINT FK_Product_Category
		FOREIGN KEY(CategoryId)
		REFERENCES [catalog].Categories(Id)
);
GO



-- Orders (user purchases)
-- one user can have many orders
CREATE TABLE [sales].Orders 
(
	Id INT IDENTITY PRIMARY KEY,
	UserId INT NOT NULL,
	OrderDate DATETIME DEFAULT GETDATE(),
	TotalAmount DECIMAL(10,2) NOT NULL,
	Status NVARCHAR(50) NOT NULL,

	-- link order to user
	CONSTRAINT FK_Order_User
		FOREIGN KEY(UserId)
		REFERENCES [identity].Users(Id)
);
GO



-- OrderItems (order details)
-- connects orders with products
CREATE TABLE [sales].OrderItems
(
	Id INT IDENTITY PRIMARY KEY,
	OrderId INT NOT NULL,
	ProductId INT NOT NULL,
	Quantity INT NOT NULL,
	Price DECIMAL(10,2) NOT NULL,

	-- link to order
	CONSTRAINT FK_OrderItem_Order
		FOREIGN KEY (OrderId)
		REFERENCES [sales].Orders(Id),

	-- link to product
	CONSTRAINT FK_OrderItem_Product
		FOREIGN KEY (ProductId)
		REFERENCES [catalog].Products(Id)
);
GO



-- ProductReviews (user feedback)
-- used in product details page
CREATE TABLE [catalog].ProductReviews
(
    Id INT IDENTITY PRIMARY KEY,
    ProductId INT NOT NULL,
    UserId INT NOT NULL,
    Rating INT CHECK (Rating >= 1 AND Rating <= 5),
    Comment NVARCHAR(1000) NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_Review_Product 
        FOREIGN KEY (ProductId)
        REFERENCES catalog.Products(Id),

    CONSTRAINT FK_Review_User 
        FOREIGN KEY (UserId)
        REFERENCES [identity].Users(Id)
);
GO



-- CartItems (shopping cart)
-- prevent duplicate product per user
CREATE TABLE sales.CartItems
(
    Id INT IDENTITY PRIMARY KEY,
    UserId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Cart_User 
		FOREIGN KEY (UserId)
		REFERENCES [identity].Users(Id),

    CONSTRAINT FK_Cart_Product 
		FOREIGN KEY (ProductId)
		REFERENCES [catalog].Products(Id),

    -- same product can't be added twice
    CONSTRAINT UQ_Cart UNIQUE (UserId, ProductId) 
);
GO



-- Payments (handle checkout)
-- each order has one payment
CREATE TABLE sales.Payments
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE(), 
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL, 
    [Status] NVARCHAR(50) NOT NULL,

    -- link payment to order
    CONSTRAINT FK_Payment_Order
		FOREIGN KEY (OrderId)
		REFERENCES sales.Orders(Id)
);
GO