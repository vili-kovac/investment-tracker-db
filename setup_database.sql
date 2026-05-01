-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Schema investment_tracker
--
-- Investment Banking Tracker 
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `investment_tracker`;

CREATE SCHEMA IF NOT EXISTS `investment_tracker` DEFAULT CHARACTER SET utf8 ;
USE `investment_tracker` ;

-- -----------------------------------------------------
-- Table `investment_tracker`.`client`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`client` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `national_id_no` VARCHAR(11) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `surname` VARCHAR(50) NOT NULL,
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
-- Table `investment_tracker`.`asset_types`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`asset_types` (
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
  `asset_types_id` INT UNSIGNED NOT NULL,
  `symbol` VARCHAR(10) NOT NULL COMMENT '“Stock”, “Crypto”, “Bond”',
  `name` VARCHAR(100) NOT NULL,
  `current_price` DECIMAL(18,8) NOT NULL DEFAULT 0,
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_asset_asset_types1_idx` (`asset_types_id` ASC) VISIBLE,
  UNIQUE INDEX `symbol_UNIQUE` (`symbol` ASC) VISIBLE,
  CONSTRAINT `fk_asset_asset_types1`
    FOREIGN KEY (`asset_types_id`)
    REFERENCES `investment_tracker`.`asset_types` (`id`)
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
-- Table `investment_tracker`.`transaction`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `investment_tracker`.`transaction` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `investment_account_id` INT UNSIGNED NOT NULL,
  `asset_id` INT UNSIGNED NULL,
  `type` ENUM('BUY', 'SELL', 'DEPOSIT', 'WITHDRAW') NULL,
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


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;




-- ==========================================
-- 1. INSERTING DUMMY DATA (8 CLIENTS)
-- ==========================================

-- 1. Adding asset types (1 = Stock, 2 = Crypto)
INSERT INTO `asset_types` (`type_name`) VALUES 
('Stock'), 
('Crypto');

-- 2. Adding a few banks
INSERT INTO `bank` (`name`, `swift_code`) VALUES 
('Revolut Bank', 'REVORO2L'), -- ID 1
('JP Morgan', 'CHASUS33'),    -- ID 2
('Barclays', 'BARCGB22');     -- ID 3

-- 3. Adding 8 clients
INSERT INTO `client` (`national_id_no`, `name`, `surname`, `email`) VALUES 
('12345678901', 'Vili', 'Vilic', 'vili@invest.com'),
('10987654321', 'John', 'Smith', 'john.smith@email.com'),
('55544433322', 'Emily', 'Davis', 'emily.d@email.com'),
('99988877766', 'Michael', 'Scott', 'mscott@dundermifflin.com'),
('11122233344', 'Sarah', 'Connor', 'sconnor@skynet.com'),
('77766655544', 'Tony', 'Stark', 'tony@stark.com'),
('33322211100', 'Bruce', 'Wayne', 'bwayne@wayneent.com'),
('44455566677', 'Clark', 'Kent', 'ckent@dailyplanet.com');

-- 4. Creating investment accounts (Notice how bank_id repeats, putting multiple clients in the same bank)
INSERT INTO `investment_account` (`client_id`, `bank_id`, `account_number`, `balance`, `currency_code`) VALUES 
(1, 1, 'HR11111111111', 5000.00, 'EUR'),  -- Vili in Revolut
(2, 2, 'US22222222222', 15000.00, 'USD'), -- John in JP Morgan
(3, 3, 'GB33333333333', 2500.00, 'GBP'),  -- Emily in Barclays
(4, 1, 'US44444444444', 400.00, 'USD'),   -- Michael in Revolut
(5, 2, 'US55555555555', 8000.00, 'USD'),  -- Sarah in JP Morgan
(6, 3, 'US66666666666', 99000.00, 'USD'), -- Tony in Barclays
(7, 1, 'US77777777777', 50000.00, 'USD'), -- Bruce in Revolut
(8, 2, 'US88888888888', 1200.00, 'USD');  -- Clark in JP Morgan

-- 5. Defining assets (Added Nvidia just for fun)
INSERT INTO `asset` (`asset_types_id`, `symbol`, `name`, `current_price`) VALUES 
(1, 'TSLA', 'Tesla, Inc.', 175.00),    -- ID 1
(1, 'PODR', 'Podravka d.d.', 160.00),  -- ID 2
(1, 'AAPL', 'Apple Inc.', 180.00),     -- ID 3
(2, 'BTC', 'Bitcoin', 65000.00),       -- ID 4
(1, 'NVDA', 'NVIDIA Corp', 900.00);    -- ID 5

-- 6. Making portfolios (1 for each client)
INSERT INTO `portfolio` (`investment_account_id`, `name`) VALUES 
(1, 'Vili Main Portfolio'),
(2, 'John Retirement Fund'),
(3, 'Emily Crypto Bag'),
(4, 'Michael Paper Portfolio'),
(5, 'Sarah Doomsday Fund'),
(6, 'Tony Tech Holdings'),
(7, 'Bruce Stealth Assets'),
(8, 'Clark Modest Savings');

-- 7. Recording transactions (EVERYONE makes at least one transaction)
INSERT INTO `transaction` (`investment_account_id`, `asset_id`, `type`, `quantity`, `price_per_unit`) VALUES 
(1, 1, 'BUY', 10, 170.00),      -- Vili buys Tesla
(1, 2, 'DEPOSIT', 24, 160.00),  -- Vili deposits Podravka
(2, 3, 'BUY', 5, 175.00),       -- John buys Apple
(3, 4, 'BUY', 0.5, 64000.00),   -- Emily buys Bitcoin
(4, 3, 'BUY', 1, 180.00),       -- Michael buys Apple
(5, 2, 'BUY', 100, 155.00),     -- Sarah buys Podravka
(6, 5, 'BUY', 50, 850.00),      -- Tony buys Nvidia
(7, 1, 'BUY', 200, 170.00),     -- Bruce buys Tesla
(8, 4, 'BUY', 0.01, 65000.00);  -- Clark buys Bitcoin

-- 8. Putting assets into the portfolios (Matching the transactions above)
INSERT INTO `portfolio_asset` (`portfolio_id`, `asset_id`, `quantity`, `average_price`) VALUES 
(1, 1, 10, 170.00),     -- Vili's Tesla
(1, 2, 24, 160.00),     -- Vili's Podravka
(2, 3, 5, 175.00),      -- John's Apple
(3, 4, 0.5, 64000.00),  -- Emily's Bitcoin
(4, 3, 1, 180.00),      -- Michael's Apple
(5, 2, 100, 155.00),    -- Sarah's Podravka
(6, 5, 50, 850.00),     -- Tony's Nvidia
(7, 1, 200, 170.00),    -- Bruce's Tesla
(8, 4, 0.01, 65000.00); -- Clark's Bitcoin


-- ==========================================
-- 2. QUERIES FOR TESTING AND REPORTING
-- ==========================================

-- QUERY 1: Shows which clients own which assets and in what quantity.
-- This helps us see the exact contents of everyone's portfolio.
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


-- QUERY 2: Displays the transaction history.
-- Useful for auditing what operations (BUY, SELL, DEPOSIT) clients made.
SELECT 
    t.create_time AS 'Date',
    c.surname AS 'Client Surname',
    t.type AS 'Operation',
    a.symbol AS 'Asset',
    t.quantity AS 'Qty',
    t.price_per_unit AS 'Price'
FROM transaction t
JOIN investment_account ia ON t.investment_account_id = ia.id
JOIN client c ON ia.client_id = c.id
JOIN asset a ON t.asset_id = a.id;


-- QUERY 3: Shows bank account balances for all investment accounts.
-- ADDED CLIENT NAME so you can actually see whose account is in which bank!
SELECT 
    c.name AS 'Client First Name',
    c.surname AS 'Client Last Name',
    b.name AS 'Bank Name',
    ia.account_number AS 'IBAN',
    ia.balance AS 'Cash Balance',
    ia.currency_code AS 'Currency'
FROM bank b
JOIN investment_account ia ON b.id = ia.bank_id
JOIN client c ON ia.client_id = c.id
ORDER BY b.name; -- Sortira ih po abecedi banke da lakše vidiš tko je s kim u istoj banci