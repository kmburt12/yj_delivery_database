Yellow Jacket Delivery Database

Overview: This project was developed to recreate a campus delivery system using a relational database in MySQL. The database models users, orders, warehouses, trucks, and routes to simulate how packages move through a delivery service. The code also includes a link to a YouTube video demonstration that walks through the implementation of key stored procedures, such as updating delivery routes and hiring new workers

Features:
- Entity-Relationship Design: Created an ER diagram to define relationships between core entities (orders, warehouses, routes, workers).
- Normalized Tables: Structured data to minimize redundancy and ensure integrity.
- Stored Procedures: Implemented procedures to handle real-world logistics scenarios such as updating delivery routes, assigning packages, and hiring new workers.

Technologies Used:
- MySQL
- SQL (DDL, DML, Stored Procedures)

Example Query:
-- Example: Update an existing leg of a route: call yellow_jacket_delivery.add_update_leg('leg_25', 1800, 'SEA', 'LAX');

Project Context: This database was created as a team project for a database systems course at the Georgia Institute of Technology. It demonstrates both theoretical design (ER diagrams, normalization) and practical application (SQL queries and stored procedures).
