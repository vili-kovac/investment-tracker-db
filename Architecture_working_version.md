# DATABASE ARCHITECTURE MANUAL
## Investment Banking Tracker

**Version:** 1.0 (Working Version)

---

## Table of Contents
- [DATABASE ARCHITECTURE MANUAL](#database-architecture-manual)
  - [Investment Banking Tracker](#investment-banking-tracker)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction \& Business Logic](#1-introduction--business-logic)
  - [2. Entity-Relationship Concepts](#2-entity-relationship-concepts)
  - [3. Relational Schema](#3-relational-schema)
  - [4. Table Dictionary](#4-table-dictionary)
    - [4.1. Core Entities](#41-core-entities)
    - [4.2. Operational Tables](#42-operational-tables)
  - [5. Analytical Queries \& Reporting](#5-analytical-queries--reporting)
    - [5.1. Client Portfolio Holdings](#51-client-portfolio-holdings)

---

## 1. Introduction & Business Logic
The "Investment Banking Tracker" is a relational database built to manage and analyze client investments across multiple financial institutions. 

The core business flow allows clients to hold investment accounts in different banks (e.g., Revolut, JP Morgan). Within these accounts, clients can maintain various portfolios to organize their assets (Stocks, Crypto). The system records a full audit trail of all transactions (BUY, DEPOSIT) and calculates the exact quantity of assets held in each portfolio.

## 2. Entity-Relationship Concepts
The architecture is defined by the following key relationships:
* **Client ↔ Investment Account (1:N):** A client can own multiple accounts, but each account belongs to exactly one client.
* **Bank ↔ Investment Account (1:N):** A bank hosts multiple accounts.
* **Investment Account ↔ Portfolio (1:N):** Accounts can be subdivided into multiple logical portfolios.
* **Asset Types ↔ Asset (1:N):** Assets are categorized by type (e.g., Stock, Crypto).
* **Portfolio ↔ Asset (N:M):** A many-to-many relationship resolved by the `portfolio_asset` junction table, representing the actual holdings (quantity and average price).
* **Investment Account ↔ Transaction (1:N):** An account contains a history of executed transactions.

## 3. Relational Schema
* **client** (id, national_id_no, name, surname, email, create_time, update_time)
* **bank** (id, name, swift_code, create_time, update_time)
* **investment_account** (id, client_id, bank_id, account_number, balance, currency_code, create_time, update_time)
* **asset_types** (id, type_name, create_time, update_time)
* **asset** (id, asset_types_id, symbol, name, current_price, create_time, update_time)
* **portfolio** (id, investment_account_id, name, create_time, update_time)
* **portfolio_asset** (id, portfolio_id, asset_id, quantity, average_price, create_time, update_time)
* **transaction** (id, investment_account_id, asset_id, type, quantity, price_per_unit, create_time)

*(Note for PDF Export: Insert EER Diagram Image here)*

---

## 4. Table Dictionary

### 4.1. Core Entities
* **`client`**: Stores personal details of the investors. `national_id_no` and `email` are unique identifiers.
* **`bank`**: Catalog of supported financial institutions with their respective `swift_code`.
* **`asset_types`**: Categorization table for assets (e.g., "Stock", "Crypto").
* **`asset`**: The main catalog of tradable instruments, including their unique `symbol` (e.g., TSLA, BTC) and `current_price`.

### 4.2. Operational Tables
* **`investment_account`**: The central link between a client and a bank. It tracks the unique `account_number` (IBAN) and the available cash `balance`.
* **`portfolio`**: Logical groupings of assets created by the client under a specific investment account.
* **`portfolio_asset`**: The junction table resolving the N:M relationship between portfolios and assets. It tracks exactly how much of a specific asset is in a portfolio (`quantity`) and the `average_price` paid.
* **`transaction`**: The immutable ledger. Records every `BUY`, `SELL`, `DEPOSIT`, or `WITHDRAW` operation, including the `quantity`, `price_per_unit`, and exact timestamp.

---

## 5. Analytical Queries & Reporting

The following SQL queries validate the database structure and provide essential business intelligence reports.

### 5.1. Client Portfolio Holdings
**Purpose:** Extracts a comprehensive list of all assets owned by clients, detailing the specific ticker and total quantity held.

```sql
SELECT 
    c.name AS 'First Name', 
    c.surname AS 'Last Name', 
    asset.symbol AS 'Ticker', 
    portfolio_asset.quantity AS 'Quantity Held'
FROM client c
JOIN investment_account ON c.id = investment_account.client_id
JOIN portfolio ON investment_account.id = portfolio.investment_account_id
JOIN portfolio_asset ON portfolio.id = portfolio_asset.portfolio_id
JOIN asset ON portfolio_asset.asset_id = asset.id;