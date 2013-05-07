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
		_stathash    => undef
    };
	
	my ( $hp, $mp, $str, $def, $mag, $mdef, $dex ) = @_;
	
	my $sthash = {};
	$sthash->{"HP"} = new GrayscalePerspective::AttributePair( $hp   ) unless not defined $hp;
	$sthash->{"MP"} = new GrayscalePerspective::AttributePair( $mp   ) unless not defined $mp;
	$sthash->{"STR"} = new GrayscalePerspective::AttributePair( $str   ) unless not defined $str;
	$sthash->{"DEF"} = new GrayscalePerspective::AttributePair( $def   ) unless not defined $def;
	$sthash->{"MAG"} = new GrayscalePerspective::AttributePair( $mag   ) unless not defined $mag;
	$sthash->{"MDEF"} = new GrayscalePerspective::AttributePair( $mdef   ) unless not defined $mdef;
	$sthash->{"DEX"} = new GrayscalePerspective::AttributePair( $dex   ) unless not defined $dex;
	$self->{_stathash} = $sthash;

    bless $self, $class;
	
    return $self;
}

sub loadFromHashRef {
	my ( $self, $hashref ) = @_;
	
	if ( defined $hashref and ( ref ( $hashref ) eq "HASH" ) ) {
		my %statcol = %{$hashref};
		
		my $sthash = {};
		$sthash->{"HP"}   = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{HP} ) )   ) unless not defined $statcol{HP};
		$sthash->{"MP"}   = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{MP} ) )   ) unless not defined $statcol{MP};
		$sthash->{"STR"}  = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{STR} ) )   ) unless not defined $statcol{STR};
		$sthash->{"DEF"}  = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{DEF} ) )   ) unless not defined $statcol{DEF};
		$sthash->{"MAG"}  = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{MAG} ) )   ) unless not defined $statcol{MAG};
		$sthash->{"MDEF"} = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{MDEF} ) )   ) unless not defined $statcol{MDEF};
		$sthash->{"DEX"}  = new GrayscalePerspective::AttributePair( reverse ( split(/,/, $statcol{DEX} ) )   ) unless not defined $statcol{DEX};
		$self->{_stathash} = $sthash;
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
			$hashref->{DEX} = $self->{_dex}->getCurrentValue();
			
			return $hashref;
		}
	return $hashref;
}

sub getStat {
	my ( $self, $statname ) = @_;
	return $self->{_stathash}->{$statname};
}

1;