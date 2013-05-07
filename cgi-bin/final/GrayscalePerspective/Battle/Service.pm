package GrayscalePerspective::Battle::Service;

# Service.pm
# This module will facilitate all external methods for the Battle system. Things like getting collections of data as well as facilitating the actual
# flow of Battle. Creating, actions, and ending the battle and maintaining the exp and other such ideas.

# Battle Status Meanings
# 1 - Completed
# 2 - Initiated
# 3 - In Progress
# 4 - Denied

use GrayscalePerspective::DAL;
use GrayscalePerspective::Battle::Character;
use GrayscalePerspective::Battle::Class;

use base Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(getAllClasses initiateBattle doesCharacterHaveActiveBattle doEitherCharactersHaveActiveBattle takeTurn getOpponentCharacterObject getBattleLog);

my ( $Battle_Completed, $Battle_Initiated, $Battle_InProgress, $Battle_Denied ) = (1, 2, 3, 4);

# getAllClasses() - Gets all the Battle Classes in the system.
#
# Takes no parameters.
#
# Returns an array reference with the list of class objects
sub getAllClasses {
	my @params = ();
	my @classes_raw = @{GrayscalePerspective::DAL::execute_table_arrayref("SELECT * FROM Battle_Class")};
	
	my @classes = ();
	
	foreach my $class (@classes_raw) {
		my $temp = new GrayscalePerspective::Class($class->{Id}, 1);
		
		push(@classes, $temp);
	}
	
	return \@classes;
}

# doesCharacterExistByName() - Checks if a character name exists already in the database.
#
# $_[0] - The character name to check.
#
# Returns true if the character name exists, false otherwise.
sub doesCharacterExistByName {
	my $charactername = $_[0];
	
	my @params = ( $charactername );
	
	if ( GrayscalePerspective::DAL::execute_scalar("SELECT 1 FROM Battle_Character WHERE Name = ?", \@params) ) {
		return 1;
	}
	return 0;
}

# initiateBattle() - Initiates a battle between two characters. Checks certain application constraints such as challenging oneself and if either character
# is already in battle.
#
# $_[0] = The character that initiated the challenge.
# $_[1] = The character that the challenger...challenged.
#
# Returns the battle id if the initiation was successful.
sub initiateBattle {
	my $challenger = $_[0];
	my $challenged = $_[1];
	my $battleid;
	
	if ( not defined ( $challenged ) or not defined ( $challenged->getId() ) ) {
		return "The opponent you challenged does not exist in this world.";
	}
	
	if($challenger->getName() eq $challenged->getName() ) {
		return "You cannot challenge yourself!"; 
	}
	
	if ( doEitherCharactersHaveActiveBattle( $challenger->getId(), $challenged->getId()) == 1 ) {
		#Check if they're battling each other. If so, resume that battle by returning the id, If not, then, no new battle!
		$battleid = _areCharactersBattlingEachOther ( $challenger->getId(), $challenged->getId() );
		if ( $battleid ) {
			return $battleid;
		}
		else {
			return "You or your opponent are currently already enganged in combat.";
		}
	}
	
	if ( ( not $challenger->isHealthZero() ) and ( not $challenged->isHealthZero() ) ) {	
		my @params = ( $challenger->getId(), $challenged->getId() );
		my $result = GrayscalePerspective::DAL::execute_query("call Battle_Initiate(?, ?);", \@params);
		
		@params = ( $challenger->getId(), $challenged->getId(), $Battle_Completed );
		$battleid = GrayscalePerspective::DAL::execute_scalar("SELECT Id FROM Battle_Active WHERE (Challenger = ? and Challenged = ?) AND Status <> ?", \@params);
		
		return $battleid;
	}
	
	return "You or your opponent does not have the strength to enter a battle right now.";
}

# doesCharacterHaveActiveBattle() - Checks to see if a character is already in battle. It checks the database if the character is in a battle with
# status != $Battle_Completed, either challenger or challenged, if so then they are available for a new battle.
#
# $_[0] = The character to check if they are in combat.
#
# Returns 1 if the character is in combat, and 0 otherwise.
sub doesCharacterHaveActiveBattle {
	my $singlecharacter = $_[0];
	
	my @params = ( $singlecharacter, $singlecharacter, $Battle_Completed );
	my $result = GrayscalePerspective::DAL::execute_single_row_hashref("SELECT 1 ActiveBattle FROM Battle_Active WHERE (Challenger = ? or Challenged = ?) AND Status <> ?", \@params);
	return _checkActiveBattleHash($result);
}

# doesCharacterHaveActiveBattle() - Checks to see if a character is already in battle. It checks the database if the character is in a battle with
# status != $Battle_Completed, either challenger or challenged, if so then they are available for a new battle.
#
# $_[0] = The character that initiated the challenge.
# $_[1] = The character that the challenger...challenged.
#
# Returns 1 if the character is in combat, and 0 otherwise.
sub doEitherCharactersHaveActiveBattle {
	my $challenger = $_[0];
	my $challenged = $_[1];
	
	my @params = ( $challenger, $challenger, $challenged, $challenged, $Battle_Completed );
	my $result = GrayscalePerspective::DAL::execute_single_row_hashref("SELECT 1 ActiveBattle FROM Battle_Active WHERE ( (Challenger = ? or Challenged = ?) or (Challenger = ? or Challenged = ?) ) AND Status <> ?", \@params);
	return _checkActiveBattleHash($result);
}

# takeTurn()
#
# Initiates the turn for a particular character. This function checks the specified battle is currently active and valid. It also checks if it is actually
# the specified "characters" turn, and if so, we do the damage, save the character stats and update the battle log. Finally, this function checks the battle
# parameters and ends the battle if necessary.
#
# $_[0] = Battle Id - The id of the battle to initiate the turn.
# $_[1] = Character - The character object taking the turn against an opponent. It must be the object, not the id.
# $_[2] = Opponent - The character on the receiving end of the attack. It must be an object, not an id of a character.
# $_[4] = Message - The message sent by the attacker. Will be added to the battle log.
#
# Does not return any value.
sub takeTurn {
	my $battleid  = $_[0];
	my $character = $_[1];
	my $opponent  = $_[2];
	my $message   = $_[3];
	
	#First check if the given character can execute a turn.	
	my $status = _checkBattleStatus( $battleid );
	
	if( defined ( $status ) and $status != 1 ) {
		my @params = ( $battleid );
		my $lastcharacteraction = GrayscalePerspective::DAL::execute_scalar("SELECT Battle_GetLastCharacterIdAction(?)", \@params);
		if ( defined ( $lastcharacteraction ) and $lastcharacteraction != $character->getId() ) {
			#initiate turn			
			$character->load();
			my $physicaldamage = _getPhysicalDamage( $character, $opponent );
			my $magicaldamage = _getMagicalDamage( $character, $opponent );
			my $criticalhit = _getCriticalHitModifier( $character );
			
			my $damage = (_getDamage($character, $opponent, "Attack")) * $criticalhit;
			
			$opponent->getStatCollection()->getStat("HP")->damage($damage);
			$opponent->save();
			
			my $actionmessage = _generateActionMessage( $character, $opponent, $damage, $criticalhit );
			
			_saveBattleLog($battleid, $character->getId(), $actionmessage, $character->getName() . " says $message" );			
			_checkBattleParameters($battleid, $character, $opponent);
		}
		else {
			print "You already took your turn! No Cheating!";
		}
	}
	else {
		print "This battle is already completed: $battleid ";
	}
}

# getOpponentCharacterObject() - Gets the id of the opponent for a specified character.
#
# $_[0] - The character id to get the opponent for.
#
# Returns the id of the character representing the opponent if it succeeds, otherwise it returns 0
sub getOpponentCharacterObject {
	my $characterid = $_[0];
	
	my @params = ( $characterid );
	my $opponentid = GrayscalePerspective::DAL::execute_scalar("SELECT Battle_GetOpponent(?)", \@params);
	
	if( defined ( $opponentid ) ) {
		my $opponentobject = new GrayscalePerspective::Character( $opponentid, 1 );
		return $opponentobject;
	}
	
	return 0;
}

# getBattleLog() - Gets the battle message for a particular battle. It automatically orders in descending order.
#
# $_[0] = The id of the battle to get the battle log messages.
#
# Returns the array reference of the battle log hashes.
sub getBattleLog {
	my $battleid     = $_[0];
	
	my @params = ( $battleid );
	my $result = GrayscalePerspective::DAL::execute_table_arrayref("SELECT (SELECT Name FROM Battle_Character WHERE Id = BL.CharacterId) Name, ActionMessage, CharacterMessage 
	FROM Battle_Log BL
	WHERE BattleId = ?
	ORDER BY BL.Id DESC;", \@params);
	
	my @logs_raw = @{$result};
	my @logs = ();
	
	foreach my $log (@logs_raw) {
		my %loghash;
		my $charactername;

		$loghash{Name}             = $log->{Name};
		$loghash{ActionMessage}    = $log->{ActionMessage};
		$loghash{CharacterMessage} = $log->{CharacterMessage};
		
		push(@logs, \%loghash);
	}
	
	return \@logs;
}

# _checkActiveBattleHash() - A utility method to read back the scalar value for an active battle. Ideally DAL should have an execute scalar function.
#
# $_[0] the result that comes back from the DAL
#
# Returns 1 if the hash is defined and contains a value for ActiveBattle, 0 otherwise.
sub _checkActiveBattleHash {
	my $result = $_[0];
	if ( defined $result and (ref ( $result ) eq 'HASH' ) ) {
		my %resulthash = %{$result};
		if ( defined $resulthash{ActiveBattle} ) {
			return 1;
		}
	}
	return 0;
}

# _updateBattleStatus() - Updates the battle with the specified status.
#
# $_[0] = Battle Id - The id of the battle to update.
# $_[1] = Status    - The status to update the battle to. It should be within the constraints of the specified values at the top of this file.
#
# Returns no value.
sub _updateBattleStatus {
	my $battleid = $_[0];
	my $status   = $_[1];
	
	my @params = ( $status, $battleid );
	my $result = GrayscalePerspective::DAL::execute_query("UPDATE Battle_Active SET Status = ? WHERE Id = ?", \@params);
}

# _saveBattleLog() - Saves a record to the battle log table with the specified parameters.
#
# $_[0] = Battle Id         - The id of the battle to update.
# $_[1] = characterid       - The id of the character activating the update. 
# $_[2] = action message    - The system message based on earlier events. Typically an initiation message, damage message, or victory message.
# $_[3] = character message - The message sent by the character during this turn.
# Returns no value.
sub _saveBattleLog {
	my $battleid         = $_[0];
	my $characterid      = $_[1];
	my $actionmessage    = $_[2];
	my $charactermessage = $_[3];
	
	my @params = ( $battleid, $characterid, $actionmessage, $charactermessage );
	my $result = GrayscalePerspective::DAL::execute_query("INSERT INTO Battle_Log(BattleId, CharacterId, ActionMessage, CharacterMessage) VALUES(?, ?, ?, ?)", \@params);
}

# _endBattle()
#
# Ends the battle. By this point, conditions to end the battle has already been met. Updates the battle log and battle status.
#
# $_[0] = Battle Id - The id of the battle to update.
# $_[1] = Winner - The character object that won the battle.
#
# Returns no value.
sub _endBattle {
	my $battleid = $_[0];
	my $winner   = $_[1];
	my $loser    = $_[2];
	
	my $exp = _getRewardEXP( $winner, $loser );
	_awardEXP($winner, $exp);
	_saveBattleLog( $battleid, $winner->getId(), "Battle ended, and the victory goes to " . $winner->getName() . ", and they earned $exp points!", "");
	_updateBattleStatus( $battleid, $Battle_Completed );
}

# _getRewardEXP() - Gets the amount of exp for the winner. It's based on the level difference of characters and the formula x^2 + 15.
#
# $_[0] = The character object that won the battle.
# $_[1] = The character object that lost the battle.
#
# Returns the amount of exp to award the winner.
sub _getRewardEXP {
	my $winner = $_[0];
	my $loser = $_[1];
	
	my $leveldiff = $winner->getLevel() - $loser->getLevel();
	my $exp = ($winner->getLevel * 10) - ($leveldiff * $winner->getLevel() * 10);
	if( $exp <= 0 ) {
		$exp = 1;
	}
	
	return $exp;
}

# _awardEXP() - 
# 
# Awards the given character an EXP amount. If the current exp - awarded exp remains above zero, no Level up occurs. 
# If the current exp - awarded exp goes below zero, then the character levels up. 
# In this case, we find the amount for the next level up and add back the negative amount from before.
# In the case that the exp is still negative, we keep going in a loop until the characters exp remains above 0. 
#
# $_[0] = The character object to award the EXP to
# $_[1] = The amount of exp to award.
sub _awardEXP {
	my $character = $_[0];
	my $exp = $_[1];
	
	my $currentexp = $character->getEXP();
	$currentexp = $currentexp - $exp;
	
	if( $currentexp <= 0 ) { #Level Up! Wooo!
		while ( $currentexp <= 0 ) {
			my $nextlevel = $character->getLevel() + 1;
			my $nextexp = (($nextlevel ** 2) + 15) + $currentexp;			
			$character->setEXP($nextexp);
			$character->LevelUp(); #LevelUp calls save.
			
			$currentexp = $nextexp;
		}
	}
	else {
		$character->setEXP($currentexp);
		$character->save();
	}
}

# _areCharactersBattlingEachOther() - Checks to see if the given character ids are battling each other in an active battle.
#
# $_[0] - The first id of a character to check
# $_[1] - The second id of a character to check
#
# Returns the battle id if the two characters are in an active battle, false otherwise.
sub _areCharactersBattlingEachOther {
	my $characterid      = $_[0];
	my $othercharacterid = $_[1];
	
	my @params = ($characterid, $othercharacterid, $othercharacterid, $characterid, $Battle_Completed);
	
	my $result = GrayscalePerspective::DAL::execute_scalar("SELECT Id FROM Battle_Active 
															WHERE ( (Challenger = ? AND Challenged = ?) 
															OR (Challenger = ? AND Challenged = ? ) ) 
															AND Status <> ?;", \@params);
	
	$result = $result || 0; #if nothing was returned, return a false value
	
	return $result;
}

# _checkBattleParameters()
#
# Checks the battle parameters as needed, typically at the end of a turn. This function checks if the HP of any character in the battle has been depleted.
# Based on this, it selects a winner with the depleted HP, and ends the battle.
#
# $_[0] = Battle Id - The id of the battle to update.
# $_[1] = Character - The character object taking the turn against an opponent. It must be the object, not the id.
# $_[2] = Opponent - The character on the receiving end of the attack. It must be an object, not an id of a character.
#
# It wil return the $Battle_Completed status if the battle is over, otherwise it returns undef.
sub _checkBattleParameters {
	my $battleid       = $_[0];
	my $character      = $_[1];
	my $opponent       = $_[2];
	
	my $winner = undef;
	my $loser = undef;
	
	if ( $character->isHealthZero() ) {
		$winner = $opponent;
		$loser = $character;
	}
	elsif ( $opponent->isHealthZero() ) {
		$winner = $character;
		$loser = $opponent;
	}
	
	if( defined ( $winner ) ) {
		_endBattle ( $battleid, $winner, $loser );
		return $Battle_Completed;
	}
	
	return undef;
}

# _checkBattleStatus() - Checks and returns the current status of the specified battle from the Database.
#
# $_[0] = Battle Id - The id of the battle to update.
#
# Returns the status of the battle.
sub _checkBattleStatus {
	my $battleid       = $_[0];
	
	my @params = ( $battleid );
	my $battle_in_progress = GrayscalePerspective::DAL::execute_scalar("SELECT Status FROM Battle_Active WHERE Id = ?", \@params);
	
	return $battle_in_progress;
}

sub _getDamage {
	my $character = $_[0];
	my $opponent  = $_[1];
	my $skill     = $_[2];
	
	my $damage;
	my $formula  = $character->getClass()->getSkillFormula($skill);
	my %stathash = %{$character->getStatCollection()->getStatHash()};
	my %oppstathash = %{$opponent->getStatCollection()->getStatHash()};
	
	while ( my ( $key, $value) = each %stathash ) {
		my $statvalue = $value->getCurrentValue();
		my $oppstatvalue = $oppstathash{$key}->getCurrentValue();
		
		my $keyreplace = "[P_$key]";
		my $oppkeyreplace = "[O_$key]";
		$formula =~ s/\Q$keyreplace/$statvalue/g;
		$formula =~ s/\Q$oppkeyreplace/$oppstatvalue/g;
	}
	
	$damage = eval $formula;
	return $damage;
}

# _getPhysicalDamage() - Gets the amount of physical damage done by the attacker.
#
# $_[0] = Character - The character object taking the turn against an opponent. It must be the object, not the id.
# $_[1] = Opponent - The character on the receiving end of the attack. It must be an object, not an id of a character.
#
# Returns the damage amount based on physical stats
sub _getPhysicalDamage {
	my $character = $_[0];
	my $opponent  = $_[1];

	my $physicaldamage = $character->getStatCollection()->getStat("STR")->getCurrentValue() - $opponent->getStatCollection()->getStat("DEF")->getCurrentValue();
	
	if($physicaldamage <= 0 ) {
		$physicaldamage = 0;
	}
	return $physicaldamage;
}

# _getMagicalDamage() - Gets the amount of magical damage done by the attacker.
#
# $_[0] = Character - The character object taking the turn against an opponent. It must be the object, not the id.
# $_[1] = Opponent - The character on the receiving end of the attack. It must be an object, not an id of a character.
#
# Returns the damage amount based on magical stats
sub _getMagicalDamage {
	my $character = $_[0];
	my $opponent  = $_[1];
	
	my $magicaldamage = $character->getStatCollection()->getStat("MAG")->getCurrentValue() - $opponent->getStatCollection()->getStat("MDEF")->getCurrentValue();
	
	if($magicaldamage <= 0 ) {
		$magicaldamage = 0;
	}
	return $magicaldamage;
}

# _getCriticalHitModifier()
# 
# Gets critical hit modifier. It's based on the characters dexterity. Once the critical hit rate is received, we generate
# a random number to check against it.
#
# $_[0] = Character - The character object taking the turn against an opponent. It must be the object, not the id.
#
# Returns 2 if it's a critical hit, 1 otherwise. It's a modifier, so 2 doubles the damage.
sub _getCriticalHitModifier {
	my $character = $_[0];
	my $chr       = $character->getCriticalHitRate();
	
	my $n = rand();
	
	if ( $n <= $chr ) {
		return 2;
	}
	return 1;
}

# _getCriticalHitModifier() - Generates the action message for the battle log. Bases itself on the damage, characters, and whether or not it was a critical hit.
#
# $_[0] = Character - The character object taking the turn against an opponent. It must be the object, not the id.
# $_[1] = Opponent - The character on the receiving end of the attack. It must be an object, not an id of a character.
# $_[2] = Damage - The damage done by the character in this turn.
# $_[3] = ch - The critical hit modifier. If it's 1, then there was no critical hit.
#
# Returns the joined message based on the given parameters.
sub _generateActionMessage {
	my $character = $_[0];
	my $opponent  = $_[1];
	my $damage    = $_[2];
	my $ch        = $_[3];
	my $message = "";
	
	if ( $ch != 1 ) {
		$message = "Critical Hit! ";
	}
	$message = ( $message || "") . $character->getName() . " did $damage points of damage to " . $opponent->getName();

	return $message;
}