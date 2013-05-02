#!/usr/bin/perl
package GrayscalePerspective::AttributePair;

# AttributePair.pm
#
# The AttributePair object represents a value that can have a different current value than its max value.
# A common example are the health points. When dealt damage, the health of a character goes down, but its max remains.
# This module also handles cases that wouldn't make sense such as a current value less than 0, or a current value greater than the max value.

sub new
{
    my $class = shift;
    my $self = {
		_maxValue     => shift,
		_currentValue => shift
    };
	

    bless $self, $class;
	
	if( not defined $self->{_currentValue} ) {
		$self->{_currentValue} = $self->{_maxValue};
	}
	
    return $self;
}

sub getCurrentValue {
	my ( $self ) = @_;
	return $self->{_currentValue};
}

sub getMaximumValue {
	my ( $self ) = @_;
	return $self->{_maxValue};
}

sub heal {
	my ( $self, $amount ) = @_;
	$self->{_currentValue} = $self->{_currentValue} + $amount;
	$self->_normalize();
	
	return $self->{_currentValue};
}

sub damage {
	my ( $self, $amount ) = @_;
	$self->{_currentValue} = $self->{_currentValue} - $amount;
	$self->_normalize();
	
	return $self->{_currentValue};
}

sub setCurrent {
	my ( $self, $value ) = @_;
	$self->{_currentValue} = $value;
	$self->_normalize();
	
	return $self->{_currentValue};
}

sub setMaximum {
	my ( $self, $amount ) = @_;
	$self->{_maxValue} = $amount;
	$self->_normalize();
	
	return $self->{_currentValue};
}

sub _normalize {
	if($self->{_maxValue} < $self->{_currentValue}) {
		$self->{_currentValue} = $self->{_maxValue};
	}
	
	if($self->{_currentValue} < 0) {
		$self->{_currentValue} = 0;
	}
}

1;