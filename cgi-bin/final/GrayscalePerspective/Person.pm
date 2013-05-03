#!/usr/bin/perl 

# User.pm
# The User object represents system data for the user. Things like password (encrypted), username and e-mail as well as user meta data like join date. 
# It also loads the user profile automatically.

package GrayscalePerspective::User;

use GrayscalePerspective::DAL;
use GrayscalePerspective::User_Profile;
use Crypt::SaltedHash;

#Battle Modules
use GrayscalePerspective::Battle::Character;

# The user object constructor. To set the instance members, use the respective accessor/mutator methods.
#
# $_[0] = The id of the object represented in the database. 
# $_[1] = A true/false [1/0] value representing whether or not to immediately load the data from the database based on the passed in id.
# 
# Returns the newly constructed or loaded object
sub new
{
    my $class = shift;
    my $self = {
        _id          => shift,
        _username    => undef,
        _email       => undef,
		_password    => undef,
		_salt        => undef,
		_joinDate    => undef,
		_userProfile => undef,
		
		_character   => undef
    };
	
	my $loadImmediate = shift;

    bless $self, $class;
	
	#If the loadImmediate parameter is set, then we save the user the hassle of having to call load on their own
	if($loadImmediate) {
		$self->load();
	}
		
    return $self;
}

# The load method will load the data based on the Id set in the object. It does not take parameters.
sub load { #The default is by Id. During normal operation after the user is logged in, this makes it easy. Although ideally it would be cached to prevent the db call
	my ( $self ) = @_;
	my @params = ($self->{_id});
	return $self->loadFromHashRef ( GrayscalePerspective::DAL::execute_single_row_hashref("SELECT * FROM User WHERE Id = ?", \@params) );
}

sub loadFromUsername {
	my ( $self ) = @_;
	my @params = ($self->{_username});
	return $self->loadFromHashRef ( GrayscalePerspective::DAL::execute_single_row_hashref("SELECT * FROM User WHERE Username = ?", \@params) );
}

sub loadFromEmail {
	my ( $self ) = @_;
	my @params = ($self->{_email});
	return $self->loadFromHashRef ( GrayscalePerspective::DAL::execute_single_row_hashref("SELECT * FROM User WHERE Email = ?", \@params) );
}

sub loadFromHashRef {
	my ( $self, $hashref ) = @_;
	
	if ( defined ( $hashref ) and $hashref != 0 ) {
		my %result = %{ $hashref };
	
		$self->{_id} = $result{Id};
		$self->{_username} = $result{Username};
		$self->{_email} =  $result{Email};
		$self->{_password} = $result{Password};
		$self->{_salt} = $result{Salt};
		$self->{_joinDate} = $result{JoinDate};
		
		my $userProfileObject = new GrayscalePerspective::User_Profile($self->{_id}, 1);
		$self->{_userProfile} = $userProfileObject;

		$self->{_character} = new GrayscalePerspective::Character( $self->getCharacterId(), 1 );
		
		return 1;
	}
	return 0;
}

# save( password )
# This method either saves an existing user if the instance id is defined, or creates a new record with the profile. Both must be defined when being called.
# 
# $_[0] = The password of the new user. If the user is existing, then it is ignored.
#
# Returns no value.
sub save {
	my ( $self, $password, $charactername, $classid ) = @_; #password, character, and class are only used for new users.
	
	if ( defined $self->{_id} ) {
		my @params = ( $self->{_username}, $self->{_email}, $self->{_id} );
		GrayscalePerspective::DAL::execute_query("UPDATE User SET Username = ?, Email = ? WHERE Id = ?", \@params);
		
		my $profile = $self->{_userProfile};
		$profile->save();
	}
	else {
		$self->setPassword($password);		
		my ( $userProfile ) = $self->{_userProfile};
		
		my ( $cname ) = $self->{_username};
		if ( defined $charactername ) {
			$cname = $charactername;
		}
		
		my @params = (  $self->{_username}, 
						$self->{_email}, 
						$self->{_password}, 
						$self->{_salt}, 
						$userProfile->getFirstName(), 
						$userProfile->getLastName(),
						$classid,
						$charactername || $self->{_username});
		
		my $result = GrayscalePerspective::DAL::execute_query("call User_Save( ?, ?, ?, ?, ?, ?, ?, ? )", \@params);		
		$self->loadFromUsername(); #DBD doesn't allow output parameters... So using a procedure I still can't eliminate all db calls.
	}
}

sub getId {
	my ( $self ) = @_;
	return $self->{_id};
}

sub setUsername {
    my ( $self, $firstName ) = @_;
    $self->{_username} = $firstName if defined($firstName);
    return $self->{_username};
}

sub getUsername {
    my( $self ) = @_;
	
    return $self->{_username};
}

sub setEmail {
    my ( $self, $email ) = @_;
    $self->{_email} = $email if defined($email);
    return $self->{_email};
}

sub getEmail {
    my( $self ) = @_;
	
    return $self->{_email};
}

sub getUserProfile {
	my ( $self ) = @_;
	return $self ->{_userProfile};
}

sub setUserProfile {
    my ( $self, $userProfile ) = @_;
    $self->{_userProfile} = $userProfile if defined($userProfile);
    return $self->{_userProfile};
}

sub setPassword {
	my ( $self, $password ) = @_;
	
	my $crypt = Crypt::SaltedHash->new(algorithm=>'SHA-256');
	$crypt->add($password);
	my $shash =$crypt->generate();
	my $salt = $crypt->salt_hex();
	
	$self->{_password} = $shash;
	$self->{_salt} = $salt;
}

sub setAndSavePassword {
	my ( $self, $password ) = @_;
	$self->setPassword( $password );
	
	my @params = ( $self->{_password}, $self->{_salt}, $self->{_id} );
	GrayscalePerspective::DAL::execute_query("UPDATE User SET Password = ?, Salt = ? WHERE Id = ?", \@params);
}

sub validatePassword {
	my ( $self, $password ) = @_;
	my $crypt = Crypt::SaltedHash->new(algorithm=>'SHA-256');
	
	my $verified=$crypt->validate($self->{_password}, $password);
	
	return $verified;
}

sub getCharacterId {
	my ( $self ) = @_;
	
	my @params = ( $self->{_id} );
	my %charid = %{GrayscalePerspective::DAL::execute_single_row_hashref("SELECT User_GetCharacterId( ? ) CharacterId", \@params)};
	
	return $charid{CharacterId};
}

sub getCharacter {
	my ( $self ) = @_;
	return $self->{_character};
}

1;