-- =========================================
-- E-COMMERCE DATABASE 
-- =========================================

DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- ======================
-- TABLES
-- ======================

CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    address TEXT,
    CHECK (email LIKE '%@%.%')
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock INT NOT NULL CHECK (stock >= 0),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) DEFAULT 0,
    status ENUM('Pending','Processing','Shipped','Delivered','Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_method ENUM('Card','UPI','Cash') NOT NULL,
    status ENUM('Pending','Completed','Failed') DEFAULT 'Pending',
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    UNIQUE(customer_id, product_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Shipping (
    shipping_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    address TEXT NOT NULL,
    status ENUM('Pending','Dispatched','Delivered') DEFAULT 'Pending',
    delivery_date DATE,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ======================
-- INDEXES
-- ======================

CREATE INDEX idx_customer_email ON Customers(email);
CREATE INDEX idx_product_category ON Products(category_id);
CREATE INDEX idx_order_date ON Orders(order_date);
CREATE INDEX idx_payment_method ON Payments(payment_method);

-- ======================
-- TRIGGERS 
-- ======================

DELIMITER //

-- INSERT
CREATE TRIGGER trg_after_insert
AFTER INSERT ON Order_Items
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET total_amount = (
        SELECT IFNULL(SUM(quantity * price),0)
        FROM Order_Items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END //

-- UPDATE
CREATE TRIGGER trg_after_update
AFTER UPDATE ON Order_Items
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET total_amount = (
        SELECT IFNULL(SUM(quantity * price),0)
        FROM Order_Items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END //

-- DELETE
CREATE TRIGGER trg_after_delete
AFTER DELETE ON Order_Items
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET total_amount = (
        SELECT IFNULL(SUM(quantity * price),0)
        FROM Order_Items
        WHERE order_id = OLD.order_id
    )
    WHERE order_id = OLD.order_id;
END //

-- Payment validation
CREATE TRIGGER trg_validate_payment
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
    DECLARE order_total DECIMAL(10,2);

    SELECT total_amount INTO order_total
    FROM Orders
    WHERE order_id = NEW.order_id;

    IF NEW.amount > order_total THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment exceeds order total!';
    END IF;
END //

DELIMITER ;

-- ======================
-- VIEW
-- ======================

CREATE VIEW CustomerOrders AS
SELECT c.name, o.order_id, o.total_amount, o.status
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id;

-- ======================
-- STORED PROCEDURE
-- ======================

DELIMITER //

CREATE PROCEDURE GetCustomerOrders(IN cid INT)
BEGIN
    SELECT * FROM Orders WHERE customer_id = cid;
END //

DELIMITER ;

-- ======================
-- DATA
-- ======================

INSERT INTO Categories (category_name) VALUES
('Electronics'),('Fashion'),('Home');

INSERT INTO Customers (name,email,phone,address) VALUES
('Harsh','h1@gmail.com','1111111111','Rajasthan'),
('Rahul','h2@gmail.com','2222222222','Delhi'),
('Priya','h3@gmail.com','3333333333','Mumbai'),
('Amit','amit@gmail.com','9000000001','Jaipur'),
('Neha','neha@gmail.com','9000000002','Delhi'),
('Riya','riya@gmail.com','9000000003','Mumbai'),
('Karan','karan@gmail.com','9000000004','Pune'),
('Ankit','ankit@gmail.com','9000000005','Hyderabad'),
('Simran','simran@gmail.com','9000000006','Chandigarh'),
('Vikas','vikas@gmail.com','9000000007','Lucknow'),
('Pooja','pooja@gmail.com','9000000008','Bangalore'),
('Rohit','rohit@gmail.com','9000000009','Chennai'),
('Sneha','sneha@gmail.com','9000000010','Kolkata'),
('Manish','manish@gmail.com','9000000011','Indore'),
('Divya','divya@gmail.com','9000000012','Surat'),
('Arjun','arjun@gmail.com','9000000013','Noida'),
('Meena','meena@gmail.com','9000000014','Patna'),
('Raj','raj@gmail.com','9000000015','Nagpur'),
('Kavya','kavya@gmail.com','9000000016','Bhopal'),
('Sahil','sahil@gmail.com','9000000017','Agra');

INSERT INTO Products (name,category_id,price,stock) VALUES
('Laptop',1,80000,10),('Phone',1,30000,20),('Shoes',2,2000,50),
('Tablet',1,25000,15),('Smartwatch',1,10000,25),('Camera',1,45000,8),
('Speaker',1,5000,30),('Jacket',2,3000,40),('Dress',2,2500,35),
('Bed',3,20000,5),('Cupboard',3,15000,7),('Fan',3,3000,20),
('AC',1,40000,6),('Microwave',3,12000,10),('Refrigerator',3,35000,4),
('Watch',2,2000,50),('Bag',2,1500,60),('Helmet',2,1800,45);

INSERT INTO Orders (customer_id,order_date,status) VALUES
(1,'2026-01-01','Delivered'),
(2,'2026-02-10','Shipped'),
(3,'2026-02-15','Pending'),
(4,'2026-03-01','Delivered'),
(5,'2026-03-05','Processing'),
(6,'2026-03-10','Delivered'),
(7,'2026-03-15','Cancelled'),
(8,'2026-03-20','Delivered'),
(9,'2026-03-22','Shipped'),
(10,'2026-03-25','Pending'),
(11,'2026-03-28','Delivered'),
(12,'2026-04-01','Processing'),
(13,'2026-04-05','Delivered'),
(14,'2026-04-08','Cancelled'),
(15,'2026-04-10','Delivered'),
(16,'2026-04-12','Shipped'),
(17,'2026-04-15','Pending'),
(18,'2026-04-18','Delivered'),
(19,'2026-04-20','Processing'),
(20,'2026-04-22','Delivered');

INSERT INTO Order_Items (order_id,product_id,quantity,price) VALUES
(1,1,1,80000),(1,3,1,2000),(2,2,1,30000),
(4,4,1,25000),(5,5,2,10000),(6,6,1,45000),
(7,7,1,5000),(8,8,1,3000),(9,9,2,2500),
(10,10,1,20000),(11,11,1,15000),(12,12,1,3000),
(13,13,2,40000),(14,14,3,12000),(15,15,1,35000),
(16,16,1,2000),(17,17,2,1500),(18,18,1,1800),
(19,1,1,80000),(20,2,1,30000);

INSERT INTO Payments (order_id,payment_date,amount,payment_method,status) VALUES
(1,'2026-01-01',82000,'Card','Completed'),
(2,'2026-02-10',30000,'UPI','Completed'),
(4,'2026-03-01',25000,'Card','Completed'),
(5,'2026-03-05',20000,'UPI','Completed'),
(6,'2026-03-10',45000,'Cash','Completed'),
(8,'2026-03-20',3000,'Card','Completed'),
(9,'2026-03-22',5000,'UPI','Completed'),
(11,'2026-03-28',15000,'Card','Completed'),
(12,'2026-04-01',3000,'UPI','Completed'),
(13,'2026-04-05',80000,'Cash','Completed');

INSERT INTO Shipping (order_id,address,status,delivery_date) VALUES
(1,'Rajasthan','Delivered','2026-01-05'),
(2,'Delhi','Dispatched','2026-02-15'),
(4,'Pune','Delivered','2026-03-05'),
(6,'Hyderabad','Delivered','2026-03-14'),
(8,'Chandigarh','Delivered','2026-03-23'),
(9,'Lucknow','Delivered','2026-03-28'),
(11,'Kolkata','Delivered','2026-04-02'),
(13,'Noida','Delivered','2026-04-10'),
(15,'Nagpur','Delivered','2026-04-15'),
(18,'Agra','Delivered','2026-04-22');

INSERT INTO Reviews (customer_id,product_id,rating,comment) VALUES
(1,1,5,'Excellent'),(2,2,4,'Good'),(3,3,3,'Average'),
(4,4,5,'Great'),(5,5,4,'Nice'),(6,6,3,'Okay'),
(7,7,5,'Perfect'),(8,8,4,'Good'),(9,9,5,'Amazing'),
(10,10,4,'Useful');

-- ======================
-- TRANSACTION
-- ======================

START TRANSACTION;
UPDATE Products SET stock = stock - 1 WHERE product_id = 1;
COMMIT;

-- ======================
-- CRUD
-- ======================

INSERT INTO Customers (name,email,phone,address)
VALUES ('NewUserr','neww@gmail.com','9999999990','Pok');

UPDATE Orders SET status = 'Delivered' WHERE order_id = 3;

DELETE FROM Reviews WHERE review_id = 1;

SELECT * FROM Orders;
-- ======================
-- ADVANCED QUERIES
-- ======================
SELECT MONTH(order_date) AS month, SUM(total_amount) AS revenue
FROM Orders GROUP BY MONTH(order_date);

SELECT name, stock FROM Products WHERE stock < 15;

SELECT o.order_id
FROM Orders o
LEFT JOIN Payments p ON o.order_id = p.order_id
WHERE p.payment_id IS NULL;

SELECT p.name, SUM(oi.quantity) AS total_sold
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.name;

SELECT payment_method, COUNT(*) AS usage_count
FROM Payments GROUP BY payment_method;

SELECT name, total_spent
FROM (
    SELECT c.customer_id, c.name, SUM(o.total_amount) AS total_spent
    FROM Customers c
    JOIN Orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.name
) AS summary
WHERE total_spent > (SELECT AVG(total_amount) FROM Orders);

-- ADDED QUERIES

SELECT cat.category_name, SUM(oi.quantity * oi.price) AS revenue
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
JOIN Categories cat ON p.category_id = cat.category_id
GROUP BY cat.category_name;

SELECT p.name, AVG(r.rating) AS avg_rating, COUNT(r.review_id) AS total_reviews
FROM Products p
LEFT JOIN Reviews r ON p.product_id = r.product_id
GROUP BY p.name;

SELECT c.name, o.order_id, o.total_amount, pay.amount
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
LEFT JOIN Payments pay ON o.order_id = pay.order_id;


