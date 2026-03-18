# ECommerceDB

ECommerceDB is a SQL Server project simulating a full-featured e-commerce platform.  
This project is designed as a **learning tool** to practice database concepts, including:

- Database design with multiple schemas (`catalog`, `sales`, `identity`)
- Tables with relationships, constraints, and data integrity
- Indexes for performance optimization
- Views to simplify queries
- Functions for reusable logic
- Stored Procedures for common operations (checkout, add to cart, reviews)
- Test queries to evaluate performance

## Seed Data

The database includes realistic seed data generated using [Mockaroo](https://mockaroo.com/):

- 1000 Users  
- 20 Categories  
- 1000 Products  
- 1000 Orders  

## Getting Started

1. Run `01_DDL.sql` to create the database, schemas, and tables.  
2. Run `02_DML.sql` to populate tables with seed data.  
3. Run `06_Indexes.sql` to create indexes for optimized queries.  
4. Explore `03_Views.sql`, `04_Functions.sql`, `05_StoredProcedures.sql` for advanced examples.  
5. Test performance using `07_TestQueries.sql`.  

## Purpose

This project is meant to **demonstrate SQL Server skills** for real-world e-commerce scenarios and to practice writing efficient queries and database objects.
