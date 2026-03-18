
-- DML: Categories
DELETE FROM [catalog].Categories
WHERE Id > 20;



-- one payment per order (real scenario)
ALTER TABLE sales.Payments
ADD CONSTRAINT UQ_Payment_Order UNIQUE (OrderId);



-- find duplicated orders in payments
SELECT OrderId, COUNT(*) AS CountPayments
FROM sales.Payments
GROUP BY OrderId
HAVING COUNT(*) > 1;

