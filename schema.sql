-- Credit Card Processing System - MySQL 8.0 schema (matches Section 4.2 of the report)
CREATE DATABASE IF NOT EXISTS credit_card_processing;
USE credit_card_processing;

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    phone       VARCHAR(15),
    address     VARCHAR(255)
);

CREATE TABLE Bank (
    bank_id   INT PRIMARY KEY AUTO_INCREMENT,
    bank_name VARCHAR(100) NOT NULL,
    branch    VARCHAR(100),
    ifsc_code VARCHAR(11)
);

CREATE TABLE Merchant (
    merchant_id   INT PRIMARY KEY AUTO_INCREMENT,
    merchant_name VARCHAR(100) NOT NULL,
    category      VARCHAR(50)
);

-- Each CreditCard is owned by one Customer and issued by one Bank.
-- NOTE: cvv is stored only because the report's design lists it. Real systems
-- must NEVER store the CVV (PCI DSS) and should encrypt/tokenize card_number.
CREATE TABLE CreditCard (
    card_id      INT PRIMARY KEY AUTO_INCREMENT,
    customer_id  INT NOT NULL,
    bank_id      INT NOT NULL,
    card_number  VARCHAR(19) NOT NULL,
    expiry_date  VARCHAR(5)  NOT NULL,          -- MM/YY
    cvv          VARCHAR(4),
    credit_limit DECIMAL(12,2) NOT NULL,
    status       VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'
                 CHECK (status IN ('ACTIVE','BLOCKED','EXPIRED')),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (bank_id)     REFERENCES Bank(bank_id)
);

CREATE TABLE Transaction (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    card_id        INT NOT NULL,
    merchant_id    INT NOT NULL,
    amount         DECIMAL(12,2) NOT NULL,
    status         VARCHAR(10) NOT NULL
                   CHECK (status IN ('SUCCESS','FAILED','DECLINED','REFUNDED')),
    flagged        BOOLEAN NOT NULL DEFAULT FALSE,   -- suspicious-activity flag
    timestamp      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (card_id)     REFERENCES CreditCard(card_id),
    FOREIGN KEY (merchant_id) REFERENCES Merchant(merchant_id)
);

CREATE TABLE Payment (
    payment_id     INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    payment_mode   VARCHAR(20) NOT NULL,
    auth_code      VARCHAR(20),
    FOREIGN KEY (transaction_id) REFERENCES Transaction(transaction_id)
);

CREATE TABLE Bill (
    bill_id       INT PRIMARY KEY AUTO_INCREMENT,
    customer_id   INT NOT NULL,
    billing_cycle VARCHAR(7) NOT NULL,           -- e.g. 2026-10
    total_due     DECIMAL(12,2) NOT NULL,
    due_date      DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- ---------- Sample data ----------
INSERT INTO Customer VALUES (1, 'Renuka Devi M', 'renuka@example.com', '9123456780', 'Chennai');
INSERT INTO Bank     VALUES (1, 'Demo Bank', 'Chennai Main', 'DEMO0001234');
INSERT INTO Merchant VALUES (1, 'Aurora Coffee Co.', 'Food & Beverage');
INSERT INTO CreditCard VALUES (1, 1, 1, '4111111111111111', '12/28', '123', 1000.00, 'ACTIVE');
INSERT INTO Transaction (transaction_id, card_id, merchant_id, amount, status, flagged)
    VALUES (1001, 1, 1, 320.00, 'SUCCESS', FALSE),
           (1002, 1, 1, 450.00, 'SUCCESS', TRUE),
           (1003, 1, 1, 500.00, 'DECLINED', TRUE);
INSERT INTO Payment VALUES (1, 1001, 'CREDIT_CARD', 'AUTH425814'),
                           (2, 1002, 'CREDIT_CARD', 'AUTH108267');
INSERT INTO Bill VALUES (1, 1, '2026-10', 770.00, '2026-10-23');

-- ---------- Useful queries (Report module) ----------
-- Transaction history with customer and merchant:
-- SELECT t.transaction_id, c.name, m.merchant_name, t.amount, t.status, t.flagged, t.timestamp
-- FROM Transaction t
-- JOIN CreditCard cc ON t.card_id = cc.card_id
-- JOIN Customer c    ON cc.customer_id = c.customer_id
-- JOIN Merchant m    ON t.merchant_id = m.merchant_id
-- ORDER BY t.timestamp DESC;
--
-- Summary report:
-- SELECT status, COUNT(*) AS total, SUM(amount) AS amount FROM Transaction GROUP BY status;
