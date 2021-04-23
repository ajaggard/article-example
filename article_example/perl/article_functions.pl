#!C:\xampp\perl\bin\perl.exe
use strict;
use warnings;

use lib '.';

use DBI;
use Template;
use CGI qw(:standard);
use JSON qw/to_json from_json/;
use Article;

my $dbh = DBI->connect("DBI:mysql:article_example","root","");

my $q = CGI->new;

my $action = $q->param('action');

my $output = {};

if ( $action eq 'add_view' ) {
	$output = add_article_view($dbh, $q);
}
elsif ( $action eq 'add_comment' ) {
	$output = add_article_comment($dbh, $q);
}

print header('application/json');

my $json_output = to_json($output);
print $json_output;

$dbh->disconnect;

# Add a view to an article and save
sub add_article_view {
	my ($dbh, $q) = @_;
	
	my $article_id = $q->param('article_id');
	
	return { 'error' => 'No article id' } unless $article_id;
	
	my $article = get_article($dbh, $article_id);
	
	my $views = $article->add_view();
    
    $article->save();
	
	return { 'success' => 1, 'views' => $views };
}

# Add a comment to an article and save
sub add_article_comment {
	my ($dbh, $q) = @_;
	
    my $article_id = $q->param('article_id');
    
	return { 'error' => 'No article id' } unless $article_id;
	
	my $article = get_article($dbh, $article_id);
    
    my $author = $q->param('comment_author');
    my $text = $q->param('comment_content');
    
    return { 'error' => 'Missing info' } unless $author && $text;
	
	$article->add_comment({
		'author' => $author,
        'content' => $text,
	});
    
    $article->save();
    
    # Rebuild the comment section of the article to include the new comment
    my $tt_vars = {
        'article' => $article,
    };
    
    my $config = {
        INCLUDE_PATH => '/xampp/htdocs/article_example/tt',
    };
    my $tt = Template->new($config);
    
    my $comments_html = '';
    $tt->process('article_comments.tt', $tt_vars, \$comments_html) || die $tt->error();
    	
	return { 'success' => 1, 'comments_html' => $comments_html };
}

# Get the article object
sub get_article {
	my ($dbh, $article_id) = @_;
    
    my $article_data = $dbh->selectrow_hashref(
        "SELECT id, author, title, content, views FROM `articles` WHERE id = ?",
        undef,
        $article_id
    );
    
    my $article = Article->new(
        dbh => $dbh,
        %$article_data
    );
	
	return $article;
}

1;