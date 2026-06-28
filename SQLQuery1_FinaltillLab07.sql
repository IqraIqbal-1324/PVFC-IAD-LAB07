USE DatabasefoPVFC;
GO

/* =========================
   DROP TABLES (SAFE ORDER)
========================= */

DROP TABLE IF EXISTS Uses_t;
DROP TABLE IF EXISTS Works_In_t;
DROP TABLE IF EXISTS SUPPLIES_t;
DROP TABLE IF EXISTS Produced_In_t;
DROP TABLE IF EXISTS Order_line_t;
DROP TABLE IF EXISTS Does_Business_In_t;
DROP TABLE IF EXISTS Employee_Skills_t;

DROP TABLE IF EXISTS Orders_t;
DROP TABLE IF EXISTS PRODUCT_t;
DROP TABLE IF EXISTS PRODUCT_LINE_t;
DROP TABLE IF EXISTS WORK_CENTER_t;
DROP TABLE IF EXISTS SALESPERSON_t;
DROP TABLE IF EXISTS VENDOR_t;
DROP TABLE IF EXISTS SKILL_t;
DROP TABLE IF EXISTS RAW_MATERIAL_t;
DROP TABLE IF EXISTS TERRITORY_t;
DROP TABLE IF EXISTS EMPLOYEE_t;
DROP TABLE IF EXISTS CUSTOMER_t;

-- RBAC TABLES
DROP TABLE IF EXISTS RolePermissions;
DROP TABLE IF EXISTS UserRoles;
DROP TABLE IF EXISTS Permissions;
DROP TABLE IF EXISTS Roles;
DROP TABLE IF EXISTS Users;


/* =========================
   CORE TABLES
========================= */

CREATE TABLE CUSTOMER_t (
    Customer_Id INT PRIMARY KEY,
    Customer_Name VARCHAR(25),
    Customer_Address VARCHAR(30),
    Customer_City VARCHAR(20),
    Customer_State VARCHAR(2),
    Postal_Code VARCHAR(10)
);

CREATE TABLE TERRITORY_t (
    Territory_Id INT PRIMARY KEY,
    Territory_Name VARCHAR(50)
);

CREATE TABLE Does_Business_In_t (
    Customer_Id INT,
    Territory_Id INT,
    PRIMARY KEY (Customer_Id, Territory_Id),
    FOREIGN KEY (Customer_Id) REFERENCES CUSTOMER_t(Customer_Id),
    FOREIGN KEY (Territory_Id) REFERENCES TERRITORY_t(Territory_Id)
);

CREATE TABLE EMPLOYEE_t (
    Employee_Id VARCHAR(10) PRIMARY KEY,
    Employee_Name VARCHAR(25),
    Employee_Address VARCHAR(30),
    Employee_BirthDate DATE,
    Employee_City VARCHAR(20),
    Employee_Date_Hired DATE,
    Employee_State VARCHAR(2),
    Employee_Supervisor VARCHAR(10),
    Employee_Zip VARCHAR(10)
);

CREATE TABLE SKILL_t (
    Skill_Id VARCHAR(12) PRIMARY KEY,
    Skill_Description VARCHAR(30)
);

CREATE TABLE Employee_Skills_t (
    Employee_Id VARCHAR(10),
    Skill_Id VARCHAR(12),
    PRIMARY KEY (Employee_Id, Skill_Id),
    FOREIGN KEY (Employee_Id) REFERENCES EMPLOYEE_t(Employee_Id),
    FOREIGN KEY (Skill_Id) REFERENCES SKILL_t(Skill_Id)
);

CREATE TABLE Orders_t (
    Order_Id INT PRIMARY KEY,
    Customer_Id INT,
    Order_Date DATE,
    FOREIGN KEY (Customer_Id) REFERENCES CUSTOMER_t(Customer_Id)
);

CREATE TABLE WORK_CENTER_t (
    Work_Center_Id VARCHAR(12) PRIMARY KEY,
    Work_Center_Location VARCHAR(30)
);

CREATE TABLE PRODUCT_LINE_t (
    Product_Line_Id INT PRIMARY KEY,
    Product_Line_Name VARCHAR(50)
);

CREATE TABLE PRODUCT_t (
    Product_Id INT PRIMARY KEY,
    Product_Line_Id INT,
    Product_Description VARCHAR(50),
    Product_Finish VARCHAR(20),
    Standard_Price DECIMAL(6,2),
    FOREIGN KEY (Product_Line_Id) REFERENCES PRODUCT_LINE_t(Product_Line_Id)
);

CREATE TABLE Produced_In_t (
    Product_Id INT,
    Work_Center_Id VARCHAR(12),
    PRIMARY KEY (Product_Id, Work_Center_Id),
    FOREIGN KEY (Product_Id) REFERENCES PRODUCT_t(Product_Id),
    FOREIGN KEY (Work_Center_Id) REFERENCES WORK_CENTER_t(Work_Center_Id)
);

CREATE TABLE Order_line_t (
    Order_Id INT,
    Product_Id INT,
    Ordered_Quantity INT,
    PRIMARY KEY (Order_Id, Product_Id),
    FOREIGN KEY (Order_Id) REFERENCES Orders_t(Order_Id),
    FOREIGN KEY (Product_Id) REFERENCES PRODUCT_t(Product_Id)
);

CREATE TABLE RAW_MATERIAL_t (
    Material_Id VARCHAR(12) PRIMARY KEY,
    Material_Name VARCHAR(30),
    Standard_Cost DECIMAL(6,2),
    Unit_Of_Measure VARCHAR(10)
);

CREATE TABLE SALESPERSON_t (
    SalesPerson_Id INT PRIMARY KEY,
    SalesPerson_Name VARCHAR(25),
    SalesPerson_Phone VARCHAR(50),
    SalesPerson_Fax VARCHAR(50),
    Territory_Id INT,
    FOREIGN KEY (Territory_Id) REFERENCES TERRITORY_t(Territory_Id)
);

CREATE TABLE VENDOR_t (
    Vendor_Id INT PRIMARY KEY,
    Vendor_Name VARCHAR(25),
    Vendor_Address VARCHAR(30),
    Vendor_City VARCHAR(20),
    Vendor_Contact VARCHAR(50),
    Vendor_Fax VARCHAR(10),
    Vendor_Phone VARCHAR(10),
    Vendor_State VARCHAR(2),
    Vendor_Tax_Id VARCHAR(50),
    Vendor_Zipcode VARCHAR(50)
);

CREATE TABLE SUPPLIES_t (
    Vendor_Id INT,
    Material_Id VARCHAR(12),
    Supply_Unit_Price DECIMAL(6,2),
    PRIMARY KEY (Vendor_Id, Material_Id),
    FOREIGN KEY (Vendor_Id) REFERENCES VENDOR_t(Vendor_Id),
    FOREIGN KEY (Material_Id) REFERENCES RAW_MATERIAL_t(Material_Id)
);

CREATE TABLE Uses_t (
    Product_Id INT,
    Material_Id VARCHAR(12),
    Goes_into_Quantity INT,
    PRIMARY KEY (Product_Id, Material_Id),
    FOREIGN KEY (Product_Id) REFERENCES PRODUCT_t(Product_Id),
    FOREIGN KEY (Material_Id) REFERENCES RAW_MATERIAL_t(Material_Id)
);

CREATE TABLE Works_In_t (
    Employee_Id VARCHAR(10),
    Work_Center_Id VARCHAR(12),
    PRIMARY KEY (Employee_Id, Work_Center_Id),
    FOREIGN KEY (Employee_Id) REFERENCES EMPLOYEE_t(Employee_Id),
    FOREIGN KEY (Work_Center_Id) REFERENCES WORK_CENTER_t(Work_Center_Id)
);


/* =========================
   RBAC TABLES
========================= */

CREATE TABLE Users(
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(100) NOT NULL,
    IsActive BIT DEFAULT 1
);

CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL
);

CREATE TABLE Permissions (
    PermissionID INT IDENTITY(1,1) PRIMARY KEY,
    PermissionName VARCHAR(100)
);

CREATE TABLE UserRoles (
    UserID INT,
    RoleID INT,
    PRIMARY KEY(UserID, RoleID),
    FOREIGN KEY(UserID) REFERENCES Users(UserID),
    FOREIGN KEY(RoleID) REFERENCES Roles(RoleID)
);

CREATE TABLE RolePermissions (
    RoleID INT,
    PermissionID INT,
    PRIMARY KEY(RoleID, PermissionID),
    FOREIGN KEY(RoleID) REFERENCES Roles(RoleID),
    FOREIGN KEY(PermissionID) REFERENCES Permissions(PermissionID)
);


/* =========================
   INSERT RBAC DATA
========================= */

INSERT INTO Roles (RoleName) VALUES
('Admin'),
('Manager'),
('Salesperson'),
('Customer');

INSERT INTO Permissions (PermissionName) VALUES
('VIEW_PRODUCTS'),
('PLACE_ORDER'),
('MAKE_PAYMENT'),
('MANAGE_CATALOG'),
('REGISTER_CUSTOMER');

-- Role Permissions
-- Admin = ALL
INSERT INTO RolePermissions
SELECT 1, PermissionID FROM Permissions;

-- Manager
INSERT INTO RolePermissions VALUES
(2,1),(2,2),(2,3);

-- Salesperson
INSERT INTO RolePermissions VALUES
(3,1),(3,2);

-- Customer
INSERT INTO RolePermissions VALUES
(4,1),(4,2),(4,3);


/* =========================
   INSERT USERS
========================= */

INSERT INTO Users (Username, Password) VALUES
('admin1', 'admin123'),
('manager1', 'manager123'),
('sales1', 'sales123'),
('customer1', 'cust123');


/* =========================
   CORRECT ROLE ASSIGNMENT
   (NO HARDCODED IDs)
========================= */

INSERT INTO UserRoles (UserID, RoleID)
SELECT UserID, 1 FROM Users WHERE Username='admin1';

INSERT INTO UserRoles (UserID, RoleID)
SELECT UserID, 2 FROM Users WHERE Username='manager1';

INSERT INTO UserRoles (UserID, RoleID)
SELECT UserID, 3 FROM Users WHERE Username='sales1';

INSERT INTO UserRoles (UserID, RoleID)
SELECT UserID, 4 FROM Users WHERE Username='customer1';


/* =========================
   SAMPLE DATA (MINIMAL)
========================= */

INSERT INTO CUSTOMER_t VALUES
(1,'Contemporary Casuals','Address1','City1','FL','11111');

INSERT INTO PRODUCT_LINE_t VALUES (1,'Furniture');

INSERT INTO PRODUCT_t VALUES
(1,1,'Chair','Wood',150);


/* =========================
   VERIFY
========================= */

SELECT * FROM Users;
SELECT * FROM Roles;
SELECT * FROM Permissions;
SELECT * FROM UserRoles;
SELECT * FROM RolePermissions;



/* =========================
   LAB 7 ADDITIONS (SEGMENTATION SUPPORT)
   DO NOT MODIFY EXISTING STRUCTURE
========================= */

-- 1️⃣ ADD NEW PERMISSION
INSERT INTO Permissions (PermissionName)
VALUES ('SEGMENT_CUSTOMERS');


-- 2️⃣ ASSIGN PERMISSION TO ADMIN & MANAGER

-- Admin (RoleID = 1)
INSERT INTO RolePermissions (RoleID, PermissionID)
SELECT 1, PermissionID 
FROM Permissions 
WHERE PermissionName = 'SEGMENT_CUSTOMERS';

-- Manager (RoleID = 2)
INSERT INTO RolePermissions (RoleID, PermissionID)
SELECT 2, PermissionID 
FROM Permissions 
WHERE PermissionName = 'SEGMENT_CUSTOMERS';


/* =========================
   OPTIONAL: ADD MORE SAMPLE DATA (IMPORTANT FOR SEGMENTATION)
========================= */

-- Add more customers
INSERT INTO CUSTOMER_t VALUES
(2,'Value Furniture','Addr2','City2','TX','22222'),
(3,'Home Furnishings','Addr3','City3','NY','33333'),
(4,'Eastern Furniture','Addr4','City4','NJ','44444'),
(5,'Impressions','Addr5','City5','CA','55555');

-- Add more products
INSERT INTO PRODUCT_t VALUES
(2,1,'Table','Wood',300),
(3,1,'Sofa','Leather',800),
(4,1,'Desk','Metal',500);

-- Add orders
INSERT INTO Orders_t VALUES
(101,1,GETDATE()),
(102,1,GETDATE()),
(103,2,GETDATE()),
(104,3,GETDATE()),
(105,3,GETDATE()),
(106,3,GETDATE()),
(107,4,GETDATE());

-- Add order lines
INSERT INTO Order_line_t VALUES
(101,1,2),
(101,2,1),
(102,3,1),
(103,2,5),
(104,4,2),
(105,3,3),
(106,1,10),
(107,2,1);


/* =========================
   TEST SEGMENTATION QUERIES
========================= */

-- Frequent Customers
SELECT 
    C.Customer_Id,
    C.Customer_Name,
    COUNT(O.Order_Id) AS TotalOrders
FROM CUSTOMER_t C
JOIN Orders_t O ON C.Customer_Id = O.Customer_Id
GROUP BY C.Customer_Id, C.Customer_Name
HAVING COUNT(O.Order_Id) >= 2;

-- Premium Customers
SELECT TOP 5 C.Customer_Id, C.Customer_Name,
SUM(P.Standard_Price * OL.Ordered_Quantity) AS TotalSpent
FROM CUSTOMER_t C
JOIN Orders_t O ON C.Customer_Id = O.Customer_Id
JOIN Order_line_t OL ON O.Order_Id = OL.Order_Id
JOIN PRODUCT_t P ON OL.Product_Id = P.Product_Id
GROUP BY C.Customer_Id, C.Customer_Name
ORDER BY TotalSpent DESC;

-- Bulk Buyers
SELECT C.Customer_Id, C.Customer_Name,
SUM(OL.Ordered_Quantity) AS TotalQty
FROM CUSTOMER_t C
JOIN Orders_t O ON C.Customer_Id = O.Customer_Id
JOIN Order_line_t OL ON O.Order_Id = OL.Order_Id
GROUP BY C.Customer_Id, C.Customer_Name
HAVING SUM(OL.Ordered_Quantity) >= 5;


--high value
SELECT 
    C.Customer_Id,
    C.Customer_Name,
    SUM(P.Standard_Price * OL.Ordered_Quantity) AS TotalSpent
FROM CUSTOMER_t C
JOIN Orders_t O ON C.Customer_Id = O.Customer_Id
JOIN Order_line_t OL ON O.Order_Id = OL.Order_Id
JOIN PRODUCT_t P ON OL.Product_Id = P.Product_Id
GROUP BY C.Customer_Id, C.Customer_Name
HAVING SUM(P.Standard_Price * OL.Ordered_Quantity) BETWEEN 1000 AND 3000;


--low value
SELECT 
    C.Customer_Id,
    C.Customer_Name,
    SUM(P.Standard_Price * OL.Ordered_Quantity) AS TotalSpent
FROM CUSTOMER_t C
JOIN Orders_t O ON C.Customer_Id = O.Customer_Id
JOIN Order_line_t OL ON O.Order_Id = OL.Order_Id
JOIN PRODUCT_t P ON OL.Product_Id = P.Product_Id
GROUP BY C.Customer_Id, C.Customer_Name
HAVING SUM(P.Standard_Price * OL.Ordered_Quantity) < 1000;

--inactive
SELECT 
    C.Customer_Id,
    C.Customer_Name,
    COUNT(O.Order_Id) AS TotalOrders
FROM CUSTOMER_t C
LEFT JOIN Orders_t O ON C.Customer_Id = O.Customer_Id
GROUP BY C.Customer_Id, C.Customer_Name
HAVING COUNT(O.Order_Id) = 0;