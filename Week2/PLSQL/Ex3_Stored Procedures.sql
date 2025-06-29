-- Drop existing objects if needed (optional safety)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Transactions CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Loans CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Accounts CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Customers CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Employees CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP SEQUENCE Transactions_seq';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- 1. Create Tables
CREATE TABLE Customers (
    CustomerID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    DOB DATE,
    Balance NUMBER,
    LastModified DATE
);

CREATE TABLE Accounts (
    AccountID NUMBER PRIMARY KEY,
    CustomerID NUMBER,
    AccountType VARCHAR2(20),
    Balance NUMBER,
    LastModified DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Transactions (
    TransactionID NUMBER PRIMARY KEY,
    AccountID NUMBER,
    TransactionDate DATE,
    Amount NUMBER,
    TransactionType VARCHAR2(10),
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

CREATE TABLE Loans (
    LoanID NUMBER PRIMARY KEY,
    CustomerID NUMBER,
    LoanAmount NUMBER,
    InterestRate NUMBER,
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Employees (
    EmployeeID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    Position VARCHAR2(50),
    Salary NUMBER,
    Department VARCHAR2(50),
    HireDate DATE
);

-- 2. Create Sequence for Transactions
CREATE SEQUENCE Transactions_seq START WITH 1001 INCREMENT BY 1;

-- 3. Insert Sample Data
INSERT INTO Customers VALUES (1, 'John Doe', TO_DATE('1985-05-15', 'YYYY-MM-DD'), 1000, SYSDATE);
INSERT INTO Customers VALUES (2, 'Jane Smith', TO_DATE('1990-07-20', 'YYYY-MM-DD'), 1500, SYSDATE);

INSERT INTO Accounts VALUES (1, 1, 'Savings', 1000, SYSDATE);
INSERT INTO Accounts VALUES (2, 2, 'Checking', 1500, SYSDATE);

INSERT INTO Transactions VALUES (1, 1, SYSDATE, 200, 'Deposit');
INSERT INTO Transactions VALUES (2, 2, SYSDATE, 300, 'Withdrawal');

INSERT INTO Loans VALUES (1, 1, 5000, 5, SYSDATE, ADD_MONTHS(SYSDATE, 60));

INSERT INTO Employees VALUES (1, 'Alice Johnson', 'Manager', 70000, 'HR', TO_DATE('2015-06-15', 'YYYY-MM-DD'));
INSERT INTO Employees VALUES (2, 'Bob Brown', 'Developer', 60000, 'IT', TO_DATE('2017-03-20', 'YYYY-MM-DD'));

COMMIT;

-- 4. Stored Procedure: ProcessMonthlyInterest
CREATE OR REPLACE PROCEDURE ProcessMonthlyInterest AS
BEGIN
    UPDATE Accounts
    SET Balance = Balance * 1.01,
        LastModified = SYSDATE
    WHERE AccountType = 'Savings';

    COMMIT;
END;
/

-- 5. Stored Procedure: UpdateEmployeeBonus
CREATE OR REPLACE PROCEDURE UpdateEmployeeBonus (
    dept_name IN VARCHAR2,
    bonus_percent IN NUMBER
) AS
BEGIN
    UPDATE Employees
    SET Salary = Salary + (Salary * bonus_percent / 100)
    WHERE Department = dept_name;

    COMMIT;
END;
/

-- 6. Stored Procedure: TransferFunds
CREATE OR REPLACE PROCEDURE TransferFunds (
    from_account IN NUMBER,
    to_account IN NUMBER,
    amount IN NUMBER
) AS
    insufficient_balance EXCEPTION;
    from_balance NUMBER;
BEGIN
    SELECT Balance INTO from_balance
    FROM Accounts
    WHERE AccountID = from_account
    FOR UPDATE;

    IF from_balance < amount THEN
        RAISE insufficient_balance;
    END IF;

    -- Deduct from source
    UPDATE Accounts
    SET Balance = Balance - amount,
        LastModified = SYSDATE
    WHERE AccountID = from_account;

    -- Add to destination
    UPDATE Accounts
    SET Balance = Balance + amount,
        LastModified = SYSDATE
    WHERE AccountID = to_account;

    -- Log Transactions
    INSERT INTO Transactions VALUES (Transactions_seq.NEXTVAL, from_account, SYSDATE, amount, 'Debit');
    INSERT INTO Transactions VALUES (Transactions_seq.NEXTVAL, to_account, SYSDATE, amount, 'Credit');

    COMMIT;
EXCEPTION
    WHEN insufficient_balance THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transfer failed: Insufficient funds.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transfer failed: ' || SQLERRM);
END;
/

-- 7. (Optional) Test Calls

-- Run monthly interest calculation
EXEC ProcessMonthlyInterest;

-- Give 10% bonus to IT department
EXEC UpdateEmployeeBonus('HR', 15);

-- Transfer 200 from Account 1 to Account 2
EXEC TransferFunds(1, 2, 200);