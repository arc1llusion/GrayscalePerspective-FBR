#!/usr/bin/perl

# Class.pm
#
# The class module represents the generic class data and description. It may be included to show the base stats of the class.
package GrayscalePerspective::Class;

use GrayscalePerspective::DAL;

sub new
{
    my $class = shift;
    my $self = {
        _id          => shift,
		_title       => undef,
		_description => undef
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
	
}

sub getId {
	my ( $self ) = @_;
	return $self->{_id};
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

sub setDescription {
    my ( $self, $description ) = @_;
    $self->{_description} = $description if defined($description);
    return $self->{_description};
}

sub getDescription {
	my ( $self ) = @_;
	return $self->{_description};
}

1;