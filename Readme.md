# 📈 Investment Banking Tracker

A relational database schema designed for tracking multi-asset investment portfolios. This system supports stocks, cryptocurrencies, and bonds while maintaining a clean transaction history and bank account integration.

## 🧠 Key Design Decisions

### 1. Single Reporting Currency Logic
To avoid the high complexity of real-time exchange rate (FX) calculations and historical price discrepancies, the system utilizes a **Single Reporting Currency (e.g., EUR)**.
- **Implementation:** All prices in the `asset` table and amounts in the `transaction` table are stored pre-converted into the base currency.
- **Benefit:** This ensures clean arithmetic for total portfolio valuation without requiring external FX rate services.

### 2. Flexible Transaction Architecture
The `transaction` table is designed to handle both asset-related trades and simple cash movements.
- **Nullable Asset ID:** The `asset_id` field is explicitly set to `NULL`. 
- **Logic:** For `BUY` and `SELL` operations, the asset is recorded. For `DEPOSIT` and `WITHDRAW` operations, the field remains empty, signifying a cash-only movement.

## 🚀 Features
- **Client & Bank Management:** Links multiple bank accounts (IBAN/SWIFT) to a single client profile.
- **Multi-Asset Support:** Categorizes assets into "Stock", "Crypto", or "Bond".
- **Portfolio Tracking:** Organizes assets into specific portfolios for better risk management.
- **Precision Accounting:** Uses `DECIMAL(18,8)` to ensure accuracy for high-fractional assets like Bitcoin.

## 🛠️ Tech Stack
- **Database:** MySQL 9.0+
- **Modeling:** MySQL Workbench (EER Diagram)
- **Standard:** UTF8mb4 for full character support.

## 📂 Project Structure
- `investment_tracker_v1.mwb`: The source visual model.
- `setup_database.sql`: SQL script to generate the schema and tables.
- `EER_Diagram.png`: High-resolution export of the database architecture.

## ⚙️ How to Use
1. Clone the repository.
2. Open MySQL Workbench.
3. Execute `setup_database.sql` to build the database on your local instance.
4. (Optional) Refer to the schema for foreign key constraints before importing data.

---
*Created as a project for designing robust financial relational databases.*