#!/usr/bin/perl

# Character.pm
#
# The character module maintains the chracter object and its data. It maintains the class object and also the stat collection for the character.
# It's responsible for getting the flattened stats from the database.

package GrayscalePerspective::Character;

use GrayscalePerspective::DAL;
use GrayscalePerspective::Battle::Class;
use GrayscalePerspective::Battle::StatCollection;

sub new
{
    my $class = shift;
    my $self = {
        _id          => shift,
		_class       => undef,
		_name        => undef,
		_level       => undef,
		
		#stats flattened into the object. At the data level it's well designed. Here though we don't need that kind of normalized design.
		_statcollection          => undef
		
		#TODO: Equipment
    };
	
	my $loadImmediate = shift;

    bless $self, $class;
	
	#If the loadImmediate parameter is set, then we save the user the hassle of having to call load on their own
	if($loadImmediate) {
		$self->load();
	}
		
    return $self;
}

sub load {
	my ( $self ) = @_;
	my @params = ($self->{_id});
	
	# Due to our outdated EVERYTHING, I had to call this without a procedure. This has made me quite unhappy.
	# We need DBD::mysql version 4, and we're running 3. I know I really can't complain since this is a basic class, though...
	$self->loadFromHashRef(GrayscalePerspective::DAL::execute_single_row_hashref("SELECT 
		BCH.*, 
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(1, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(1, BCH.ClassId, BCH.Level)) AS CHAR(10)))) HP, 
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(2, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(2, BCH.ClassId, BCH.Level)) AS CHAR(10)))) MP,
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(3, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(3, BCH.ClassId, BCH.Level)) AS CHAR(10)))) STR,
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(4, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(4, BCH.ClassId, BCH.Level)) AS CHAR(10)))) DEF,
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(5, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(5, BCH.ClassId, BCH.Level)) AS CHAR(10))))  MAG,
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(6, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(6, BCH.ClassId, BCH.Level)) AS CHAR(10))))  MDEF,
		( CONCAT(CAST( (SELECT Battle_GetCharacterStatValue(7, BCH.Id, BCH.Level)) AS CHAR(10)),',', CAST( (SELECT Battle_GetClassStatValue(7, BCH.ClassId, BCH.Level)) AS CHAR(10))))  DEX

		FROM Battle_Character BCH
		WHERE BCH.Id = ?;", \@params));
		
	return $self;
}

sub loadFromHashRef {
	my ( $self, $hr ) = @_;
	
	if ( defined ( $hr ) and $hr != 0 ) {
		my %result = %{$hr};
		$self->{_name} = $result{Name};
		$self->{_level} =  $result{Level};	
		
		$self->{_statcollection} = new GrayscalePerspective::StatCollection();
		$statcollectionobject = $self->{_statcollection};
		
		$statcollectionobject->loadFromHashRef($hr);
		
		$self->{_class} = new GrayscalePerspective::Class($result{ClassId}, 1);
	}
}

sub save {
	my ( $self ) = @_;
	my %savehash;
	
	if ( defined $self->{_id} ) {
		$savehash{Id} = $self->{_id};
		$savehash{ClassId} = $self->{_class}->getId();
		$savehash{Name} = $self->{_name};
		$self->{_statcollection}->saveCurrentValuesToHashRef( \%savehash );
		
		#while ( my ( $key, $value) = each %savehash ) {
			#print "$key and $value \n";
		#}
		
		my @params = 
		(
			$savehash{Id},
			$savehash{Name},
			$savehash{HP},
			$savehash{MP},
			$savehash{STR},
			$savehash{DEF},
			$savehash{MAG},
			$savehash{MDEF},
			$savehash{DEX}
		);
		
		#print join(',', @params);
		
		GrayscalePerspective::DAL::execute_query("call Battle_Character_Save(?, ?, ?, ?, ?, ?, ?, ?, ?);", \@params);
	}
}

sub getId {
	my ( $self ) = @_;
	return $self->{_id};
}

sub setClass {
    my ( $self, $class ) = @_;
    $self->{_class} = $class if defined($class);	
    return $self->{_class};
}

sub getClass {
    my( $self ) = @_;	
    return $self->{_class};
}

sub switchClassById {
	my ( $self, $classid ) = @_; 
}

sub isHealthZero {
	my ( $self ) = @_;
	if ( $self->getStatCollection()->getHP()->getCurrentValue <= 0 ) {
		return 1;
	}
	return 0;
}

sub setName {
    my ( $self, $name ) = @_;
    $self->{_name} = $name if defined($name);
    return $self->{_name};
}

sub getName {
    my( $self ) = @_;	
    return $self->{_name};
}

sub LevelUp {
	my ( $self ) = @_;
	if ( defined $self->{_id} ) {
		$self->save();
	
		my @params = ( $self->{_id} );
		$result = GrayscalePerspective::DAL::execute_query("call Battle_Character_LevelUp(?);", \@params);
		$self->load();
	}
}

sub getLevel {
    my( $self ) = @_;	
    return $self->{_level};
}

sub getStatCollection {
	my ( $self ) = @_;
	return $self->{_statcollection};
}

1;