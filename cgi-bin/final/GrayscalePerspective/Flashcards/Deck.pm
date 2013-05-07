#!/usr/bin/perl 

# Deck.pm
# The Deck object represents a flashcard deck. When loaded, it loads and populates the flashcard objects it contains as well.

package GrayscalePerspective::Deck;
use GrayscalePerspective::DAL;
use GrayscalePerspective::Flashcards::Flashcard;

# The deck object constructor. To set the instance members, use the respective accessor/mutator methods.
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
		_title         => undef,
		_createdby     => undef,
		_createddate   => undef,
		_categoryid    => undef,
		_flaschards    => undef
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
	my $result = GrayscalePerspective::DAL::execute_single_row_hashref("SELECT * FROM Deck WHERE Id = ?", \@params);
	$self->loadFromHashref($result);
}

sub loadFromHashref {
	my ( $self, $hashref ) = @_;
	my %result = %{$hashref};
	my @params = ($self->{_id});
	
	$self->{_id}          = $result{Id};
	$self->{_title}       = $result{Title};
	$self->{_createdby}   = $result{CreatedBy};
	$self->{_createddate} = $result{CreatedDate};
	$self->{_categoryid}  = $result{CategoryId};
	
	my @flashcards_raw = @{GrayscalePerspective::DAL::execute_table_arrayref("SELECT FC.Id Id, FC.DeckId, FC.Question, FC.Answer, FR.Attempts, FR.Correct FROM Flashcard FC
																		LEFT JOIN FlashcardResult FR ON FC.Id = FR.FlashcardId
																		WHERE FC.DeckId = ?;", \@params)};
	my @flashcards = ();
	
	foreach $card (@flashcards_raw) {
		my $temp = new GrayscalePerspective::Flashcard();
		$temp->loadFromHashref($card);
		
		push(@flashcards, $temp);
	}
	
	$self->{_flashcards} = \@flashcards;
}

sub save {
	my ( $self ) = @_;
	
	if( not defined $self->{_id} ) {
		my @params = ( $self->{_title}, $self->{_createdby}, $self->{_categoryid} );
		GrayscalePerspective::DAL::execute_query("INSERT INTO Deck(Title, CreatedBy, CreatedDate, CategoryId) Values(?, ?, (SELECT CURRENT_TIMESTAMP), ?)", \@params);
	}
	else {	
		my @params = ( $self->{_title}, $self->{_categoryid}, $self->{_id} );
		GrayscalePerspective::DAL::execute_query("UPDATE Deck SET Title = ?, CategoryId = ? WHERE Id = ?", \@params);
	}
	
	#Save its corresponding flashcards
	if ( defined $self->{_flashcards} and ref($self->{_flashcards}) eq 'ARRAY') {
		my @cards = @{$self->{_flashcards}};
		foreach my $item (@cards) {
			$item->save();
		}
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

sub setCategoryId {
    my ( $self, $categoryid ) = @_;
    $self->{_categoryid} = $categoryid if defined($categoryid);
    return $self->{_categoryid};
}

sub getCategoryId {
	my ( $self ) = @_;
	return $self->{_categoryid};
}

sub setCreatedBy {
    my ( $self, $createdby ) = @_;
    $self->{_createdby} = $createdby if defined($createdby);
    return $self->{_createdby};
}

sub getCreatedBy {
	my ( $self ) = @_;
	return $self->{_createdby};
}

sub getFlashcards {
	my ( $self ) = @_;
	return $self->{_flashcards};
}

sub getHashRef{
	my ( $self ) = @_;
	
	my %deckhash;
	$deckhash{Id} = $self->{_id};
	$deckhash{Title} = $self->{_title};
	$deckhash{CreatedBy} = $self->{_createdby};
	$deckhash{CreatedDate} = $self->{_createddate};
	$deckhash{CategoryId} = $self->{_categoryid};
	
	return \%deckhash;
}

1;