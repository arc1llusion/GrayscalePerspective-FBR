#!/usr/bin/perl
package GrayscalePerspective::DAL;

#DAL - Data Access Layer. For this project, each component will be fairly coupled to make it easy on me, since this project is already large.
#In addition, credentials are hardcoded. In a real scenario, this is obviously a no-no.

#This will not be an object, and so we'll be a little more preemptive with our exporting.
use base Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(db_connect execute_query execute_single_row_hash execute_table_arrayref);

use DBI;

my ($server, $username, $password, $db, $dbh);

$server = "localhost";
$username = "jgerma08";
$password = "password";
$db = "jgerma08_db";

sub db_connect {
	$dbh = DBI->connect("dbi:mysql:database=$db;" . "host=$server;port=3306;mysql_multi_results=1", $username, $password) or return 0;
}

sub execute_query {
	my $sql = $_[0];
	my @parameter_values = ();
	
	if($_[1]) {
		@parameter_values = @{$_[1]};
	}
	my $result = $dbh->prepare($sql);
	$result->execute(@parameter_values) or print "Failed with error: " . $DBI::errstr;
	
	return $result;
}

sub execute_single_row_hashref {
	my $sql = $_[0];
	my @parameter_values = ();
	
	if($_[1]) {
		@parameter_values = @{$_[1]};
	}
	
	my $row = $dbh->selectrow_hashref($sql, undef, @parameter_values) or die "Failed with error: " . $DBI::errstr;
	return $row;
}

sub execute_table_arrayref {
	my $sql = $_[0];
	my @parameter_values = ();
	
	if($_[1]) {
		@parameter_values = @{$_[1]};
	}
	
	my $arrayref = $dbh->selectall_arrayref($sql, { Slice => {} }, @parameter_values) or die "Failed with error: " . $DBI::errstr;
	return $arrayref;
}

1;