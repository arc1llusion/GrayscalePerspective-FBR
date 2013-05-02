#!/usr/bin/perl 

# Flashcard.pm
# The flashcard object represents the data for a flashcard.

package GrayscalePerspective::Flashcard;
use GrayscalePerspective::DAL;

# The flashcard object constructor. To set the instance members, use the respective accessor/mutator methods.
#
# $_[0] = The id of the object represented in the database. 
# $_[1] = A true/false [1/0] value representing whether or not to immediately load the data from the database based on the passed in id.
# 
# Returns the newly constructed or loaded object
sub new
{
    my $class = shift;
    my $self = {
        _id            => shift,
		_deckid        => undef,
		_question      => undef,
		_answer        => undef
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
	my $result = GrayscalePerspective::DAL::execute_single_row_hashref("SELECT * FROM Flashcard WHERE Id = ?", \@params);
	$self->loadFromHashref($result);
}

sub loadFromHashref {
	my ( $self, $hashref ) = @_;
	my %result = %{$hashref};
	
	$self->{_id}       = $result{Id};
	$self->{_deckid}   = $result{DeckId};
	$self->{_question} = $result{Question};
	$self->{_answer}   = $result{Answer};
}

sub save {
	my ( $self ) = @_;
	
	if( not defined $self->{_id} ) {	
		my @params = ( $self->{_deckid},  $self->{_question}, $self->{_answer} );
		GrayscalePerspective::DAL::execute_query("INSERT INTO Flashcard(DeckId, Question, Answer) Values(?, ?, ?)", \@params);
	}
	else {	
		my @params = ( $self->{_deckid},  $self->{_question}, $self->{_answer}, $self->{_id} );
		GrayscalePerspective::DAL::execute_query("UPDATE Flashcard SET DeckId = ?, Question = ?, Answer= ? WHERE Id = ?", \@params);
	}
}

sub getId {
	my ( $self ) = @_;
	return $self->{_id};
}

sub setDeckId {
    my ( $self, $deckid ) = @_;
    $self->{_deckid} = $deckid if defined($deckid);
    return $self->{_deckid};
}

sub getDeckId {
	my ( $self ) = @_;
	return $self->{_deckid};
}

sub setQuestion {
    my ( $self, $question ) = @_;
    $self->{_question} = $question if defined($question);
    return $self->{_question};
}

sub getQuestion {
	my ( $self ) = @_;
	return $self->{_question};
}

sub setAnswer {
    my ( $self, $answer ) = @_;
    $self->{_answer} = $answer if defined($answer);
    return $self->{_answer};
}

sub getAnswer {
	my ( $self ) = @_;
	return $self->{_answer};
}

1;