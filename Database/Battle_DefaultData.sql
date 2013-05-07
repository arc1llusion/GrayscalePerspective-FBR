-- Battle Default Data

-- Class Data
INSERT INTO `jgerma08_db`.`Battle_Class` (`Id`, `Title`, `Description`) VALUES (1, 'Warrior', 'A character capable of devastating physical attacks. Specializes in heavy weaponry.');
INSERT INTO `jgerma08_db`.`Battle_Class` (`Id`, `Title`, `Description`) VALUES (2, 'Mage', 'A character capable of great magical prowess. Specializes in spellcasting.');
INSERT INTO `jgerma08_db`.`Battle_Class` (`Id`, `Title`, `Description`) VALUES (3, 'Rogue', 'A character representing strength in stealth. Prefers being a lone wolf, rather than part of a group.');

-- Skill Data
INSERT INTO `jgerma08_db`.`Battle_Skill` (`Id`, `ClassId`, `Name`, `Formula`, `MP`, `Accuracy`) VALUES (1, 1, 'Attack', '[P_STR]-[O_DEF]', 0, 100);
INSERT INTO `jgerma08_db`.`Battle_Skill` (`Id`, `ClassId`, `Name`, `Formula`, `MP`, `Accuracy`) VALUES (2, 2, 'Attack', '[P_MAG]-[O_MDEF]', 0, 100);
INSERT INTO `jgerma08_db`.`Battle_Skill` (`Id`, `ClassId`, `Name`, `Formula`, `MP`, `Accuracy`) VALUES (3, 3, 'Attack', '([P_STR]+[P_DEX])-([O_DEF]-[O_MDEF])', 0, 100);
INSERT INTO `jgerma08_db`.`Battle_Skill` (`Id`, `ClassId`, `Name`, `Formula`, `MP`, `Accuracy`) VALUES (4, 1, 'Brutal Swing', '([P_STR]*2)-[O_DEF]', 0, 45);
INSERT INTO `jgerma08_db`.`Battle_Skill` (`Id`, `ClassId`, `Name`, `Formula`, `MP`, `Accuracy`) VALUES (5, 2, 'Fireball', '([P_MAG]*2)-[O_MDEF]', 3, 90);
INSERT INTO `jgerma08_db`.`Battle_Skill` (`Id`, `ClassId`, `Name`, `Formula`, `MP`, `Accuracy`) VALUES (6, 3, 'Silent Stab', '([P_STR]+[P_DEX]*2)-([O_DEF]-[O_MDEF])', 8, 100);


-- Stat Data

INSERT INTO `jgerma08_db`.`Battle_Stat` (`Id`, `Name`, `Description`) VALUES (1, 'HP', 'The health points for the character. When depleted, the character loses in battle.');
INSERT INTO `jgerma08_db`.`Battle_Stat` (`Id`, `Name`, `Description`) VALUES (2, 'MP', 'The magic points for the character. This attribute is used for spellcasting, and once depleted no more magic can be cast.');
INSERT INTO `jgerma08_db`.`Battle_Stat` (`Id`, `Name`, `Description`) VALUES (3, 'STR', 'This attribute garners physical strength. The higher the value, the more physical damage the character can deal.');
INSERT INTO `jgerma08_db`.`Battle_Stat` (`Id`, `Name`, `Description`) VALUES (4, 'DEF', 'This attribute garners physical resistance. The higher the value, the more resilient to physical damage the character is.');
INSERT INTO `jgerma08_db`.`Battle_Stat` (`Id`, `Name`, `Description`) VALUES (5, 'MAG', 'This attribute garners magical strength. The higher the value, the more magical damage the character can deal.');
INSERT INTO `jgerma08_db`.`Battle_Stat` (`Id`, `Name`, `Description`) VALUES (6, 'MDEF', 'This attribute garners magical resistance. The higher the value, the more resilient to magical damage the character is.');
INSERT INTO `jgerma08_db`.`Battle_Stat` (`Id`, `Name`, `Description`) VALUES (7, 'DEX', 'This attribute garners dexterity. It determines the characters evasion, hit rate, and critical hit rate. The higher the value, the more likely the character will hit, evade, and deal damage based on a multiplier.');


-- Class Progression Data

INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (1, 1, 30);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (1, 2, 20);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (1, 3, 3);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (1, 4, 2);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (1, 5, 1);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (1, 6, 1);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (1, 7, 2);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (2, 1, 10);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (2, 2, 30);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (2, 3, 1);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (2, 4, 2);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (2, 5, 3);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (2, 6, 2);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (2, 7, 2);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (3, 1, 20);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (3, 2, 10);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (3, 3, 2);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (3, 4, 3);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (3, 5, 1);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (3, 6, 2);
INSERT INTO `jgerma08_db`.`Battle_ClassProgression` (`ClassId`, `StatId`, `Progression`) VALUES (3, 7, 3);




-- Object Type Data

INSERT INTO `jgerma08_db`.`Battle_ObjectType` (`Id`, `Name`) VALUES (1, 'Class');
INSERT INTO `jgerma08_db`.`Battle_ObjectType` (`Id`, `Name`) VALUES (2, 'Weapon');
INSERT INTO `jgerma08_db`.`Battle_ObjectType` (`Id`, `Name`) VALUES (3, 'Armor');
INSERT INTO `jgerma08_db`.`Battle_ObjectType` (`Id`, `Name`) VALUES (4, 'Skill');
INSERT INTO `jgerma08_db`.`Battle_ObjectType` (`Id`, `Name`) VALUES (5, 'Spell');
INSERT INTO `jgerma08_db`.`Battle_ObjectType` (`Id`, `Name`) VALUES (6, 'Character');


-- Object Stat Mapping Data

INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (1, 1, 1, 80);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (2, 1, 1, 10);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (3, 1, 1, 10);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (4, 1, 1, 10);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (5, 1, 1, 1);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (6, 1, 1, 2);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (7, 1, 1, 3);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (1, 1, 2, 40);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (2, 1, 2, 80);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (3, 1, 2, 1);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (4, 1, 2, 2);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (5, 1, 2, 10);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (6, 1, 2, 7);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (7, 1, 2, 3);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (1, 1, 3, 60);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (2, 1, 3, 40);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (3, 1, 3, 5);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (4, 1, 3, 4);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (5, 1, 3, 2);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (6, 1, 3, 4);
INSERT INTO `jgerma08_db`.`Battle_ObjectStatValue` (`StatId`, `ObjectType`, `ObjectId`, `Value`) VALUES (7, 1, 3, 10);

