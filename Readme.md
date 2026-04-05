# E-Commerce Database Management System (SQL Project)

## Project Overview

This project presents the design and implementation of a relational database system for an E-commerce platform using SQL. The system manages structured data such as customers, products, orders, payments, shipping, and reviews.

The database ensures data integrity, consistency, and efficient querying through normalization, constraints, triggers, and indexing.

---

## How to Run the Project

1. Install MySQL or use MySQL Workbench
2. Open the SQL file (`ecommerce_db.sql`)
3. Execute the script step-by-step or run all at once
4. The database `ecommerce_db` will be created automatically
5. Tables, constraints, triggers, and sample data will be inserted
6. Run SELECT queries to verify outputs

---

## Database Structure

The system includes the following tables:

* Customers
* Products
* Categories
* Orders
* Order_Items
* Payments
* Shipping
* Reviews

---

## Relationships

* One customer can place multiple orders (1:N)
* One order can contain multiple order items (1:N)
* One product can appear in multiple order items (1:N)
* One category can include multiple products (1:N)
* Orders and products have a many-to-many relationship resolved through Order_Items

---

### ER Diagram Explanation

The ER diagram visually represents the structure of the database:

* **Customers → Orders (1:N)**
  A single customer can place multiple orders

* **Orders → Order_Items (1:N)**
  Each order can contain multiple products

* **Products → Order_Items (1:N)**
  A product can appear in multiple orders

* **Orders ↔ Products (M:N)**
  This relationship is resolved using the Order_Items table

* **Categories → Products (1:N)**
  Each category groups multiple products

* **Orders → Payments (1:N)**
  Allows multiple payment attempts for an order

* **Orders → Shipping (1:1)**
  Each order has one shipping record

* **Customers → Reviews (1:N)**

* **Products → Reviews (1:N)**

The diagram ensures clear visualization of relationships and helps maintain referential integrity.

---

## Features Implemented

### Constraints

* Primary Keys on all tables
* Foreign Keys for relationships
* UNIQUE constraint on email
* Composite UNIQUE on Reviews
* CHECK constraints for validation

---

### Triggers

* `trg_after_insert` – updates order total after insert
* `trg_after_update` – updates order total after update
* `trg_after_delete` – updates order total after delete
* `trg_validate_payment` – prevents overpayment

---

### Indexing

* Email (Customers)
* Category (Products)
* Order Date
* Payment Method

---

### View

* CustomerOrders

---

### Stored Procedure

* GetCustomerOrders(cid)

---

### Transactions

* Ensures safe stock updates

---

## CRUD Operations

### Insert

INSERT INTO Customers (name,email,phone,address)
VALUES ('NewUserr','neww@gmail.com','9999999990','Pok');


### Update

UPDATE Orders SET status = 'Delivered' WHERE order_id = 3;

### Delete


DELETE FROM Reviews WHERE review_id = 1;


### Select

SELECT * FROM Orders;


## Normalization

* 1NF: All attributes are atomic
* 2NF: In Order_Items, attributes depend on full key
* 3NF: Customer data separated from Orders

---

## Challenges and Solutions

| Challenge                                             | Solution                              |
| ----------------------------------------------------- | ------------------------------------- |
| Many-to-many relationship between Orders and Products | Introduced Order_Items junction table |
| Maintaining accurate order total                      | Implemented triggers for automation   |
| Preventing invalid payments                           | Added validation trigger              |
| Ensuring data consistency                             | Applied foreign keys and constraints  |
| Improving query performance                           | Implemented indexing                  |

---

## Results

The system successfully:

* Executes CRUD operations
* Handles complex queries
* Maintains data integrity
* Simulates real-world e-commerce operations

---

## Future Improvements

* Web interface integration
* Authentication system
* Advanced analytics
* Scalability improvements

---

## Author

Name: Arjungowda Devarahalli Nagaraj
Student ID: GH1047219
