#!/usr/bin/perl 

# UserProfile.pm
# This module is the profile of a user. Right now it is simple, but is intended to separate the system data needed for the user and the personal data of a user.
# This could be extended to include instant messaging fields, phone number, etc.

package GrayscalePerspective::User_Profile;

use GrayscalePerspective::DAL;

# The user profile object constructor. To set the instance members, use the respective accessor/mutator methods.
#
# $_[0] = The id of the object represented in the database. 
# $_[1] = A true/false [1/0] value representing whether or not to immediately load the data from the database based on the passed in id.
# 
# Returns the newly constructed or loaded object
sub new
{
    my $class = shift;
    my $self = {
        _userid        => shift,
		_firstname     => undef,
		_lastname      => undef,
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
	my @params = ($self->{_userid});
	my %result = %{GrayscalePerspective::DAL::execute_single_row_hashref("SELECT * FROM User_Profile WHERE UserId = ?", \@params)};

	$self->{_firstname} = $result{FirstName};
	$self->{_lastname} =  $result{LastName};
}

sub save {
	my ( $self, $newuser ) = @_;
	
	if( defined $newuser and $newuser == 1) {	
		my @params = ( $self->{_userid}, $self->{_firstname}, $self->{_lastname} );
		GrayscalePerspective::DAL::execute_query("INSERT INTO User_Profile(UserId, FirstName, LastName) Values(?, ?, ?)", \@params);
	}
	else {	
		my @params = ( $self->{_firstname}, $self->{_lastname}, $self->{_userid} );
		GrayscalePerspective::DAL::execute_query("UPDATE User_Profile SET FirstName = ?, LastName = ? WHERE UserId = ?", \@params);
	}
}

sub setFirstName {
    my ( $self, $firstName ) = @_;
    $self->{_firstname} = $firstName if defined($firstName);
    return $self->{_firstname};
}

sub getFirstName {
    my( $self ) = @_;
	
    return $self->{_firstname};
}

sub setLastName {
    my ( $self, $lastname ) = @_;
    $self->{_lastname} = $lastname if defined($lastname);
    return $self->{_lastname};
}

sub getLastName {
    my( $self ) = @_;
	
    return $self->{_lastname};
}

1;