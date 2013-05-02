package GrayscalePerspective::User;

use strict;
use warnings;

#Author: Jared Germano

#First version will contain basic checking of username and passwords as 
#well as basic manipulations to update user profile areas.

sub new {

	my $class = @_;
	my $self = {};
	$self->{Id} = undef;
	$self->{Username} = undef;
	$self->{Password} = undef;
	$self->{Email} = undef;
	$self->{JoinDate} = undef;

	return bless($self, $class);
}

sub IsValidUser {
	my $this = @_;
	
	print $username->{Username} . " and your password is " . $this->{$Password};
}

1;
