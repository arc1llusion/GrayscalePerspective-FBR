#!/usr/bin/perl
#c06case1.cgi - creates a dynamic Web page
print "Content-type: text/html\n\n";
use GrayscalePerspective::Person;
use GrayscalePerspective::User_Profile;
use GrayscalePerspective::DAL;
use GrayscalePerspective::Flashcards::Category;
use GrayscalePerspective::Flashcards::Deck;
use GrayscalePerspective::Flashcards::Flashcard;
use GrayscalePerspective::Flashcards::FlashcardService;

use GrayscalePerspective::Battle::Character;
use GrayscalePerspective::Battle::Service;
db_connect();





#my $object = new GrayscalePerspective::Category();
#$object->setTitle("New Category x");
#$object->save(1);


#my $secondobject = new GrayscalePerspective::Category(1, 1);
#print $secondobject->getTitle();

#my $deckObject = new GrayscalePerspective::Deck();
#$deckObject->setTitle("New Deck 2");
#$deckObject->setCreatedBy(1);
#$deckObject->setCategoryId(1);
#$deckObject->save();

#my $seconddeck = new GrayscalePerspective::Deck(1, 1);
#print $seconddeck->getTitle() . "\n";

#my @arr = @{$seconddeck->getFlashcards()};
#foreach $card (@arr) {
	#print $card->getId() . "\n";
	#print $card->getQuestion() . "\n";
	#print $card->getAnswer() . "\n";
#}

#$arr[0]->setQuestion("Renamed Question");
#$seconddeck->save();

#$seconddeck->setTitle("Renamed Deck");
#$seconddeck->save();

#my $flashcard = new GrayscalePerspective::Flashcard();
#$flashcard->setDeckId(1);
#$flashcard->setQuestion("Who rocks?");
#$flashcard->setAnswer("Jared");
#$flashcard->save();

#my $secondfc = new GrayscalePerspective::Flashcard(1, 1);
#print $secondfc->getQuestion() . "\n";
#print $secondfc->getAnswer() . "\n";
#print $secondfc->getDeckId()  . "\n";

#$secondfc->setAnswer("Always Jared");
#$secondfc->save();


#GrayscalePerspective::FlashcardService::createFlashcard(1, "Test Quest FC Service", "Test Answer FC Service");
#GrayscalePerspective::FlashcardService::createDeck(1, 1, "Test Deck");

#my $userobj = new GrayscalePerspective::User(1, 1);
#my $object = $userobj->getCharacter();
#print $object->getName() . " " . $object->getLevel();


#my $statobj = $object->getStatCollection();

#print $statobj->getHP()->getCurrentValue() . " / " . $statobj->getHP()->getMaximumValue() . "\n";
#print $statobj->getMP()->getCurrentValue() . " / " . $statobj->getMP()->getMaximumValue() . "\n";
#print $statobj->getSTR()->getCurrentValue() . " / " . $statobj->getSTR()->getMaximumValue() . "\n";
#print $statobj->getDEF()->getCurrentValue() . " / " . $statobj->getDEF()->getMaximumValue() . "\n";
#print $statobj->getMAG()->getCurrentValue() . " / " . $statobj->getMAG()->getMaximumValue() . "\n";
#print $statobj->getMDEF()->getCurrentValue() . " / " . $statobj->getMDEF()->getMaximumValue() . "\n";
#print $statobj->getDEX()->getCurrentValue() . " / " . $statobj->getDEX()->getMaximumValue() . "\n\n";


#$object->LevelUp();

#$statobj = $object->getStatCollection();


#my $classobj = $object->getClass();
#print $classobj->getTitle();

#$object->setName("Kabros");

#$statobj->getHP()->setCurrent(1);
#$statobj->getHP()->heal(2000);
#$object->save();

#print GrayscalePerspective::Battle::Service::doesCharacterHaveActiveBattle(1);
#print GrayscalePerspective::Battle::Service::doesCharacterHaveActiveBattle(2);
#print GrayscalePerspective::Battle::Service::doesCharacterHaveActiveBattle(3);

#print GrayscalePerspective::Battle::Service::doEitherCharactersHaveActiveBattle(1, 2);
#print GrayscalePerspective::Battle::Service::doEitherCharactersHaveActiveBattle(1, 3);
#print GrayscalePerspective::Battle::Service::doEitherCharactersHaveActiveBattle(2, 3);
#print GrayscalePerspective::Battle::Service::doEitherCharactersHaveActiveBattle(1, 5);
#print GrayscalePerspective::Battle::Service::doEitherCharactersHaveActiveBattle(4, 5);


#print GrayscalePerspective::Battle::Service::initiateBattle(1, 1);
#print GrayscalePerspective::Battle::Service::initiateBattle(1, 2);

GrayscalePerspective::Battle::Service::takeTurn( 15, 2 );