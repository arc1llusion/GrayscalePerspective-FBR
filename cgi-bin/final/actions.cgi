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
			 
			 "getdecksuser" 	=> \&GetAllDecksForUser,
			 "createdeck"   	=> \&CreateDeck,
			 
			 "header"           => \&GetHeader,
			 "createdecktmpl"   => \&GetCreateDeckHtml,
			 "decklisting"      => \&GetDeckListing);

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
sub GetAllDecksForUser {
	print $cgi->header;
	my $user = _getLoggedInUser();
	
	my $userid = $user->getId();
	my $decks_ref = GrayscalePerspective::FlashcardService::getDecksByUser($userid);
	my @decks = @$decks_ref;
	foreach my $deck (@decks) {
		print $deck->getTitle() . "<br />";
	}
}

sub CreateDeck {
	print $cgi->header;
	my $user = _getLoggedInUser();
	my $userid = $user->getId();
	
	my $category = param('category');
	my $title = param('title');
	
	GrayscalePerspective::FlashcardService::createDeck($userid, $category, $title);
	print "Success";
}

############################
#       HTML Template      #
############################

sub GetHeader {
	my $template = HTML::Template->new(filename => 'Templates/header.tmpl');
	$template->param(LOGGEDIN => _isUserLoggedIn());
	
	if (_isUserLoggedIn()) {
		my $user = _getLoggedInUser();
		$template->param(USERNAME => $user->getUsername());
	}
	
	my @classes = @{GrayscalePerspective::Battle::Service::getAllClasses()};
	
	my @classref = ();
	foreach my $classobj (@classes) {
		my %classhash;
		$classhash{Id} = $classobj->getId();
		$classhash{Title} = $classobj->getTitle();
		
		push(@classref, \%classhash);
	}
	
	$template->param(CLASS_LOOP => \@classref);
	
	print $cgi->header;
	print $template->output;	
}

sub GetCreateDeckHtml {
	my $template = HTML::Template->new(filename => 'Templates/CategoriesDropdown.tmpl');
	#$template->param(LOGGEDIN => _isUserLoggedIn());
	
	print $cgi->header;
	
	my @categories = @{GrayscalePerspective::FlashcardService::getAllCategories()};
	
	my @catref = ();
	foreach my $catobj (@categories) {
		push(@catref, $catobj->getHashRef());
	}	
	
	$template->param(CAT_LOOP => \@catref);
	print $template->output;	
}

sub GetDeckListing {
	my $template = HTML::Template->new(filename => 'Templates/decklisting.tmpl');
	print $cgi->header;
	my $user = _getLoggedInUser();	
	my $userid = $user->getId();
	my @decks = @{GrayscalePerspective::FlashcardService::getDecksByUser($userid)};
	
	my @deckref = ();
	foreach my $deckobj (@decks) {
		my %deckhash;
		$deckhash{ID} = $deckobj->getId();
		$deckhash{TITLE} = $deckobj->getTitle();
		$deckhash{DECK_LINK} = "https://crux.baker.edu/~jgerma08/final/";
		push(@deckref, \%deckhash);
	}
	$template->param(DECK_LOOP => \@deckref);
	print $template->output;	
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