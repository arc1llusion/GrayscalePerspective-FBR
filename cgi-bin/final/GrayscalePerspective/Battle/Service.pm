package GrayscalePerspective::Battle::Service;

# Service.pm
# This module will facilitate all external methods for the Battle system. Things like getting collections of data as well as facilitating the actual
# flow of Battle. Creating, actions, and ending the battle and maintaining the exp and other such ideas.

# Battle Status Meanings
# 1 - Completed
# 2 - Initiated
# 3 - In Progress

use GrayscalePerspective::DAL;
use GrayscalePerspective::Battle::Class;

use base Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(getAllClasses initiateBattle doesCharacterHaveActiveBattle doEitherCharactersHaveActiveBattle);

my ( $Battle_Completed, $Battle_Initiated, $Battle_InProgress) = (1, 2, 3);

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

sub initiateBattle {
	my $challenger = $_[0];
	my $challenged = $_[1];
	
	if($challenger == $challenged) {
		return "You cannot challenge yourself!"; 
	}
	
	if ( doEitherCharactersHaveActiveBattle( $challenger, $challenged) == 1 ) {
		return "You or your opponent are currently already enganged in combat.";
	}
	
	my @params = ( $challenger, $challenged, $Battle_Initiated );
	my $result = GrayscalePerspective::DAL::execute_query("INSERT INTO Battle_Active(Challenger, Challenged, Status) VALUES(?, ?, ?);", \@params);
	return 1;
}

sub doesCharacterHaveActiveBattle {
	my $singlecharacter = $_[0];
	
	my @params = ( $singlecharacter, $singlecharacter, $Battle_Compelted );
	my $result = GrayscalePerspective::DAL::execute_single_row_hashref("SELECT 1 ActiveBattle FROM Battle_Active WHERE (Challenger = ? or Challenged = ?) AND Status <> ?", \@params);
	return _checkActiveBattleHash($result);
}

sub doEitherCharactersHaveActiveBattle {
	my $challenger = $_[0];
	my $challenged = $_[1];
	
	my @params = ( $challenger, $challenger, $challenged, $challenged, $Battle_Completed );
	my $result = GrayscalePerspective::DAL::execute_single_row_hashref("SELECT 1 ActiveBattle FROM Battle_Active WHERE ( (Challenger = ? or Challenged = ?) or (Challenger = ? or Challenged = ?) ) AND Status <> ?", \@params);
	return _checkActiveBattleHash($result);
}




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