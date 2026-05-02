
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema investment_tracker
-- -----------------------------------------------------
-- Investment Banking Tracker 

-- -----------------------------------------------------
-- Schema investment_tracker
--
-- Investment Banking Tracker 
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `investment_tracker` DEFAULT CHARACTER SET utf8 ;
USE `investment_tracker` ;

-- -----------------------------------------------------
-- Table `investment_tracker`.`client`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`client` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `national_id_no` VARCHAR(11) NOT NULL,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `create_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE INDEX `national_id_no_UNIQUE` (`national_id_no` ASC) VISIBLE,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `investment_tracker`.`bank`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`bank` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `swift_code` VARCHAR(11) NOT NULL,
  `create_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `investment_tracker`.`investment_account`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`investment_account` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `client_id` INT UNSIGNED NOT NULL,
  `bank_id` INT UNSIGNED NOT NULL,
  `account_number` VARCHAR(30) NOT NULL COMMENT 'IBAN',
  `balance` DECIMAL(18,2) NOT NULL DEFAULT 0,
  `currency_code` CHAR(3) NOT NULL DEFAULT 'EUR',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `account_number_UNIQUE` (`account_number` ASC) VISIBLE,
  INDEX `fk_investment_account_client1_idx` (`client_id` ASC) VISIBLE,
  INDEX `fk_investment_account_bank1_idx` (`bank_id` ASC) VISIBLE,
  CONSTRAINT `fk_investment_account_client1`
    FOREIGN KEY (`client_id`)
    REFERENCES `investment_tracker`.`client` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_investment_account_bank1`
    FOREIGN KEY (`bank_id`)
    REFERENCES `investment_tracker`.`bank` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `investment_tracker`.`asset_type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`asset_type` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_name` VARCHAR(20) NOT NULL COMMENT '“Stock”, “Crypto”, “Bond”',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `investment_tracker`.`asset`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`asset` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `symbol` VARCHAR(10) NOT NULL COMMENT '“Stock”, “Crypto”, “Bond”',
  `name` VARCHAR(100) NOT NULL,
  `current_price` DECIMAL(18,8) NOT NULL DEFAULT 0,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `asset_type_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `symbol_UNIQUE` (`symbol` ASC) VISIBLE,
  INDEX `fk_asset_asset_type1_idx` (`asset_type_id` ASC) VISIBLE,
  CONSTRAINT `fk_asset_asset_type1`
    FOREIGN KEY (`asset_type_id`)
    REFERENCES `investment_tracker`.`asset_type` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `investment_tracker`.`portfolio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`portfolio` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `investment_account_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_portfolio_investment_account1_idx` (`investment_account_id` ASC) VISIBLE,
  CONSTRAINT `fk_portfolio_investment_account10`
    FOREIGN KEY (`investment_account_id`)
    REFERENCES `investment_tracker`.`investment_account` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `investment_tracker`.`portfolio_asset`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`portfolio_asset` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `portfolio_id` INT UNSIGNED NOT NULL,
  `asset_id` INT UNSIGNED NOT NULL,
  `quantity` DECIMAL(18,8) NOT NULL,
  `average_price` DECIMAL(18,8) NOT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_portfolio_has_asset_asset1_idx` (`asset_id` ASC) VISIBLE,
  INDEX `fk_portfolio_has_asset_portfolio1_idx` (`portfolio_id` ASC) VISIBLE,
  CONSTRAINT `fk_portfolio_has_asset_portfolio1`
    FOREIGN KEY (`portfolio_id`)
    REFERENCES `investment_tracker`.`portfolio` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_portfolio_has_asset_asset1`
    FOREIGN KEY (`asset_id`)
    REFERENCES `investment_tracker`.`asset` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `investment_tracker`.`asset_transaction`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`asset_transaction` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `investment_account_id` INT UNSIGNED NOT NULL,
  `asset_id` INT UNSIGNED NOT NULL,
  `action` ENUM('BUY', 'SELL') NOT NULL,
  `quantity` DECIMAL(18,8) NOT NULL DEFAULT 0,
  `price_per_unit` DECIMAL(18,8) NOT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_transaction_investment_account1_idx` (`investment_account_id` ASC) VISIBLE,
  INDEX `fk_transaction_asset1_idx` (`asset_id` ASC) VISIBLE,
  CONSTRAINT `fk_transaction_investment_account1`
    FOREIGN KEY (`investment_account_id`)
    REFERENCES `investment_tracker`.`investment_account` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_transaction_asset1`
    FOREIGN KEY (`asset_id`)
    REFERENCES `investment_tracker`.`asset` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `investment_tracker`.`account_transaction`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`account_transaction` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `investment_account_id` INT UNSIGNED NOT NULL,
  `action` ENUM('DEPOSIT', 'WITHDRAW') NOT NULL,
  `amount` DECIMAL(18,8) NOT NULL,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_account_transaction_investment_account1_idx` (`investment_account_id` ASC) VISIBLE,
  CONSTRAINT `fk_account_transaction_investment_account1`
    FOREIGN KEY (`investment_account_id`)
    REFERENCES `investment_tracker`.`investment_account` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `investment_tracker`.`asset_price_history`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`asset_price_history` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `asset_id` INT UNSIGNED NOT NULL,
  `price` DECIMAL(18,8) NOT NULL,
  `price_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_asset_price_history_asset1_idx` (`asset_id` ASC) VISIBLE,
  CONSTRAINT `fk_asset_price_history_asset1`
    FOREIGN KEY (`asset_id`)
    REFERENCES `investment_tracker`.`asset` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `investment_tracker`.`dividend`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`dividend` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `asset_id` INT UNSIGNED NOT NULL,
  `amount` DECIMAL(18,8) NOT NULL,
  `payment_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_asset_price_history_asset1_idx` (`asset_id` ASC) VISIBLE,
  CONSTRAINT `fk_asset_price_history_asset10`
    FOREIGN KEY (`asset_id`)
    REFERENCES `investment_tracker`.`asset` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;



-- ==========================================
-- 1. UNOS PODATAKA (DUMMY DATA)
-- ==========================================

-- Tipovi imovine
INSERT INTO `asset_type` (`type_name`) VALUES ('Stock'), ('Crypto'), ('Bond');

-- Banke
INSERT INTO `bank` (`name`, `swift_code`) VALUES 
('JPMorgan Chase', 'CHASUS33'), ('Barclays Bank', 'BARCGB22'), ('Goldman Sachs', 'GSUS33');

-- Klijenti
INSERT INTO `client` (`national_id_no`, `first_name`, `last_name`, `email`) VALUES 
('10987654321', 'John', 'Smith', 'john@email.com'),
('55544433322', 'Emily', 'Davis', 'emily@email.com'),
('99988877766', 'Michael', 'Scott', 'michael@email.com');

-- Investicijski računi
INSERT INTO `investment_account` (`client_id`, `bank_id`, `account_number`, `balance`, `currency_code`) VALUES 
(1, 1, 'US11111111111', 15000.00, 'USD'), 
(2, 2, 'GB22222222222', 5000.00, 'GBP'), 
(3, 3, 'US33333333333', 120000.00, 'USD');

-- Imovina (Assets)
INSERT INTO `asset` (`asset_type_id`, `symbol`, `name`, `current_price`) VALUES 
(1, 'AAPL', 'Apple Inc.', 180.00),   
(1, 'NVDA', 'NVIDIA Corp', 900.00),  
(2, 'BTC', 'Bitcoin', 65000.00),    
(3, 'US10Y', 'US Treasury Bond', 98.50);

-- Portfelji
INSERT INTO `portfolio` (`investment_account_id`, `name`) VALUES 
(1, 'John Tech Fund'), (2, 'Emily Mixed Bag'), (3, 'Michael Whale Portfolio');

-- Novčane transakcije
INSERT INTO `account_transaction` (`investment_account_id`, `action`, `amount`) VALUES 
(1, 'DEPOSIT', 20000.00), (1, 'WITHDRAW', 5000.00), (2, 'DEPOSIT', 5000.00), (3, 'DEPOSIT', 150000.00);

-- Transakcije imovinom
INSERT INTO `asset_transaction` (`investment_account_id`, `asset_id`, `action`, `quantity`, `price_per_unit`) VALUES 
(1, 1, 'BUY', 50, 175.00), (2, 3, 'BUY', 0.5, 60000.00), (3, 2, 'BUY', 100, 850.00), (3, 2, 'SELL', 10, 950.00);

-- Stanje u portfelju
INSERT INTO `portfolio_asset` (`portfolio_id`, `asset_id`, `quantity`, `average_price`) VALUES 
(1, 1, 50, 175.00), (2, 3, 0.5, 60000.00), (3, 2, 90, 850.00);

-- Povijest cijena
INSERT INTO `asset_price_history` (`asset_id`, `price`, `price_date`) VALUES 
(1, 170.00, '2024-01-01'), (1, 180.00, '2024-05-01'), (2, 800.00, '2024-01-01'), (2, 900.00, '2024-05-01');

-- Dividende (samo dionice)
INSERT INTO `dividend` (`asset_id`, `amount`, `payment_date`) VALUES 
(1, 0.25, '2024-03-01'), (2, 1.20, '2024-04-01');


-- ==========================================
-- 2. SLOŽENI UPITI (10 Komada za rješavanje problema)
-- ==========================================

-- PROBLEM 1: Kolika je trenutna tržišna vrijednost svakog portfelja? (Množenje količine s TRENUTNOM cijenom)
SELECT p.name AS Portfolio, SUM(pa.quantity * a.current_price) AS Total_Market_Value
FROM portfolio_asset pa
JOIN portfolio p ON pa.portfolio_id = p.id
JOIN asset a ON pa.asset_id = a.id
GROUP BY p.name;

-- PROBLEM 2: Analiza Profitabilnosti - Tko je u plusu, a tko u minusu? (Usporedba prosječne nabavne i trenutne cijene)
SELECT c.last_name, a.symbol, pa.quantity, pa.average_price AS Bought_At, a.current_price AS Current_Price,
       (a.current_price - pa.average_price) * pa.quantity AS Unrealized_Profit_Loss
FROM portfolio_asset pa
JOIN asset a ON pa.asset_id = a.id
JOIN portfolio p ON pa.portfolio_id = p.id
JOIN investment_account ia ON p.investment_account_id = ia.id
JOIN client c ON ia.client_id = c.id;

-- PROBLEM 3: Detekcija "Kitova" (Whale Alert) - Transakcije iznad 50,000 u zadnjih godinu dana.
SELECT c.last_name, at.action, a.symbol, at.quantity, at.price_per_unit, (at.quantity * at.price_per_unit) AS Total_Value
FROM asset_transaction at
JOIN investment_account ia ON at.investment_account_id = ia.id
JOIN client c ON ia.client_id = c.id
JOIN asset a ON at.asset_id = a.id
WHERE (at.quantity * at.price_per_unit) > 50000;

-- PROBLEM 4: Diverzifikacija - Koliko koji klijent ima posto u Stock vs Crypto?
SELECT c.last_name, atype.type_name, SUM(pa.quantity * a.current_price) AS Asset_Type_Value
FROM portfolio_asset pa
JOIN asset a ON pa.asset_id = a.id
JOIN asset_type atype ON a.asset_type_id = atype.id
JOIN portfolio p ON pa.portfolio_id = p.id
JOIN investment_account ia ON p.investment_account_id = ia.id
JOIN client c ON ia.client_id = c.id
GROUP BY c.last_name, atype.type_name;

-- PROBLEM 5: Pasivni prihod - Koliko je ukupno isplaćeno dividendi po dionici?
SELECT a.symbol, a.name, SUM(d.amount) AS Total_Dividend_Paid_Per_Share, COUNT(d.id) AS Payout_Count
FROM dividend d
JOIN asset a ON d.asset_id = a.id
GROUP BY a.symbol, a.name;

-- PROBLEM 6: Volatilnost cijena - Razlika između najviše i najniže cijene u povijesti.
SELECT a.symbol, MIN(aph.price) AS All_Time_Low, MAX(aph.price) AS All_Time_High, 
       (MAX(aph.price) - MIN(aph.price)) AS Price_Spread
FROM asset_price_history aph
JOIN asset a ON aph.asset_id = a.id
GROUP BY a.symbol;

-- PROBLEM 7: Likvidnost klijenata - Tko ima manje od 10,000 casha, a ogroman portfelj? (Potencijalni rizik)
SELECT c.last_name, ia.balance AS Cash_Balance, SUM(pa.quantity * a.current_price) AS Portfolio_Value
FROM client c
JOIN investment_account ia ON c.id = ia.client_id
JOIN portfolio p ON ia.id = p.investment_account_id
JOIN portfolio_asset pa ON p.id = pa.portfolio_id
JOIN asset a ON pa.asset_id = a.id
GROUP BY c.last_name, ia.balance
HAVING ia.balance < 10000 AND Portfolio_Value > 20000;

-- PROBLEM 8: Kretanje gotovine - Ukupne uplate vs Isplate po banci.
SELECT b.name AS Bank, act.action, SUM(act.amount) AS Total_Volume
FROM account_transaction act
JOIN investment_account ia ON act.investment_account_id = ia.id
JOIN bank b ON ia.bank_id = b.id
GROUP BY b.name, act.action;

-- PROBLEM 9: Aktivnost burze - Najviše trgovana imovina (po broju transakcija).
SELECT a.symbol, COUNT(at.id) AS Number_Of_Trades, SUM(at.quantity) AS Total_Volume_Traded
FROM asset_transaction at
JOIN asset a ON at.asset_id = a.id
GROUP BY a.symbol
ORDER BY Number_Of_Trades DESC;

-- PROBLEM 10: Izračun ukupnog bogatstva (Net Worth = Cash + Portfolio Value).
SELECT c.last_name, ia.balance AS Cash, IFNULL(SUM(pa.quantity * a.current_price), 0) AS Investments,
       (ia.balance + IFNULL(SUM(pa.quantity * a.current_price), 0)) AS Total_Net_Worth
FROM client c
JOIN investment_account ia ON c.id = ia.client_id
LEFT JOIN portfolio p ON ia.id = p.investment_account_id
LEFT JOIN portfolio_asset pa ON p.id = pa.portfolio_id
LEFT JOIN asset a ON pa.asset_id = a.id
GROUP BY c.last_name, ia.balance
ORDER BY Total_Net_Worth DESC;


-- ==========================================
-- 3. VIEWS (10 Pogleda za brži rad aplikacije)
-- ==========================================

-- VIEW 1: Kompletan pregled klijenata i njihovih računa
CREATE OR REPLACE VIEW v_client_full_details AS
SELECT c.id, c.first_name, c.last_name, c.email, b.name AS bank_name, ia.account_number, ia.balance
FROM client c
JOIN investment_account ia ON c.id = ia.client_id
JOIN bank b ON ia.bank_id = b.id;

-- VIEW 2: Trenutno stanje svih portfelja
CREATE OR REPLACE VIEW v_portfolio_current_state AS
SELECT p.name AS portfolio_name, a.symbol, pa.quantity, a.current_price, (pa.quantity * a.current_price) AS total_value
FROM portfolio_asset pa
JOIN portfolio p ON pa.portfolio_id = p.id
JOIN asset a ON pa.asset_id = a.id;

-- VIEW 3: Log svih burzovnih transakcija
CREATE OR REPLACE VIEW v_trade_log AS
SELECT at.create_time, c.last_name, at.action, a.symbol, at.quantity, at.price_per_unit
FROM asset_transaction at
JOIN investment_account ia ON at.investment_account_id = ia.id
JOIN client c ON ia.client_id = c.id
JOIN asset a ON at.asset_id = a.id;

-- VIEW 4: Log svih bankovnih transfera (Uplate/Isplate)
CREATE OR REPLACE VIEW v_cash_flow_log AS
SELECT act.create_time, c.last_name, b.name AS bank, act.action, act.amount
FROM account_transaction act
JOIN investment_account ia ON act.investment_account_id = ia.id
JOIN client c ON ia.client_id = c.id
JOIN bank b ON ia.bank_id = b.id;

-- VIEW 5: Samo Kripto Imovina
CREATE OR REPLACE VIEW v_crypto_assets AS
SELECT a.symbol, a.name, a.current_price
FROM asset a
JOIN asset_type atype ON a.asset_type_id = atype.id
WHERE atype.type_name = 'Crypto';

-- VIEW 6: Detalji isplata dividendi
CREATE OR REPLACE VIEW v_dividend_calendar AS
SELECT d.payment_date, a.symbol, a.name, d.amount
FROM dividend d
JOIN asset a ON d.asset_id = a.id
ORDER BY d.payment_date DESC;

-- VIEW 7: Prikaz isplativosti pozicija (Real-time P&L)
CREATE OR REPLACE VIEW v_position_pnl AS
SELECT p.name AS portfolio, a.symbol, pa.average_price, a.current_price, 
       ROUND(((a.current_price - pa.average_price) / pa.average_price) * 100, 2) AS profit_percentage
FROM portfolio_asset pa
JOIN portfolio p ON pa.portfolio_id = p.id
JOIN asset a ON pa.asset_id = a.id;

-- VIEW 8: Pregled rizika banaka (Koliko casha leži u kojoj banci)
CREATE OR REPLACE VIEW v_bank_cash_reserves AS
SELECT b.name AS bank_name, SUM(ia.balance) AS total_client_funds
FROM bank b
JOIN investment_account ia ON b.id = ia.bank_id
GROUP BY b.name;

-- VIEW 9: Posljednje promjene cijena na tržištu
CREATE OR REPLACE VIEW v_market_ticker AS
SELECT a.symbol, aph.price AS historical_price, aph.price_date
FROM asset_price_history aph
JOIN asset a ON aph.asset_id = a.id
ORDER BY aph.price_date DESC;

-- VIEW 10: Izloženost dionicama (Tko ima najviše dionica)
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