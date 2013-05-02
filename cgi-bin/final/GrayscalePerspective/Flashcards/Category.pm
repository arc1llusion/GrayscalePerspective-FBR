#!/usr/bin/perl 

# Category.pm
# This module represents the flashcard deck category. This is intended to be used for easy sorting of different subjects for the cards.

package GrayscalePerspective::Category;
use GrayscalePerspective::DAL;

# The category object constructor. To set the instance members, use the respective accessor/mutator methods.
#
# $_[0] = The id of the object represented in the database. 
# $_[1] = A true/false [1/0] value representing whether or not to immediately load the data from the database based on the passed in id.
# 
# Returns the newly constructed or loaded object
sub new
{
    my $class = shift;
    my $self = {
        _id        => shift,
		_title     => undef
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
	my %result = %{GrayscalePerspective::DAL::execute_single_row_hashref("SELECT * FROM Category WHERE Id = ?", \@params)};

	$self->{_id}    = $result{Id};
	$self->{_title} = $result{Title};
}

sub save {
	my ( $self ) = @_;
	
	if( not defined $self->{_id} ) {	
		my @params = ( $self->{_title} );
		GrayscalePerspective::DAL::execute_query("INSERT INTO Category(Title) Values(?)", \@params);
	}
	else {	
		my @params = ( $self->{_title}, $self->{_id} );
		GrayscalePerspective::DAL::execute_query("UPDATE Category SET Title = ? WHERE Id = ?", \@params);
	}
}

sub setTitle {
    my ( $self, $title ) = @_;
    $self->{_title} = $title if defined($title);
    return $self->{_title};
}

sub getTitle {
	my ( $self ) = @_;
	return $self->{_title};
}

sub getHashRef{
	my ( $self ) = @_;
	
	my %cathash;
	$cathash{Id} = $self->{_id};
	$cathash{Title} = $self->{_title};
	
	return \%cathash;
}

1;