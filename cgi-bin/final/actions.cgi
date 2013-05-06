#!/usr/bin/perl
#Actions for the web application

use strict;
use warnings;
use CGI qw(:standard -debug);
use CGI::Session;
use HTML::Template;

#GS Modules
use GrayscalePerspective::Person;

use GrayscalePerspective::Flashcards::Category;
use GrayscalePerspective::Flashcards::Deck;
use GrayscalePerspective::Flashcards::Flashcard;
use GrayscalePerspective::Flashcards::FlashcardService;


use GrayscalePerspective::Battle::Service;
use GrayscalePerspective::Battle::Character;
GrayscalePerspective::DAL::db_connect();

my $cgi = new CGI;
#print $cgi->header; Let individual methods print the header

my ( $action_param );
my ( %actions );

#actions hash to determine which method to call. Saves from having to use a bunch of if statements. 
#I'll admit it, Perl if pretty nifty here even though
#JS and modern compiled languages can also achieve this. I guess this shows my low expectations of the language.

%actions = ( "valuser"      	=> \&ValidateUser,
			 "reguser"      	=> \&RegisterUser,
			 "login"        	=> \&LogIn,
			 "logout"       	=> \&LogOut,
			 
			 "createdeck"   	=> \&CreateDeck,
			 "createfc"         => \&CreateFlashcard,
			 
			 "gethome"          => \&GetHomeTemplate,
			 "getlogin"         => \&GetLoginTemplate,
			 "getdecklisting"   => \&GetDeckListingTemplate,
			 "getflashcards"    => \&GetFlashcardTemplate,
			 "getbattle"        => \&GetBattleTemplate,
			 
			 "attack"           => \&Attack,
			 "challenge"        => \&IssueChallenge);

$action_param = param('action');

while ( my ( $key, $value) = each %actions )
{
	if ( $key eq $action_param ) {
		$value->();
		last; #break out of the loop. We only want one action since this will primarily be accessed through AJAX calls.
	}
}

exit; 

############################
#       User Related       #
############################
sub LogIn {
	my $result = 0;
	my $username = param('username');
	my $password = param('password');
	my $object = _loadUser( $username );
	if ( $object != 0 and _validateUserObject( $object, $password ) ) {		
		my $sid = $cgi->cookie("CGISESSID") || undef;
		my $session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});
		
		my $cookie = $cgi->cookie(CGISESSID => $session->id);
		print $cgi->header( -cookie=>$cookie );
		
		$session->param('user', $object);
		$session->param('loggedin', 1);
		
		$result = 1;
	}
	else {
		print $cgi->header;
	}
	
	print $result;
}

sub LogOut {
	my $sid = $cgi->cookie("CGISESSID") || undef;
	my $session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});
	my $cookie = $cgi->cookie(CGISESSID => $session->id);
	
	$cookie->expires('-3M');	
	print $cgi->header( -cookie=>$cookie );
	
	$session->param('loggedin', 0);
	
	print 1;
}

sub ValidateUser {
	my $username = param('username');
	my $password = param('password');
	print _validateUser($username, $password);
}

sub RegisterUser {
	my ( $username, $password, $email, $firstname, $lastname, $charactername, $classid );
	$username = param('username');
	$password = param('password');
	$email = param('email');
	$firstname = param('firstname');
	$lastname = param('lastname');
	$charactername = param('charactername');
	$classid = param('classid');
	
	my $object = new GrayscalePerspective::User();
	$object->setUsername($username);
	$object->setEmail($email);
	
	my $userProfile = new GrayscalePerspective::User_Profile();
	$userProfile->setFirstName($firstname);
	$userProfile->setLastName($lastname);
	
	$object->setUserProfile($userProfile);
	$object->save($password, $charactername, $classid);
	
	print $cgi->header;
	print 1;
}


############################
#    Flashcard Related     #
############################

sub CreateDeck {
	print $cgi->header;
	my $user = _getLoggedInUser();
	my $userid = $user->getId();
	
	my $category = param('category');
	my $title = param('title');
	
	GrayscalePerspective::FlashcardService::createDeck($userid, $category, $title);
	print "Success";
}

sub CreateFlashcard {
	print $cgi->header;
	my $deckid = param('deckid');
	my $question = param('question');
	my $answer = param('answer');
	
	GrayscalePerspective::FlashcardService::createFlashcard( $deckid, $question, $answer );
	print "Success";
}

############################
#       HTML Template      #
############################

sub GetHomeTemplate {
	my $template = HTML::Template->new(filename => 'Templates/body.tmpl');
	$template->param(HOME_CONTENT => 1);
	
	
	print $cgi->header;
	print $template->output;	
}

sub GetLoginTemplate {
	my $template = HTML::Template->new(filename => 'Templates/body.tmpl');
	$template->param(LOGIN_REGISTER_CONTENT => 1);
	
	$template->param(CLASS_LOOP => _getBattleClassArrayRef() );
	
	print $cgi->header;
	print $template->output;	
}

sub GetDeckListingTemplate {
	my $template = HTML::Template->new(filename => 'Templates/body.tmpl');
	$template->param(DECK_LISTING_CONTENT => 1);
	
	if( _isUserLoggedIn() ) {
		$template->param(LOGGED_IN => _isUserLoggedIn() );
		$template->param(CAT_LOOP => _getCategoriesArrayRef() );
		$template->param(DECK_LOOP => _getDecksArrayRef( _getLoggedInUser()->getId() ) );
	}
	
	print $cgi->header;
	print $template->output;	
}

sub GetFlashcardTemplate {
	print $cgi->header;
	my $template = HTML::Template->new(filename => 'Templates/body.tmpl');
	$template->param(FLASHCARD_CONTENT => 1);
	
	if( _isUserLoggedIn() ) {
		my $deckid = param('deckid');
	
		$template->param(LOGGED_IN => 1 );
		$template->param(FLASHCARDS_LOOP => _getFlashcardsArrayRef( $deckid ) );
	}
	
	print $template->output;	
}

sub GetBattleTemplate {
	my $template = HTML::Template->new(filename => 'Templates/body.tmpl');
	$template->param(BATTLE_CONTENT => 1);
	$template->param(LOGGED_IN => _isUserLoggedIn() );
	
	print $cgi->header;
	
	if ( _isUserLoggedIn() ) {
		my $user = _getLoggedInUser();
		$user->load();
		
		my $hasActiveBattle = GrayscalePerspective::Battle::Service::doesCharacterHaveActiveBattle( $user->getCharacter()->getId() );
		$template->param(IN_BATTLE => $hasActiveBattle );
		
		if( $hasActiveBattle ) {		
			my $character = $user->getCharacter();
			my $opponent = GrayscalePerspective::Battle::Service::getOpponentCharacterObject( $character->getId() );
			
			_saveCharacterToTemplate( $template, $character, "CHARACTER");
			_saveCharacterToTemplate( $template, $opponent, "OPPONENT");
			
			my $battleid = GrayscalePerspective::Battle::Service::initiateBattle($character, $opponent);
			$template->param(BATTLE_ID => $battleid);
			
			my $logs = GrayscalePerspective::Battle::Service::getBattleLog( $battleid );
			
			_saveSessionParam('battleid', $battleid);
			_saveSessionParam('opponent', $opponent);
			
			$template->param(MESSAGE_LOOP => $logs);
		}
	}
	
	print $template->output;
}

############################
#      Battle Related      #
############################

sub Attack {
	print $cgi->header;	

	my $battleid = _getSessionParam('battleid');
	my $character = _getLoggedInUser()->getCharacter();
	my $opponent = _getSessionParam('opponent');
	my $message = param('message');
	
	GrayscalePerspective::Battle::Service::takeTurn($battleid, $character, $opponent, $message);
}

sub IssueChallenge {
	print $cgi->header;
	my $charactertochallenge = param("charchallenge");
	if ( _isUserLoggedIn() ) {
		
		if( defined ( $charactertochallenge ) and $charactertochallenge ne "") {
			my $opponent = new GrayscalePerspective::Character();
			$opponent->setName( $charactertochallenge );
			$opponent->loadFromName();
			
			my $user = _getLoggedInUser();
			$user->load();
			
			my $battleid = GrayscalePerspective::Battle::Service::initiateBattle($user->getCharacter(), $opponent);

			if( defined ( $battleid ) ) {
				_saveSessionParam('battleid', $battleid);
				_saveSessionParam('opponent', $opponent);
			}
		}
	}
}

############################
#      Utility Methods     #
############################
sub _loadUser {
	my ( $username ) = @_;
	my $object = new GrayscalePerspective::User();
	$object->setUsername($username);	
	
	if ( $object->loadFromUsername() != 0) {
		return $object;
	}
	return 0;
}

sub _validateUser {
	my ( $username, $password ) = @_;
	
	my $object = new GrayscalePerspective::User();
	$object->setUsername($username);
	
	if ( $object->loadFromUsername() != 0) {
		return $object->validatePassword($password);
	}
	return 0;
}

sub _validateUserObject {
	my ( $userObject, $password ) = @_;
	return $userObject->validatePassword($password);
}

sub _getSession {
	my $sid = $cgi->cookie("CGISESSID") || undef;
	my $session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});
	return $session;
}

sub _saveSessionParam {
	my $sparam_key = $_[0];
	my $sparam_value = $_[1];

	my $session = _getSession();
	$session->param($sparam_key, $sparam_value);
}

sub _getSessionParam {
	my $sparam_key = $_[0];
	my $session = _getSession();
	
	return $session->param($sparam_key);
}

sub _getLoggedInUser {
	my $sid = $cgi->cookie("CGISESSID") || undef;
	my $session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});
	my $user = $session->param('user');
	return $user;
}

sub _isUserLoggedIn {
	my $session = _getSession();
	return $session->param('loggedin');
}

sub _getCategoriesArrayRef {
	my @categories = @{GrayscalePerspective::FlashcardService::getAllCategories()};
	
	my @catref = ();
	foreach my $catobj (@categories) {
		push(@catref, $catobj->getHashRef());
	}	
	
	return \@catref;
}

sub _getDecksArrayRef {
	my $userid = $_[0];
	my @decks = @{GrayscalePerspective::FlashcardService::getDecksByUser($userid)};
	
	my @deckref = ();
	foreach my $deckobj (@decks) {
		my %deckhash;
		$deckhash{ID} = $deckobj->getId();
		$deckhash{TITLE} = $deckobj->getTitle();
		push(@deckref, \%deckhash);
	}
	
	return \@deckref;
}

sub _getFlashcardsArrayRef {
	my $deckid = $_[0];
	my @cards = @{GrayscalePerspective::FlashcardService::getFlashcardsByDeck($deckid)};
	
	my @flashcardref = ();
	
	foreach my $cardobj (@cards) {
		my %cardhash;
		$cardhash{QUESTION} = $cardobj->getQuestion();
		$cardhash{ANSWER} = $cardobj->getAnswer();
		push(@flashcardref, \%cardhash);
	}
	
	return \@flashcardref;
}

sub _getBattleClassArrayRef {
	my @classes = @{GrayscalePerspective::Battle::Service::getAllClasses()};
	my @classref = ();
	foreach my $classobj (@classes) {
		my %classhash;
		$classhash{Id} = $classobj->getId();
		$classhash{Title} = $classobj->getTitle();
		
		push(@classref, \%classhash);
	}
	return \@classref;
}

sub _saveCharacterToTemplate {
	my $template     = $_[0];
	my $character = $_[1];
	my $prefix       = $_[2];
	
	$template->param($prefix . "_NAME" => $character->getName());
	$template->param($prefix . "_CLASS_NAME" => $character->getClass()->getTitle());
	$template->param($prefix . "_LEVEL" => $character->getLevel());
	$template->param($prefix . "_HEALTH" => $character->getStatCollection()->getHP()->getCurrentValue());
	$template->param($prefix . "_MP" => $character->getStatCollection()->getMP()->getCurrentValue());
	$template->param($prefix . "_EXP" => $character->getEXP());
}