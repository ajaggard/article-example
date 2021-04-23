#!C:\xampp\perl\bin\perl.exe
use strict;
use warnings;

use DBI;
use Template;

print "Content-type: text/html; charset=iso-8859-1\n\n";

my $dbh = DBI->connect("DBI:mysql:article_example","root","");

my $config = {
	INCLUDE_PATH => '/Apache24/htdocs/tt',
};
my $tt = Template->new($config);

my $output = "";

$output = get_article_view();

print $output;

$dbh->disconnect;

# Gets all the articles and outputs the template for the webpage that displays them
sub get_article_view {
	my $articles = $dbh->selectall_arrayref(
		"SELECT id, author, title, content, views FROM `articles` ORDER BY id DESC",
		{ "Slice" => {} }
	);
	
	my $comment_sth = $dbh->prepare(
		"SELECT id, author, content FROM `comments` WHERE article_id = ?"
	);
	
	for my $article ( @$articles ) {
		$comment_sth->execute($article->{'id'});
		$article->{'comments'} = $comment_sth->fetchall_arrayref({});
	}

	my $tt_vars = {
		articles => $articles,
	};

	$tt->process('article_page.tt', $tt_vars, \$output) || die $tt->error();
    
    return $output;
}

1;