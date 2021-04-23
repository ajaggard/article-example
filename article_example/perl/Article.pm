#!/Strawberry/perl/bin/perl
use strict;
use warnings;

package Article;

use Moo;
use Types::Standard qw/Num ArrayRef HashRef Str Object/;

# Attributes 

has dbh => (
    is => 'ro',
    isa => Object,
);

has id => (
    is => 'ro',
    isa => Num,
);

has author => (
    is => 'ro',
    isa => Str,
);

has title => (
    is => 'ro',
    isa => Str,
);

has content => (
    is => 'ro',
    isa => Str,
);

has views => (
    is => 'rw',
    isa => Num,
);

has comments => (
    is => 'lazy',
    isa => ArrayRef[HashRef],
);

# Public methods

# Increment the current number of views by one
sub add_view {
    my ($self) = @_;
    
    my $cur_views = $self->views;
    
    $self->views($cur_views + 1);
    
    return $cur_views + 1;
}

# Add a comment to the list of comments on the article
sub add_comment {
    my ($self, $comment_data) = @_;
        
    push @{$self->comments}, $comment_data;
    
    return;
}

# Save all the current data for the article
sub save {
    my ($self) = @_;
        
    # Save article
    $self->dbh->do("
        UPDATE `articles`
        SET author = ?,
            title = ?,
            content = ?,
            views = ?
        WHERE id = ?",
        undef,
        $self->author,
        $self->title,
        $self->content,
        $self->views,
        $self->id
    );
    
    # Save comments
    for my $comment ( @{$self->comments} ) {
        if ( $comment->{'id'} ) {
            # Update
            $self->dbh->do("
                UPDATE `comments`
                SET author = ?,
                    content = ?
                WHERE id = ?",
                undef,
                $comment->{'author'},
                $comment->{'content'},
                $comment->{'id'}
            );
        }
        else {
            # Insert
            $self->dbh->do("
                INSERT INTO `comments` (
                    article_id,
                    author,
                    content
                ) VALUES (?,?,?)",
                undef,
                $self->id,
                $comment->{'author'},
                $comment->{'content'}
            );
        }
    }
    
    return;
}

# Private methods

sub _build_comments {
    my ($self) = @_;
    
    my $comments = $self->dbh->selectall_arrayref(
        "SELECT id, author, content FROM `comments` WHERE article_id = ?",
        { "Slice" => {} },
        $self->id
    );
    
    return $comments;
}

1;