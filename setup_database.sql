-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

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
