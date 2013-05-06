#!/usr/bin/perl 

# FlaschardService.pm
# This module contains a variety of utility methods to make working with the flashcards easier.

package GrayscalePerspective::FlashcardService;
use GrayscalePerspective::DAL;

use GrayscalePerspective::Flashcards::Deck;

use base Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(getDecksByUser);

# getAllCategories() - Gets all the topic categories in the system.
#
# Takes no parameters.
#
# Returns an array reference with the list of category objects
sub getAllCategories {
	my @params = ();
	my @categories_raw = @{GrayscalePerspective::DAL::execute_table_arrayref("SELECT * FROM Category")};
	
	my @categories = ();
	
	foreach $cat (@categories_raw) {
		my $temp = new GrayscalePerspective::Category($cat->{Id}, 1);
		
		push(@categories, $temp);
	}
	
	return \@categories;
}

# getDecksByCategory( category_id )
# Gets the flashcard decks by the category.
#
# $_[0] = Category Id the list of decks belongs to.
#
# Returns an array reference with the list of deck objects
sub getDecksByCategory {
	my ( $dc_category ) = $_[0];
	my @params =( $dc_category );
	
	my @decks_raw = @{GrayscalePerspective::DAL::execute_table_arrayref("SELECT * FROM Deck WHERE CategoryId = ?", \@params)};
	my @decks = ();
	
	foreach $card (@decks_raw) {
		my $temp = new GrayscalePerspective::Deck();
		$temp->loadFromHashref($card);
		
		push(@decks, $temp);
	}
	
	return \@decks;
}

# getDecksByCategory( category_id, user_id )
# Gets the flashcard decks by the category AND the user id.
#
# $_[0] = Category Id the list of decks belongs to.
# $_[1] = The user id used to find the decks created by this user
#
# Returns an array reference with the list of deck objects
sub getDecksByCategoryAndUser {
	my ( $dc_category ) = $_[0];
	my ( $dc_user ) = $_[1];
	my @params =( $dc_category, $dc_user );
	
	my @decks_raw = @{GrayscalePerspective::DAL::execute_table_arrayref("SELECT * FROM Deck WHERE CategoryId = ? AND CreatedBy = ?", \@params)};
	my @decks = ();
	
	foreach $card (@decks_raw) {
		my $temp = new GrayscalePerspective::Deck();
		$temp->loadFromHashref($card);
		
		push(@decks, $temp);
	}
	
	return \@decks;
}

sub getFlashcardsByDeck {
	my ( $deckid ) = $_[0];
	my @params = ( $deckid );
	
	my @flashcards_raw = @{GrayscalePerspective::DAL::execute_table_arrayref("SELECT * FROM Flashcard WHERE DeckId = ?", \@params)};
	my @flashcards = ();
	
	foreach $flashcard (@flashcards_raw) {

		my $temp = new GrayscalePerspective::Flashcard();
		$temp->loadFromHashref($flashcard);
		
		push(@flashcards, $temp);
	}
	
	return \@flashcards;
}

# getDecksByUser( user_id )
# Gets the flashcard decks by the user id that created the decks.
#
# $_[0] = The user id used to find the decks created by this user
#
# Returns an array reference with the list of deck objects
sub getDecksByUser {
	my ( $dc_user ) = $_[0];
	my @params =( $dc_user );
	
	my @decks_raw = @{GrayscalePerspective::DAL::execute_table_arrayref("SELECT * FROM Deck WHERE CreatedBy = ?", \@params)};
	my @decks = ();
	
	foreach $card (@decks_raw) {
		my $temp = new GrayscalePerspective::Deck();
		$temp->loadFromHashref($card);
		
		push(@decks, $temp);
	}
	
	return \@decks;
}

# createDeck( CreatedBy, CategoryId, Title )
# Gets the flashcard decks by the category AND the user id.
#
# $_[0] = The id of the user that is creating the deck
# $_[1] = The id of the category that the deck is being assigned to
# $_[2] = The named title of the deck
#
# Returns the newly created Deck object
sub createDeck {
	my ( $createdby, $categoryid, $title ) = @_;
	
	my $deck = new GrayscalePerspective::Deck();
	$deck->setTitle($title);
	$deck->setCategoryId($categoryid);
	$deck->setCreatedBy($createdby);
	
	$deck->save();
	return $deck;
}

# createFlashcard( DeckId, Question, Answer )
# Gets the flashcard decks by the category AND the user id.
#
# $_[0] = The id of the deck that the flashcard is a part of
# $_[1] = The question for the flashcard
# $_[2] = The answer for the flashcard
#
# Returns the newly created flashcard object
sub createFlashcard {
	my ( $deckid, $question, $answer ) = @_;
	
	my $card = new GrayscalePerspective::Flashcard();
	$card->setDeckId($deckid);
	$card->setQuestion($question);
	$card->setAnswer($answer);
	
	$card->save();
	return $card;
}

1;