
# 🚧 Project Status: Active Development
This repository is part of my current B.Sc. coursework.

# 📈 Investment Banking Tracker

A robust relational database schema designed for tracking multi-asset investment portfolios. This system supports stocks, cryptocurrencies, and bonds, maintaining a clean separation of asset trades and cash flows, along with built-in analytical views and historical tracking.

## 🧠 Key Design Decisions

### 1. Separated Transaction Architecture
To maintain high data integrity and avoid `NULL` values, transaction logic is split into two distinct tables:
- **`account_transaction`**: Handles fiat money movements (`DEPOSIT`, `WITHDRAW`) linked directly to the investment account.
- **`asset_transaction`**: Handles trading activities (`BUY`, `SELL`), strictly requiring an `asset_id`, quantity, and execution price.
- **Benefit**: Ensures clean, normalized data without the need for conditional logic when calculating cash balances vs. portfolio exposure.

### 2. View-Driven Analytics
Instead of writing complex, repetitive queries for application dashboards, the database utilizes **SQL Views**.
- **Implementation**: 10 distinct views (e.g., `v_position_pnl`, `v_portfolio_current_state`) act as "virtual tables", pre-calculating real-time profit/loss, dividend calendars, and bank cash reserves.
- **Benefit**: Offloads heavy calculations to the database layer, making backend API integration significantly faster and easier.

### 3. Historical Tracking & Passive Income
The schema goes beyond current state tracking by including `asset_price_history` and `dividend` tables, allowing for time-series analysis and yield calculations.

## 🚀 Features
- **Client & Bank Management:** Links multiple bank accounts (IBAN/SWIFT) to a single client profile.
- **Multi-Asset Support:** Categorizes assets into "Stock", "Crypto", or "Bond".
- **Precision Accounting:** Uses `DECIMAL(18,8)` to ensure accuracy for high-fractional assets like Bitcoin, and `DECIMAL(18,2)` for standard fiat balances.
- **Built-in Analytics:** Includes 10 complex problem-solving queries (e.g., Whale Detection, Asset Volatility, Client Liquidity Risk).
- **Ready-to-Use Dashboard Data:** 10 pre-compiled Views for immediate UI/UX data fetching.

## 🛠️ Tech Stack
- **Database:** MySQL 8.0+ / 9.0+
- **Modeling:** MySQL Workbench (EER Diagram)
- **Standard:** UTF8mb4 for full character support.
- **SQL Modes:** Strict transactions, only full group by.

## 📂 Project Structure
- `investment_tracker_v1.mwb`: The source visual EER model.
- `setup_database.sql`: The complete SQL script. It includes:
  1. **DDL:** Schema and table creation with foreign keys.
  2. **DML:** Comprehensive dummy data for testing.
  3. **Queries:** 10 complex analytical queries.
  4. **Views:** 10 dashboard-ready virtual tables.
- `EER_Diagram.png`: High-resolution export of the database architecture.

## ⚙️ How to Use
1. Clone the repository.
2. Open MySQL Workbench or your preferred SQL client.
3. Execute the `setup_database.sql` script to build the database, insert dummy data, and generate the views.
4. Explore the `Views` section in your database GUI to see real-time calculated metrics like `v_position_pnl`.

---
*Created as a project for designing robust financial relational databases and advanced SQL data analysis.*
