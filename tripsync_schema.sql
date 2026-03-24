-- TripSync Database Schema (SQL Server)

CREATE DATABASE TripSyncDB;
GO

USE TripSyncDB;
GO

-- 1. Users Table
CREATE TABLE Users (
    UserId NVARCHAR(50) PRIMARY KEY, -- Using NVARCHAR/UUID for compatibility with app logic
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- 2. Trips Table
CREATE TABLE Trips (
    TripId NVARCHAR(50) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Destination NVARCHAR(100) NOT NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL,
    Budget DECIMAL(18, 2) NOT NULL,
    Currency NVARCHAR(10) DEFAULT 'VND',
    CreatorId NVARCHAR(50),
    FOREIGN KEY (CreatorId) REFERENCES Users(UserId) ON DELETE SET NULL
);
GO

-- 3. TripMembers (Link Table for many-to-many relationship)
CREATE TABLE TripMembers (
    TripId NVARCHAR(50),
    UserId NVARCHAR(50),
    PRIMARY KEY (TripId, UserId),
    FOREIGN KEY (TripId) REFERENCES Trips(TripId) ON DELETE CASCADE,
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);
GO

-- 4. ItineraryItems Table
CREATE TABLE ItineraryItems (
    ItemId NVARCHAR(50) PRIMARY KEY,
    TripId NVARCHAR(50),
    Title NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    ItemTime DATETIME NOT NULL,
    Location NVARCHAR(200),
    Cost DECIMAL(18, 2) DEFAULT 0,
    FOREIGN KEY (TripId) REFERENCES Trips(TripId) ON DELETE CASCADE
);
GO

-- 5. Expenses Table
CREATE TABLE Expenses (
    ExpenseId NVARCHAR(50) PRIMARY KEY,
    TripId NVARCHAR(50),
    Title NVARCHAR(100) NOT NULL,
    Amount DECIMAL(18, 2) NOT NULL,
    Category NVARCHAR(50),
    ExpenseDate DATETIME NOT NULL,
    PaidByUserId NVARCHAR(50),
    FOREIGN KEY (TripId) REFERENCES Trips(TripId) ON DELETE CASCADE,
    FOREIGN KEY (PaidByUserId) REFERENCES Users(UserId) ON DELETE SET NULL
);
GO

-- 6. ExpenseSplits Table
CREATE TABLE ExpenseSplits (
    ExpenseId NVARCHAR(50),
    UserId NVARCHAR(50),
    PRIMARY KEY (ExpenseId, UserId),
    FOREIGN KEY (ExpenseId) REFERENCES Expenses(ExpenseId) ON DELETE CASCADE,
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);
GO

-- 7. Documents Table
CREATE TABLE Documents (
    DocumentId NVARCHAR(50) PRIMARY KEY,
    TripId NVARCHAR(50),
    FileName NVARCHAR(255) NOT NULL,
    FileType NVARCHAR(50),
    Url NVARCHAR(500) NOT NULL,
    UploadDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (TripId) REFERENCES Trips(TripId) ON DELETE CASCADE
);
GO

-- 8. ChecklistItems Table
CREATE TABLE ChecklistItems (
    ChecklistItemId NVARCHAR(50) PRIMARY KEY,
    TripId NVARCHAR(50),
    Task NVARCHAR(255) NOT NULL,
    IsDone BIT DEFAULT 0,
    FOREIGN KEY (TripId) REFERENCES Trips(TripId) ON DELETE CASCADE
);
GO
