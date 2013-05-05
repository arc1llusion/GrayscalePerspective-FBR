package GrayscalePerspective::Battle::Service;

# Service.pm
# This module will facilitate all external methods for the Battle system. Things like getting collections of data as well as facilitating the actual
# flow of Battle. Creating, actions, and ending the battle and maintaining the exp and other such ideas.

# Battle Status Meanings
# 1 - Completed
# 2 - Initiated
# 3 - In Progress

use GrayscalePerspective::DAL;
use GrayscalePerspective::Battle::Character;
use GrayscalePerspective::Battle::Class;

use base Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(getAllClasses initiateBattle doesCharacterHaveActiveBattle doEitherCharactersHaveActiveBattle takeTurn);

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
	
	foreach $class (@classes_raw) {
		my $temp = new GrayscalePerspective::Class($class->{Id}, 1);
		
		push(@classes, $temp);
	}
	
	return \@classes;
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
	
	if($challenger == $challenged) {
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
	
	return undef;
}

# doesCharacterHaveActiveBattle() - Checks to see if a character is already in battle. It checks the database if the character is in a battle with
# status != $Battle_Completed, either challenger or challenged, if so then they are available for a new battle.
#
# $_[0] = The character to check if they are in combat.
#
# Returns 1 if the character is in combat, and 0 otherwise.
sub doesCharacterHaveActiveBattle {
	my $singlecharacter = $_[0];
	
	my @params = ( $singlecharacter, $singlecharacter, $Battle_Compelted );
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
			my $physicaldamage = $character->getStatCollection()->getSTR()->getCurrentValue() - $opponent->getStatCollection()->getDEF()->getCurrentValue();
			my $magicaldamage = $character->getStatCollection()->getMAG()->getCurrentValue() - $opponent->getStatCollection()->getMDEF()->getCurrentValue();
			
			if($physicaldamage <= 0 ) {
				$physicaldamage = 0;
			}
			
			if($magicaldamage <= 0 ) {
				$magicaldamage = 0;
			}
			
			my $damage = $physicaldamage + $magicaldamage;
			
			$opponent->getStatCollection()->getHP()->damage($damage);
			$opponent->save();
			
			_saveBattleLog($battleid, $character->getId(), $character->getName() . " did $damage points of damage to " . $opponent->getName(), $character->getName() . " says $message" );
			
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