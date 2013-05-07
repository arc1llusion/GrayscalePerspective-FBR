#!/usr/bin/perl

# Skill.pm
#
# The class module represents the data needed to represent a skill.
package GrayscalePerspective::Skill;

use GrayscalePerspective::DAL;

sub new
{
    my $class = shift;
    my $self = {
        _id          => shift,
		_name        => undef,
		_formula     => undef,
		_mp          => undef,
		_accuracy    => undef
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
	
	$self->loadFromHashRef(GrayscalePerspective::DAL::execute_single_row_hashref("SELECT * FROM Battle_Skill WHERE Id = ?;", \@params));
	return $self;
}

sub loadFromHashRef {
	my ( $self, $hr ) = @_;
	if ( defined ( $hr ) and $hr != 0 ) {
		my %skillhash = %{$hr};
		
		$self->{_id} = $skillhash{Id};
		$self->{_name} = $skillhash{Name};
		$self->{_formula} = $skillhash{Formula};
		$self->{_mp} = $skillhash{MP};
		$self->{_accuracy} = $skillhash{Accuracy};
	}
}

sub saveToHashRef {
	my ( $self, $skillhash ) = @_;
	
	if ( defined ( $skillhash ) and ref ( $skillhash ) eq 'HASH' ) {
		$skillhash->{Id} = $self->{_id};
		$skillhash->{Name} = $self->{_name};
		$skillhash->{Formula} = $self->{_formula};
		$skillhash->{MP} = $self->{_mp};
		$skillhash->{Accuracy} = $self->{_accuracy};
	}
}

sub getId {
	my ( $self ) = @_;
	return $self->{_id};
}

sub getName {
	my ( $self ) = @_;
	return $self->{_name};
}

sub getFormula {
	my ( $self ) = @_;
	return $self->{_formula};
}

sub getMP {
	my ( $self ) = @_;
	return $self->{_mp};
}

sub getAccuracy {
	my ( $self ) = @_;
	return $self->{_accuracy};
}

1;