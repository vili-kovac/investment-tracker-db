# DATABASE ARCHITECTURE MANUAL
## Investment Banking Tracker

**Version:** 2.0 (Final Architecture)

---

## Table of Contents
- [1. Introduction & Business Logic](#1-introduction--business-logic)
- [2. Entity-Relationship Concepts](#2-entity-relationship-concepts)
- [3. Relational Schema](#3-relational-schema)
- [4. Table Dictionary](#4-table-dictionary)
  - [4.1. Core Entities](#41-core-entities)
  - [4.2. Operational Tables](#42-operational-tables)
- [5. Analytical Queries & Reporting](#5-analytical-queries--reporting)
- [6. Virtual Dashboards (Views)](#6-virtual-dashboards-views)

---

## 1. Introduction & Business Logic
The "Investment Banking Tracker" is a robust relational database built to manage and analyze client investments across multiple financial institutions. 

The core business flow allows clients to hold investment accounts in different banks (e.g., JPMorgan, Barclays). Within these accounts, clients can maintain various portfolios to organize their assets (Stocks, Crypto, Bonds). The system records a strict, separated audit trail of both fiat cash flows (`DEPOSIT`, `WITHDRAW`) and asset trades (`BUY`, `SELL`), calculates real-time portfolio values, tracks historical asset prices, and logs dividend payouts.

## 2. Entity-Relationship Concepts
The architecture is defined by the following key relationships:
* **Client ↔ Investment Account (1:N):** A client can own multiple accounts, but each account belongs to exactly one client.
* **Bank ↔ Investment Account (1:N):** A bank hosts multiple accounts.
* **Investment Account ↔ Portfolio (1:N):** Accounts can be subdivided into multiple logical portfolios.
* **Asset Type ↔ Asset (1:N):** Assets are categorized by type (e.g., Stock, Crypto).
* **Portfolio ↔ Asset (N:M):** A many-to-many relationship resolved by the `portfolio_asset` junction table, representing the actual holdings.
* **Investment Account ↔ Account Transaction (1:N):** An account contains a history of fiat money movements.
* **Investment Account ↔ Asset Transaction (1:N):** An account contains a history of executed asset trades.
* **Asset ↔ Asset Price History (1:N):** Tracks the price movement of an asset over time.
* **Asset ↔ Dividend (1:N):** Logs passive income payouts linked to specific assets.

## 3. Relational Schema
* **`client`** (id, national_id_no, first_name, last_name, email, create_time, update_time)
* **`bank`** (id, name, swift_code, create_time, update_time)
* **`investment_account`** (id, client_id, bank_id, account_number, balance, currency_code, create_time, update_time)
* **`asset_type`** (id, type_name, create_time, update_time)
* **`asset`** (id, asset_type_id, symbol, name, current_price, create_time, update_time)
* **`portfolio`** (id, investment_account_id, name, create_time, update_time)
* **`portfolio_asset`** (id, portfolio_id, asset_id, quantity, average_price, create_time, update_time)
* **`account_transaction`** (id, investment_account_id, action, amount, create_time)
* **`asset_transaction`** (id, investment_account_id, asset_id, action, quantity, price_per_unit, create_time)
* **`asset_price_history`** (id, asset_id, price, price_date)
* **`dividend`** (id, asset_id, amount, payment_date)

*(Note for PDF Export: Insert updated EER Diagram Image here)*

---

## 4. Table Dictionary

### 4.1. Core & Historical Entities
* **`client`**: Stores personal details of the investors. `national_id_no` and `email` are unique identifiers.
* **`bank`**: Catalog of supported financial institutions with their respective `swift_code`.
* **`asset_type`**: Categorization table for assets (e.g., "Stock", "Crypto", "Bond").
* **`asset`**: The main catalog of tradable instruments, including their unique `symbol` (e.g., AAPL, BTC) and `current_price`.
* **`asset_price_history`**: Time-series table logging the price changes of assets for performance analysis.
* **`dividend`**: Ledger for recording passive income distributed by specific assets to shareholders.

### 4.2. Operational & Transactional Tables
* **`investment_account`**: The central link between a client and a bank. It tracks the unique `account_number` (IBAN) and the available fiat cash `balance`.
* **`portfolio`**: Logical groupings of assets created by the client under a specific investment account.
* **`portfolio_asset`**: The junction table resolving the N:M relationship between portfolios and assets. It tracks exactly how much of a specific asset is in a portfolio (`quantity`) and the `average_price` paid.
* **`account_transaction`**: Handles pure fiat liquidity operations (`DEPOSIT`, `WITHDRAW`).
* **`asset_transaction`**: The trading ledger. Records every `BUY` or `SELL` operation, including the `quantity` and `price_per_unit`.

---

## 5. Analytical Queries & Reporting

The database includes 10 complex queries designed to provide deep financial analytics, risk assessment, and market insights. 

### 5.1. Portfolio Market Valuation
**Purpose:** Calculates the current total market value of each portfolio by multiplying the exact quantity of held assets by their latest market price.
```sql
SELECT p.name AS Portfolio, SUM(pa.quantity * a.current_price) AS Total_Market_Value
FROM portfolio_asset pa
JOIN portfolio p ON pa.portfolio_id = p.id
JOIN asset a ON pa.asset_id = a.id
GROUP BY p.name;
```

### 5.2. Profitability Analysis (Unrealized P&L)
**Purpose:** Evaluates the performance of individual asset positions by comparing the client's average purchase price against the current market price to determine unrealized profit or loss.
```sql
SELECT c.last_name, a.symbol, pa.quantity, pa.average_price AS Bought_At, a.current_price AS Current_Price,
       (a.current_price - pa.average_price) * pa.quantity AS Unrealized_Profit_Loss
FROM portfolio_asset pa
JOIN asset a ON pa.asset_id = a.id
JOIN portfolio p ON pa.portfolio_id = p.id
JOIN investment_account ia ON p.investment_account_id = ia.id
JOIN client c ON ia.client_id = c.id;
```

### 5.3. "Whale" Alert (Large Transactions)
**Purpose:** Acts as a compliance and monitoring tool by flagging massive single transactions (over $50,000) executed by high-net-worth individuals.
```sql
SELECT c.last_name, at.action, a.symbol, at.quantity, at.price_per_unit, (at.quantity * at.price_per_unit) AS Total_Value
FROM asset_transaction at
JOIN investment_account ia ON at.investment_account_id = ia.id
JOIN client c ON ia.client_id = c.id
JOIN asset a ON at.asset_id = a.id
WHERE (at.quantity * at.price_per_unit) > 50000;
```

### 5.4. Asset Diversification Exposure
**Purpose:** Aggregates total capital allocation per asset class (e.g., Stocks vs. Crypto) for each client, aiding in portfolio diversification tracking.
```sql
SELECT c.last_name, atype.type_name, SUM(pa.quantity * a.current_price) AS Asset_Type_Value
FROM portfolio_asset pa
JOIN asset a ON pa.asset_id = a.id
JOIN asset_type atype ON a.asset_type_id = atype.id
JOIN portfolio p ON pa.portfolio_id = p.id
JOIN investment_account ia ON p.investment_account_id = ia.id
JOIN client c ON ia.client_id = c.id
GROUP BY c.last_name, atype.type_name;
```

### 5.5. Passive Income Tracking
**Purpose:** Summarizes the total amount of dividends paid out per specific asset and counts the number of historical payouts.
```sql
SELECT a.symbol, a.name, SUM(d.amount) AS Total_Dividend_Paid_Per_Share, COUNT(d.id) AS Payout_Count
FROM dividend d
JOIN asset a ON d.asset_id = a.id
GROUP BY a.symbol, a.name;
```

### 5.6. Asset Price Volatility (Spread)
**Purpose:** Analyzes the historical price data to determine the all-time high, all-time low, and the overall price spread for each listed asset.
```sql
SELECT a.symbol, MIN(aph.price) AS All_Time_Low, MAX(aph.price) AS All_Time_High, 
       (MAX(aph.price) - MIN(aph.price)) AS Price_Spread
FROM asset_price_history aph
JOIN asset a ON aph.asset_id = a.id
GROUP BY a.symbol;
```

### 5.7. Client Liquidity Risk Assessment
**Purpose:** Identifies potentially over-leveraged clients by finding individuals who hold large investment portfolios (>$20k) but have very low fiat cash reserves (<$10k).
```sql
SELECT c.last_name, ia.balance AS Cash_Balance, SUM(pa.quantity * a.current_price) AS Portfolio_Value
FROM client c
JOIN investment_account ia ON c.id = ia.client_id
JOIN portfolio p ON ia.id = p.investment_account_id
JOIN portfolio_asset pa ON p.id = pa.portfolio_id
JOIN asset a ON pa.asset_id = a.id
GROUP BY c.last_name, ia.balance
HAVING ia.balance < 10000 AND Portfolio_Value > 20000;
```

### 5.8. Cash Flow Volume by Bank
**Purpose:** Aggregates the total volume of incoming (DEPOSIT) and outgoing (WITHDRAW) fiat capital handled by each supported banking institution.
```sql
SELECT b.name AS Bank, act.action, SUM(act.amount) AS Total_Volume
FROM account_transaction act
JOIN investment_account ia ON act.investment_account_id = ia.id
JOIN bank b ON ia.bank_id = b.id
GROUP BY b.name, act.action;
```

### 5.9. Market Trading Activity
**Purpose:** Ranks assets by their popularity and liquidity, calculating the total number of trades executed and the absolute volume traded per symbol.
```sql
SELECT a.symbol, COUNT(at.id) AS Number_Of_Trades, SUM(at.quantity) AS Total_Volume_Traded
FROM asset_transaction at
JOIN asset a ON at.asset_id = a.id
GROUP BY a.symbol
ORDER BY Number_Of_Trades DESC;
```

### 5.10. Total Client Net Worth Calculation
**Purpose:** Combines available fiat cash balances with the real-time market value of all held portfolio assets to determine the absolute wealth of each client.
```sql
SELECT c.last_name, ia.balance AS Cash, IFNULL(SUM(pa.quantity * a.current_price), 0) AS Investments,
       (ia.balance + IFNULL(SUM(pa.quantity * a.current_price), 0)) AS Total_Net_Worth
FROM client c
JOIN investment_account ia ON c.id = ia.client_id
LEFT JOIN portfolio p ON ia.id = p.investment_account_id
LEFT JOIN portfolio_asset pa ON p.id = pa.portfolio_id
LEFT JOIN asset a ON pa.asset_id = a.id
GROUP BY c.last_name, ia.balance
ORDER BY Total_Net_Worth DESC;
```

---

## 6. Virtual Dashboards (Views)

To optimize application performance, ensure data security, and simplify frontend data fetching, the architecture implements 10 SQL Views. These act as pre-compiled, read-only virtual tables that offload complex logic from the application backend directly to the database engine.

### 6.1. Client Account Overview (`v_client_full_details`)
**Purpose:** Consolidates client personal data with their active bank accounts and current fiat balances into a single, easily readable profile.
```sql
CREATE OR REPLACE VIEW v_client_full_details AS
SELECT c.id, c.first_name, c.last_name, c.email, b.name AS bank_name, ia.account_number, ia.balance
FROM client c
JOIN investment_account ia ON c.id = ia.client_id
JOIN bank b ON ia.bank_id = b.id;
```

### 6.2. Live Portfolio Valuation (`v_portfolio_current_state`)
**Purpose:** Provides a real-time snapshot of all portfolios, multiplying the exact quantity of held assets by their latest market prices to output the total current value.
```sql
CREATE OR REPLACE VIEW v_portfolio_current_state AS
SELECT p.name AS portfolio_name, a.symbol, pa.quantity, a.current_price, (pa.quantity * a.current_price) AS total_value
FROM portfolio_asset pa
JOIN portfolio p ON pa.portfolio_id = p.id
JOIN asset a ON pa.asset_id = a.id;
```

### 6.3. Asset Trade Audit Trail (`v_trade_log`)
**Purpose:** Generates a clean, chronological audit log of all market trading activities (BUY/SELL), linking the client directly to the asset and execution price.
```sql
CREATE OR REPLACE VIEW v_trade_log AS
SELECT at.create_time, c.last_name, at.action, a.symbol, at.quantity, at.price_per_unit
FROM asset_transaction at
JOIN investment_account ia ON at.investment_account_id = ia.id
JOIN client c ON ia.client_id = c.id
JOIN asset a ON at.asset_id = a.id;
```

### 6.4. Fiat Cash Flow Ledger (`v_cash_flow_log`)
**Purpose:** A unified ledger tracking all fiat liquidity movements (DEPOSIT/WITHDRAW) across different banking institutions.
```sql
CREATE OR REPLACE VIEW v_cash_flow_log AS
SELECT act.create_time, c.last_name, b.name AS bank, act.action, act.amount
FROM account_transaction act
JOIN investment_account ia ON act.investment_account_id = ia.id
JOIN client c ON ia.client_id = c.id
JOIN bank b ON ia.bank_id = b.id;
```

### 6.5. Cryptocurrency Market Watch (`v_crypto_assets`)
**Purpose:** A filtered catalog specifically isolating cryptocurrency assets, making it easier for specific API endpoints to fetch crypto-only market data.
```sql
CREATE OR REPLACE VIEW v_crypto_assets AS
SELECT a.symbol, a.name, a.current_price
FROM asset a
JOIN asset_type atype ON a.asset_type_id = atype.id
WHERE atype.type_name = 'Crypto';
```

### 6.6. Passive Income Schedule (`v_dividend_calendar`)
**Purpose:** A chronological schedule of historical dividend distributions, structured to be easily displayed in a UI calendar component.
```sql
CREATE OR REPLACE VIEW v_dividend_calendar AS
SELECT d.payment_date, a.symbol, a.name, d.amount
FROM dividend d
JOIN asset a ON d.asset_id = a.id
ORDER BY d.payment_date DESC;
```

### 6.7. Real-Time Profit & Loss (`v_position_pnl`)
**Purpose:** The most critical view for the dashboard. It calculates the percentage return on investment (ROI) for active positions by comparing the average buy price to the live market price.
```sql
CREATE OR REPLACE VIEW v_position_pnl AS
SELECT p.name AS portfolio, a.symbol, pa.average_price, a.current_price, 
       ROUND(((a.current_price - pa.average_price) / pa.average_price) * 100, 2) AS profit_percentage
FROM portfolio_asset pa
JOIN portfolio p ON pa.portfolio_id = p.id
JOIN asset a ON pa.asset_id = a.id;
```

### 6.8. Institutional Risk Analysis (`v_bank_cash_reserves`)
**Purpose:** Aggregates the total uninvested fiat liquidity currently held across all clients within each banking institution to monitor exposure.
```sql
CREATE OR REPLACE VIEW v_bank_cash_reserves AS
SELECT b.name AS bank_name, SUM(ia.balance) AS total_client_funds
FROM bank b
JOIN investment_account ia ON b.id = ia.bank_id
GROUP BY b.name;
```

### 6.9. Historical Market Ticker (`v_market_ticker`)
**Purpose:** Displays a flattened timeline of asset price history, optimized for generating historical price charts on the frontend.
```sql
CREATE OR REPLACE VIEW v_market_ticker AS
SELECT a.symbol, aph.price AS historical_price, aph.price_date
FROM asset_price_history aph
JOIN asset a ON aph.asset_id = a.id
ORDER BY aph.price_date DESC;
```

### 6.10. Traditional Market Exposure (`v_stock_exposure`)
**Purpose:** Calculates the absolute volume of traditional stock shares held by each client, isolating conventional market exposure from crypto or bond assets.
```sql
CREATE OR REPLACE VIEW v_stock_exposure AS
SELECT c.last_name, SUM(pa.quantity) AS total_shares_owned
FROM portfolio_asset pa
JOIN portfolio p ON pa.portfolio_id = p.id
JOIN investment_account ia ON p.investment_account_id = ia.id
JOIN client c ON ia.client_id = c.id
JOIN asset a ON pa.asset_id = a.id
JOIN asset_type atype ON a.asset_type_id = atype.id
WHERE atype.type_name = 'Stock'
GROUP BY c.last_name;
```