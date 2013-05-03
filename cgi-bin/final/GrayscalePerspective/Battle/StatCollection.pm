#!/usr/bin/perl
package GrayscalePerspective::StatCollection;

use GrayscalePerspective::Battle::AttributePair;

# StatCollection.pm
#
# This module is not tied to a database but rather is the flattened collection of stats so that various objects do not need to be modified if a new stat is added later.
# It instantiates AttributePair objects for each stat. The object allows for initializing via the constructor and also a hashref from the database.

sub new
{
    my $class = shift;
    my $self = {
        _hp          => undef,
		_mp          => undef,
		_str         => undef,
		_def         => undef,
		_mag         => undef,
		_mdef        => undef,
		_dex         => undef
    };
	
	my ( $hp, $mp, $str, $def, $mag, $mdef, $dex ) = @_;
	
	$self->{_hp}   = new GrayscalePerspective::AttributePair( $hp   ) unless not defined $hp;
	$self->{_mp}   = new GrayscalePerspective::AttributePair( $mp   ) unless not defined $mp;
	$self->{_str}  = new GrayscalePerspective::AttributePair( $str  ) unless not defined $str;
	$self->{_def}  = new GrayscalePerspective::AttributePair( $def  ) unless not defined $def;
	$self->{_mag}  = new GrayscalePerspective::AttributePair( $mag  ) unless not defined $mag;
	$self->{_mdef} = new GrayscalePerspective::AttributePair( $mdef ) unless not defined $mdef;
	$self->{_dex}  = new GrayscalePerspective::AttributePair( $dex  ) unless not defined $dex;

    bless $self, $class;
	
    return $self;
}

sub loadFromHashRef {
	my ( $self, $hashref ) = @_;
	
	if ( defined $hashref and ( ref ( $hashref ) eq "HASH" ) ) {
		my %statcol = %{$hashref};
		
		$self->{_hp}   = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{HP} ) ) ) unless not defined $statcol{HP};
		$self->{_mp}   = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{MP} ) ) ) unless not defined $statcol{MP};
		$self->{_str}  = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{STR} ) ) ) unless not defined $statcol{STR};
		$self->{_def}  = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{DEF} ) ) ) unless not defined $statcol{DEF};
		$self->{_mag}  = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{MAG} ) ) ) unless not defined $statcol{MAG};
		$self->{_mdef} = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{MDEF} ) ) ) unless not defined $statcol{MDEF};
		$self->{_dex}  = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{DEX} ) ) ) unless not defined $statcol{DEX};
	}
	else {
		print "Stat Collection hashref was invalid.";
	}
}

sub saveCurrentValuesToHashRef {
	my ( $self, $hashref ) = @_;
	
		if ( defined $hashref and ( ref ( $hashref ) eq "HASH" ) ) {
			
			$hashref->{HP} = $self->{_hp}->getCurrentValue();
			$hashref->{MP} = $self->{_mp}->getCurrentValue();
			$hashref->{STR} = $self->{_str}->getCurrentValue();
			$hashref->{DEF} = $self->{_def}->getCurrentValue();
			$hashref->{MAG} = $self->{_mag}->getCurrentValue();
			$hashref->{MDEF} = $self->{_mdef}->getCurrentValue();
			$hashref->{DEX} = $self->{_def}->getCurrentValue();
			
			return $hashref;
		}
	return $hashref;
}

sub getHP {
	my ( $self ) = @_;
	return $self->{_hp};
}

sub getMP {
	my ( $self ) = @_;
	return $self->{_mp};
}

sub getSTR {
	my ( $self ) = @_;
	return $self->{_str};
}

sub getDEF {
	my ( $self ) = @_;
	return $self->{_def};
}

sub getMAG {
	my ( $self ) = @_;
	return $self->{_mag};
}

sub getMDEF {
	my ( $self ) = @_;
	return $self->{_mdef};
}

sub getDEX {
	my ( $self ) = @_;
	return $self->{_dex};
}

1;