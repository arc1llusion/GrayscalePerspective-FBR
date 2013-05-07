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
		_description => undef,
		_skillhash   => undef
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
	
	$self->loadFromHashRef(GrayscalePerspective::DAL::execute_single_row_hashref("SELECT * FROM Battle_Class WHERE Id = ?;", \@params));
	return $self;
}

sub loadFromHashRef {
	my ( $self, $hr ) = @_;
	
	if ( defined ( $hr ) and $hr != 0 ) {
		my %classhash = %{$hr};
		$self->{_id} = $classhash{Id};
		$self->{_title} = $classhash{Title};
		$self->{_description} = $classhash{Description};
		$self->loadClassSkills();
	}
}

sub loadClassSkills {
	my ( $self ) = @_;
	
	if ( defined ( $self->{_id} ) ) {
		my @params = ( $self->{_id} );
		my @skills = @{GrayscalePerspective::DAL::execute_table_arrayref("SELECT * FROM Battle_Skill WHERE ClassId = ?", \@params)};
		
		my $skillhash = {};
		
		foreach $skill (@skills) {
			$skillhash->{ $skill->{Name} } = $skill->{Formula};
		}
		
		$self->{_skillhash} = $skillhash;
	}
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

sub getSkillHash {
	my ( $self ) = @_;
	return $self->{_skillhash};
}

sub getSkillFormula {
	my ( $self, $skillname ) = @_;
	return $self->{_skillhash}->{$skillname};
}

1;