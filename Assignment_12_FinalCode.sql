
DROP TABLE IF EXISTS OrderPizzas;
DROP TABLE IF EXISTS CustomerOrders;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Pizzas;


CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL
);


CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    OrderDateTime DATETIME NOT NULL
);

CREATE TABLE Pizzas (
    PizzaID INT PRIMARY KEY AUTO_INCREMENT,
    PizzaName VARCHAR(50) NOT NULL,
    Price DECIMAL(5,2) NOT NULL
);


CREATE TABLE CustomerOrders (
    CustomerOrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    OrderID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


CREATE TABLE OrderPizzas (
    OrderPizzaID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT NOT NULL,
    PizzaID INT NOT NULL,
    Quantity INT NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (PizzaID) REFERENCES Pizzas(PizzaID)
);


INSERT INTO Pizzas (PizzaName, Price) VALUES 
('Pepperoni & Cheese', 7.99),
('Vegetarian', 9.99),
('Meat Lovers', 14.99),
('Hawaiian', 12.99);


INSERT INTO Customers (Name, PhoneNumber) VALUES 
('Trevor Page', '226-555-4982'),
('John Doe', '555-555-9498');


INSERT INTO Orders (OrderDateTime) VALUES 
('2023-09-10 09:47:00'),
('2023-09-10 13:20:00'),
('2023-09-10 09:47:00'),
('2023-10-10 10:37:00');

INSERT INTO CustomerOrders (CustomerID, OrderID) VALUES
(1, 1),
(2, 2),
(1, 3),
(2, 4);


INSERT INTO OrderPizzas (OrderID, PizzaID, Quantity) VALUES
(1, 1, 1), 
(1, 3, 1),
(2, 2, 1), 
(2, 3, 2), 
(3, 3, 1), 
(3, 4, 1), 
(4, 2, 3), 
(4, 4, 1); 


SELECT 
    c.Name AS CustomerName,
    c.PhoneNumber,
    SUM(p.Price * op.Quantity) AS TotalSpent
FROM 
    Customers c
JOIN 
    CustomerOrders co ON c.CustomerID = co.CustomerID
JOIN 
    Orders o ON co.OrderID = o.OrderID
JOIN 
    OrderPizzas op ON o.OrderID = op.OrderID
JOIN 
    Pizzas p ON op.PizzaID = p.PizzaID
GROUP BY 
    c.CustomerID, c.Name, c.PhoneNumber
ORDER BY 
    TotalSpent DESC;


WITH CustomerSpending AS (
    SELECT 
        c.Name AS CustomerName,
        c.PhoneNumber,
        DATE(o.OrderDateTime) AS OrderDate,
        SUM(p.Price * op.Quantity) AS TotalSpent
    FROM 
        Customers c
    JOIN 
        CustomerOrders co ON c.CustomerID = co.CustomerID
    JOIN 
        Orders o ON co.OrderID = o.OrderID
    JOIN 
        OrderPizzas op ON o.OrderID = op.OrderID
    JOIN 
        Pizzas p ON op.PizzaID = p.PizzaID
    GROUP BY 
        c.CustomerID, c.Name, c.PhoneNumber, DATE(o.OrderDateTime)
    ORDER BY 
        c.Name, OrderDate
)

SELECT 
    CASE WHEN @prev_name = CustomerName THEN '' ELSE CustomerName END AS CustomerName,
    CASE WHEN @prev_name = CustomerName THEN '' ELSE PhoneNumber END AS PhoneNumber,
    OrderDate,
    TotalSpent,
    @prev_name := CustomerName
FROM 
    CustomerSpending, 
    (SELECT @prev_name := '') AS vars;
