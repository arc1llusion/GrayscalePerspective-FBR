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
our @EXPORT = qw(getAllClasses initiateBattle doesCharacterHaveActiveBattle doEitherCharactersHaveActiveBattle);

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
	
	if($challenger == $challenged) {
		return "You cannot challenge yourself!"; 
	}
	
	if ( doEitherCharactersHaveActiveBattle( $challenger, $challenged) == 1 ) {
		return "You or your opponent are currently already enganged in combat.";
	}
	
	my @params = ( $challenger, $challenged );
	my $result = GrayscalePerspective::DAL::execute_query("call Battle_Initiate(?, ?);", \@params);
	
	@params = ( $challenger, $challenged, $Battle_Completed );
	my $battleid = GrayscalePerspective::DAL::execute_scalar("SELECT Id FROM Battle_Active WHERE (Challenger = ? and Challenged = ?) AND Status <> ?", \@params);
	
	return $battleid;
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
			my $damage = $character->getStatCollection()->getSTR()->getCurrentValue() - $opponent->getStatCollection()->getDEF()->getCurrentValue();
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
	my $winner = $_[1];
	
	_saveBattleLog( $battleid, $winner->getId(), "Battle ended, and the victory goes to " . $winner->getName() . "!", "");
	_updateBattleStatus( $battleid, $Battle_Completed );
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
# It wil return the $Battle_Completed status if the battle is over, otherwise it returns nothing.
sub _checkBattleParameters {
	my $battleid       = $_[0];
	my $character      = $_[1];
	my $opponent       = $_[2];
	
	my $winner = undef;
	if ( $character->getStatCollection()->getHP()->getCurrentValue() <= 0 ) {
		$winner = $opponent;
	}
	elsif ( $opponent->getStatCollection()->getHP()->getCurrentValue()  <= 0 ) {
		$winner = $character;
	}
	
	if( defined ( $winner ) ) {
		_endBattle ( $battleid, $winner );
		return $Battle_Completed;
	}
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