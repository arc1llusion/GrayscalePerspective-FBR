use jgerma08_db;

DROP TABLE User_Profile;
DROP TABLE User;

DROP TABLE Flashcard;
DROP TABLE Deck;
DROP TABLE Category;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`User` (
  `Id` INT NOT NULL AUTO_INCREMENT ,
  `Username` VARCHAR(45) NOT NULL ,
  `Email` VARCHAR(45) NOT NULL ,
  `Password` CHAR(64) NOT NULL COMMENT 'Using SHA-256 hashing using Perls Crypt functions' ,
  `Salt` CHAR(14) NOT NULL COMMENT 'v' ,
  `JoinDate` DATETIME NOT NULL ,
  PRIMARY KEY (`Id`) )
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `jgerma08_db`.`User_Profile` (
  `UserId` INT NOT NULL ,
  `FirstName` VARCHAR(45) NULL ,
  `LastName` VARCHAR(45) NULL ,
  PRIMARY KEY (`UserId`) ,
  CONSTRAINT `FK_User`
    FOREIGN KEY (`UserId` )
    REFERENCES `jgerma08_db`.`User` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`Category` (
  `Id` INT NOT NULL AUTO_INCREMENT ,
  `Title` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`Id`) )
ENGINE = InnoDB;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`Deck` (
  `Id` INT NOT NULL AUTO_INCREMENT ,
  `CategoryId` INT NOT NULL ,
  `Title` VARCHAR(45) NOT NULL ,
  `CreatedBy` INT NOT NULL ,
  `CreatedDate` DATETIME NULL ,
  PRIMARY KEY (`Id`) ,
  INDEX `fk_Deck_Category1_idx` (`CategoryId` ASC) ,
  CONSTRAINT `fk_Deck_Category1`
    FOREIGN KEY (`CategoryId` )
    REFERENCES `jgerma08_db`.`Category` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`Flashcard` (
  `Id` INT NOT NULL AUTO_INCREMENT ,
  `DeckId` INT NOT NULL ,
  `Question` LONGTEXT NOT NULL ,
  `Answer` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`Id`) ,
  CONSTRAINT `fk_Flashcard_Deck1`
    FOREIGN KEY (`DeckId` )
    REFERENCES `jgerma08_db`.`Deck` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- Procedures
delimiter $$

CREATE DEFINER=`jgerma08`@`localhost` PROCEDURE `User_Save`(
	IN p_username VARCHAR(45),
	IN p_email VARCHAR(45),
	IN p_password CHAR(64),
	IN p_salt CHAR(14),
	IN p_firstname CHAR(45),
	IN p_lastname VARCHAR(45)
)
BEGIN

-- Warm up Script: call User_Save('Jared3','email@email.com','{SSHA256}mThXp7e75I2MX4HAZuXrjpO7F9f1SwYEhhfEB2pb0IOlNBP1','HEX{d4a2d42b}', 'jared', 'germano'); 

DECLARE l_userid INT;
DECLARE io_characterid INT;

INSERT INTO `jgerma08_db`.`User` (Username, Email, Password, Salt, JoinDate) 
	VALUES (p_username, p_email, p_password, p_salt, (SELECT CURRENT_TIMESTAMP));

SELECT User.Id INTO l_userid FROM User ORDER BY JoinDate DESC LIMIT 1;

INSERT INTO `jgerma08_db`.`User_Profile` (UserId, FirstName, LastName)
	VALUE (l_userid, p_firstname, p_lastname);

call Battle_Character_New(1, p_username, io_characterid);

INSERT INTO UserCharacterMapping VALUES(l_userid, io_characterid);

END$$

delimiter $$
DROP PROCEDURE IF EXISTS `User_Save`$$
CREATE DEFINER=`jgerma08`@`localhost` PROCEDURE `User_Save`(
	IN p_username VARCHAR(45),
	IN p_email VARCHAR(45),
	IN p_password CHAR(64),
	IN p_salt CHAR(14),
	IN p_firstname CHAR(45),
	IN p_lastname VARCHAR(45)
)
BEGIN

-- Warm up Script: call User_Save('Jared3','email@email.com','{SSHA256}mThXp7e75I2MX4HAZuXrjpO7F9f1SwYEhhfEB2pb0IOlNBP1','HEX{d4a2d42b}', 'jared', 'germano'); 

DECLARE l_userid INT;

INSERT INTO `jgerma08_db`.`User` (Username, Email, Password, Salt, JoinDate) 
	VALUES (p_username, p_email, p_password, p_salt, (SELECT CURRENT_TIMESTAMP));

SELECT User.Id INTO l_userid FROM User ORDER BY JoinDate DESC LIMIT 1;

INSERT INTO `jgerma08_db`.`User_Profile` (UserId, FirstName, LastName)
	VALUE (l_userid, p_firstname, p_lastname);

END$$
DELIMITER ;

-- Functions
DROP FUNCTION User_GetCharacterId;

delimiter $$

CREATE DEFINER=`jgerma08`@`localhost` FUNCTION `User_GetCharacterId`(p_userid INT) RETURNS int(11)
BEGIN	
RETURN (SELECT CharacterId FROM UserCharacterMapping WHERE UserId = p_userid);
END$$



#Default Data

#INSERT INTO `jgerma08_db`.`User` (`Username`, `Email`, `Password`, `Salt`, `JoinDate`) VALUES ('Jared', 'surfintime0027@hotmail.com', '01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567', '01234567891234', (select CURRENT_TIMESTAMP));
#INSERT INTO `jgerma08_db`.`User_Profile` (`UserId`, `FirstName`, `LastName`) VALUES ('1', 'Jared', 'Germano');
