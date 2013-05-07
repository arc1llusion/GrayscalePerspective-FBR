-- Battle Schema
use jgerma08_db;

DROP TABLE IF EXISTS Battle_Log;
DROP TABLE IF EXISTS Battle_Active;

DROP TABLE IF EXISTS Battle_ClassProgression;

DROP TABLE IF EXISTS Battle_ObjectStatValue;
DROP TABLE IF EXISTS Battle_Stat;
DROP TABLE IF EXISTS Battle_ObjectType;
DROP TABLE IF EXISTS UserCharacterMapping;
DROP TABLE IF EXISTS Battle_Skill;
DROP TABLE IF EXISTS Battle_Character;
DROP TABLE IF EXISTS Battle_Class;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`Battle_Class` (
  `Id` INT NOT NULL AUTO_INCREMENT ,
  `Title` VARCHAR(45) NOT NULL ,
  `Description` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`Id`) )
ENGINE = InnoDB;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`Battle_Skill` (
  `Id` INT NOT NULL AUTO_INCREMENT ,
  `ClassId` INT NOT NULL ,
  `Name` VARCHAR(45) NOT NULL ,
  `Formula` VARCHAR(255) NOT NULL ,
  `MP` INT NOT NULL DEFAULT 0 ,
  `Accuracy` INT NOT NULL DEFAULT 100 ,
  PRIMARY KEY (`Id`) ,
  INDEX `fk_Class_Skill_idx` (`ClassId` ASC) ,
  CONSTRAINT `fk_Class_Skill`
    FOREIGN KEY (`ClassId` )
    REFERENCES `jgerma08_db`.`Battle_Class` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`Battle_Character` (
  `Id` INT NOT NULL AUTO_INCREMENT ,
  `ClassId` INT NULL ,
  `Name` VARCHAR(45) NOT NULL UNIQUE,
  `Level` INT NOT NULL DEFAULT 1 ,
  `EXP` INT NOT NULL ,
  PRIMARY KEY (`Id`) ,
  INDEX `Battle_Character_Class_Fk_idx` (`ClassId` ASC) ,
  UNIQUE INDEX `Name_UNIQUE` (`Name` ASC) ,
  CONSTRAINT `Battle_Character_Class_Fk`
    FOREIGN KEY (`ClassId` )
    REFERENCES `jgerma08_db`.`Battle_Class` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`UserCharacterMapping` (
  `UserId` INT NOT NULL ,
  `CharacterId` INT NOT NULL ,
  INDEX `UserKey_idx` (`UserId` ASC) ,
  INDEX `CharacterKey_idx` (`CharacterId` ASC) ,
  CONSTRAINT `UserKey`
    FOREIGN KEY (`UserId` )
    REFERENCES `jgerma08_db`.`User` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `CharacterKey`
    FOREIGN KEY (`CharacterId` )
    REFERENCES `jgerma08_db`.`Battle_Character` (`Id` )
    ON DELETE RESTRICT
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`Battle_Stat` (
  `Id` INT NOT NULL AUTO_INCREMENT ,
  `Name` VARCHAR(45) NOT NULL ,
  `Description` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`Id`) )
ENGINE = InnoDB;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`Battle_ObjectType` (
  `Id` INT NOT NULL AUTO_INCREMENT ,
  `Name` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`Id`, `Name`) )
ENGINE = InnoDB;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`Battle_ObjectStatValue` (
  `StatId` INT NOT NULL ,
  `ObjectType` INT NOT NULL ,
  `ObjectId` INT NOT NULL ,
  `Value` INT NOT NULL ,
  INDEX `ObjectStat_ObjectType_idx` (`ObjectType` ASC) ,
  CONSTRAINT `ObjectStat_Fk`
    FOREIGN KEY (`StatId` )
    REFERENCES `jgerma08_db`.`Battle_Stat` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `ObjectStat_ObjectType`
    FOREIGN KEY (`ObjectType` )
    REFERENCES `jgerma08_db`.`Battle_ObjectType` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`Battle_ClassProgression` (
  `ClassId` INT NOT NULL ,
  `StatId` INT NOT NULL ,
  `Progression` TINYINT(4) NOT NULL ,
  INDEX `Stat_Progression_Fk_idx` (`StatId` ASC) ,
  INDEX `Class_Progression_Fk_idx` (`ClassId` ASC) ,
  CONSTRAINT `Class_Progression_Fk`
    FOREIGN KEY (`ClassId` )
    REFERENCES `jgerma08_db`.`Battle_Class` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Stat_Progression_Fk`
    FOREIGN KEY (`StatId` )
    REFERENCES `jgerma08_db`.`Battle_Stat` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`Battle_Active` (
  `Id` INT NOT NULL AUTO_INCREMENT ,
  `Challenger` INT NOT NULL ,
  `Challenged` INT NOT NULL ,
  `Status` INT NOT NULL DEFAULT 1 COMMENT '1 means active, 0 inactive.' ,
  PRIMARY KEY (`Id`) ,
  INDEX `fk_ActiveBattle_Character_idx` (`Challenger` ASC) ,
  INDEX `fk_ActiveBattle_CharacterTwo_idx` (`Challenged` ASC) ,
  CONSTRAINT `fk_ActiveBattle_CharacterOne`
    FOREIGN KEY (`Challenger` )
    REFERENCES `jgerma08_db`.`Battle_Character` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ActiveBattle_CharacterTwo`
    FOREIGN KEY (`Challenged` )
    REFERENCES `jgerma08_db`.`Battle_Character` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE  TABLE IF NOT EXISTS `jgerma08_db`.`Battle_Log` (
  `Id` INT NOT NULL AUTO_INCREMENT ,
  `BattleId` INT NOT NULL ,
  `CharacterId` INT NOT NULL ,
  `ActionMessage` LONGTEXT NOT NULL ,
  `CharacterMessage` LONGTEXT NULL ,
  PRIMARY KEY (`Id`) ,
  INDEX `fk_Log_ActiveBattle_idx` (`BattleId` ASC) ,
  INDEX `fk_Log_CharacterId_idx` (`CharacterId` ASC) ,
  CONSTRAINT `fk_Log_ActiveBattle`
    FOREIGN KEY (`BattleId` )
    REFERENCES `jgerma08_db`.`Battle_Active` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Log_CharacterId`
    FOREIGN KEY (`CharacterId` )
    REFERENCES `jgerma08_db`.`Battle_Character` (`Id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- Procedures
DROP Procedure IF EXISTS Battle_Character_Get;
DROP Procedure IF EXISTS Battle_Character_LevelUp;
DROP Procedure IF EXISTS Battle_Character_New;
DROP Procedure IF EXISTS Battle_Character_Save;
DROP Procedure IF EXISTS Battle_Initiate;

DELIMITER $$

CREATE DEFINER=`jgerma08`@`localhost` PROCEDURE `Battle_Character_Get`(p_characterid int)
BEGIN

	SELECT 
		BCH.*, 
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(1, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(1, BCH.ClassId, BCH.Level)) AS CHAR(10)))) HP, 
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(2, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(2, BCH.ClassId, BCH.Level)) AS CHAR(10)))) MP,
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(3, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(3, BCH.ClassId, BCH.Level)) AS CHAR(10)))) STR,
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(4, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(4, BCH.ClassId, BCH.Level)) AS CHAR(10)))) DEF,
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(5, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(5, BCH.ClassId, BCH.Level)) AS CHAR(10))))  MAG,
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(6, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(6, BCH.ClassId, BCH.Level)) AS CHAR(10))))  MDEF,
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(7, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(7, BCH.ClassId, BCH.Level)) AS CHAR(10))))  DEX

		FROM Battle_Character BCH
		WHERE BCH.Id = p_characterid;

END$$

delimiter $$

CREATE DEFINER=`jgerma08`@`localhost` PROCEDURE `Battle_Character_LevelUp`
(
	p_characterid INT
)
BEGIN
	-- First, update level.
	UPDATE Battle_Character SET Level = Level + 1 WHERE Id = p_characterid;

	-- Next, update character stats to go up with the level up. Class stats are dynamic, but character stats need to go up with it.
	UPDATE Battle_ObjectStatValue BOS
	 JOIN Battle_Character BC ON BOS.ObjectId = BC.Id
	 JOIN Battle_ClassProgression BCP ON BOS.StatId = BCP.StatId AND BC.ClassId = BCP.ClassId
	SET BOS.Value = BOS.Value + BCP.Progression  
	WHERE ObjectId = p_characterid and ObjectType = 6;

END$$

delimiter $$

CREATE DEFINER=`jgerma08`@`localhost` PROCEDURE `Battle_Character_New`(
		p_classid INT,
		p_charactername CHAR(45),
		INOUT p_characterid INT
	)
BEGIN
	-- First add the new character entry
	DECLARE characterid INT;
	INSERT INTO `jgerma08_db`.`Battle_Character` (`ClassId`, `Name`, `Level`, `EXP`) 
		VALUES (p_classid, p_charactername, 1, 15);
	
	SET characterid = (select LAST_INSERT_ID());

	INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (1, 6, characterid, (SELECT Battle_GetClassStatValue(1, p_classid, 1)));
	INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (2, 6, characterid, (SELECT Battle_GetClassStatValue(2, p_classid, 1)));
	INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (3, 6, characterid, (SELECT Battle_GetClassStatValue(3, p_classid, 1)));
	INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (4, 6, characterid, (SELECT Battle_GetClassStatValue(4, p_classid, 1)));
	INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (5, 6, characterid, (SELECT Battle_GetClassStatValue(5, p_classid, 1)));
	INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (6, 6, characterid, (SELECT Battle_GetClassStatValue(6, p_classid, 1)));
	INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (7, 6, characterid, (SELECT Battle_GetClassStatValue(7, p_classid, 1)));

	SET p_characterid = characterid;
END$$

delimiter $$

CREATE DEFINER=`jgerma08`@`localhost` PROCEDURE `Battle_Character_Save`(
	p_characterid INT,
	p_name CHAR(45),
	p_exp INT,
	p_hp INT,
	p_mp INT,
	p_str INT,
	p_def INT,
	p_mag INT,
	p_mdef INT,
	p_dex INT	
)
BEGIN
	UPDATE Battle_Character SET Name = p_name, EXP = p_exp WHERE Id = p_characterid;

	UPDATE Battle_ObjectStatValue SET Value = p_hp 
		WHERE StatId = 1 and ObjectType = 6 and ObjectId = p_characterid;
	UPDATE Battle_ObjectStatValue SET Value = p_mp 
		WHERE StatId = 2 and ObjectType = 6 and ObjectId = p_characterid;
	UPDATE Battle_ObjectStatValue SET Value = p_str 
		WHERE StatId = 3 and ObjectType = 6 and ObjectId = p_characterid;
	UPDATE Battle_ObjectStatValue SET Value = p_def 
		WHERE StatId = 4 and ObjectType = 6 and ObjectId = p_characterid;
	UPDATE Battle_ObjectStatValue SET Value = p_mag 
		WHERE StatId = 5 and ObjectType = 6 and ObjectId = p_characterid;
	UPDATE Battle_ObjectStatValue SET Value = p_mdef 
		WHERE StatId = 6 and ObjectType = 6 and ObjectId = p_characterid;
	UPDATE Battle_ObjectStatValue SET Value = p_dex 
		WHERE StatId = 7 and ObjectType = 6 and ObjectId = p_characterid;
END$$

delimiter $$

CREATE DEFINER=`jgerma08`@`localhost` PROCEDURE `Battle_Initiate`(
	p_challenger INT,
	p_challenged INT
)
BEGIN
	DECLARE l_battleid INT;
	DECLARE l_challengername CHAR(45);
	DECLARE l_challengedname CHAR(45);

	INSERT INTO Battle_Active(Challenger, Challenged, Status) 
		VALUES(p_challenger, p_challenged, 2);

	SET l_battleid = (select LAST_INSERT_ID());
	SET l_challengername = (SELECT Name From Battle_Character WHERE Id = p_challenger);
	SET l_challengedname = (SELECT Name From Battle_Character WHERE Id = p_challenged);

	INSERT INTO Battle_Log(BattleId, CharacterId, ActionMessage, CharacterMessage)
		VALUES(l_battleid, p_challenger, CONCAT("Battle initiated by ", l_challengername, " against ", l_challengedname), "");
END$$

DELIMITER ;

-- Functions 
DROP FUNCTION IF EXISTS Battle_GetCharacterStatValue;
DROP FUNCTION IF EXISTS Battle_GetClassStatValue;
DROP FUNCTION IF EXISTS Battle_GetStatValue;
DROP FUNCTION IF EXISTS Battle_GetLastCharacterIdAction;
DROP FUNCTION IF EXISTS Battle_GetOpponent;

delimiter $$

CREATE DEFINER=`jgerma08`@`localhost` FUNCTION `Battle_GetCharacterStatValue`(
p_statid INT,
p_objectid INT,
p_level INT) RETURNS int(11)
BEGIN

	DECLARE statvalue INT;

	SELECT Value INTO statvalue FROM Battle_ObjectStatValue BOS
	WHERE ObjectType = 6 
	AND ObjectId = p_objectid 
	AND StatId = p_statid
	LIMIT 1;

	#Level is 0 based, so we subtract 1.
	#SET statvalue = statvalue + ( (p_level-1) * (SELECT Progression FROM Battle_ClassProgression WHERE StatId = p_statid AND ClassId = p_objectid));

	RETURN statvalue;
END$$

delimiter $$

CREATE DEFINER=`jgerma08`@`localhost` FUNCTION `Battle_GetStatValue`(
p_statid INT,
p_objecttype INT,
p_objectid INT) RETURNS int(11)
BEGIN
DECLARE statvalue INT;
	SELECT Value INTO statvalue FROM Battle_ObjectStatValue 
	WHERE ObjectType = p_objecttype 
	AND ObjectId = p_objectid 
	AND StatId = p_statid
	LIMIT 1;

RETURN statvalue;
END$$

delimiter $$

CREATE DEFINER=`jgerma08`@`localhost` FUNCTION `Battle_GetClassStatValue`(
p_statid INT,
p_objectid INT,
p_level INT) RETURNS int(11)
BEGIN

	DECLARE statvalue INT;

	SELECT Value INTO statvalue FROM Battle_ObjectStatValue BOS
	WHERE ObjectType = 1 
	AND ObjectId = p_objectid 
	AND StatId = p_statid
	LIMIT 1;

	#Level is 0 based, so we subtract 1.
	SET statvalue = statvalue + ( (p_level-1) * (SELECT Progression FROM Battle_ClassProgression WHERE StatId = p_statid AND ClassId = p_objectid));

	RETURN statvalue;
END$$

delimiter $$

CREATE DEFINER=`jgerma08`@`localhost` FUNCTION `Battle_GetLastCharacterIdAction`(
	p_battleid INT
) RETURNS int(11)
BEGIN
	DECLARE l_characterid_turn INT;

	SELECT BC.Id INTO l_characterid_turn 
		FROM Battle_Character BC
		JOIN Battle_Log BL ON BC.Id = BL.CharacterId
		WHERE BL.BattleId = p_battleid
		ORDER BY BL.Id DESC
		LIMIT 1;
		
RETURN l_characterid_turn;
END$$

delimiter $$

CREATE DEFINER=`jgerma08`@`localhost` FUNCTION `Battle_GetOpponent`(
p_characterid INT
) RETURNS int(11)
BEGIN

DECLARE l_opponentid INT;

DROP TEMPORARY TABLE IF EXISTS MatchedBattles;

CREATE TEMPORARY TABLE MatchedBattles (
	BattleId INT,
	Challenger INT,
	Challenged INT
);

INSERT INTO MatchedBattles
	SELECT Id, Challenger, Challenged FROM Battle_Active 
	WHERE (Challenger = p_characterid or Challenged = p_characterid) AND Status <> 1;

IF (SELECT 1 FROM MatchedBattles WHERE Challenger = p_characterid) THEN
	SET l_opponentid = (SELECT Challenged FROM MatchedBattles LIMIT 1);
ELSE 
	SET l_opponentid = (SELECT Challenger FROM MatchedBattles LIMIT 1);	
END IF;

DROP TEMPORARY TABLE MatchedBattles;

RETURN l_opponentid;
END$$


