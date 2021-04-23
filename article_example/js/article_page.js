// Constructor for each article object --------------------------
function Article(article_element) {
    var this_article = this;
    this_article.element = article_element;
    this_article.article_id = $(this_article.element).data('article_id');
    this_article.is_open = false;
    this_article.viewed = false;
    this_article.animating = false;
    
    $(this_article.element).find('.title-section').on('click', function() {
        if ( this_article.is_open ) {
            this_article.close();
        }
        else {
            this_article.open();
        }
    });
    
    $(this_article.element).find('.comment-form button').on('click', function(e) {
        e.preventDefault();
        this_article.add_comment();
    });
}

// Methods for each article object ------------------------------
// Open the article for viewing
Article.prototype.open = function() {
    var this_article = this;
    
    if ( !this_article.is_open && !this_article.animating ) {
        this_article.add_view();
        
        this_article.animating = true;
        // Hide other articles
        var other_articles = $('.article-container .article-box:not([data-article_id="' + this_article.article_id + '"])');
        other_articles.fadeOut(300, function() {
            // Expand to full width
            $(this_article.element).animate({ 'width': '100%', 'height': '500px' }, 300, function() {
                $(this_article.element)
                    .addClass('active')
                    .find('.title-section .instructions').text('(click to hide)');
                
                // Show contents
                $(this_article.element).find('.content-section').fadeIn(300, function() {
                    this_article.is_open = true;
                    this_article.animating = false;
                });
            });
        });
    }
};

// Close and hide the article
Article.prototype.close = function() {
    var this_article = this;
    
    if ( this_article.is_open && !this_article.animating ) {
        this_article.animating = true;
        // Hide contents
        $(this_article.element).find('.content-section').fadeOut(300, function() {
            // Shrink
            var title_height = $(this_article.element).find('.title-section').outerHeight();
            $(this_article.element).animate({ 'width': '33%', 'height': title_height }, 300, function() {
                // Clear inline css
                $(this_article.element).css({
                    'width': '',
                    'height': '',
                });
                
                $(this_article.element)
                    .removeClass('active')
                    .find('.title-section .instructions').text('(click to expand)');
                
                // Show other articles
                var other_articles = $('.article-container .article-box:not([data-article_id="' + this_article.article_id + '"])');
                other_articles.fadeIn(300, function() {
                    this_article.is_open = false;
                    this_article.animating = false;
                });
            });
        });
    }
};

// Add a view to the article
Article.prototype.add_view = function() {
    var this_article = this;
    if ( !this_article.viewed ) {
        this_article.viewed = true;
        
        // Send an ajax to add one view for the article
        $.ajax({
            'method': 'POST',
            'url': 'perl/article_functions.pl',
            'data': { 
                'action':     'add_view',
                'article_id': this_article.article_id,
            },
            'success': function(data) {
                // Update the number of views displayed in the article
                this_article.element.find('.views').text('Views: ' + data.views);
            },
            'error': function(e) {
                console.log(e.responseText);
            },
        });
    }
};

// Add a new comment to the article
Article.prototype.add_comment = function() {
    var this_article = this;
    
    var comment_author = this_article.element.find('.comment-form .comment-author-input').val();
    var comment_text = this_article.element.find('.comment-form .comment-textbox').val();
    if ( comment_author && comment_text ) {
        this_article.element.find('.comment-form .comment-author-input, .comment-form .comment-textbox, .comment-form button').prop('disabled', true);
        $.ajax({
            'method': 'POST',
            'url': 'perl/article_functions.pl',
            'data': { 
                'action':          'add_comment',
                'article_id':      this_article.article_id,
                'comment_author':  comment_author,
                'comment_content': comment_text,
            },
            'success': function(data) {
                // Refresh the article comment section to include the new comment
                if ( data.comments_html ) {
                    this_article.element.find('.comment-section .comments').fadeOut(100, function() {
                        $(this).html(data.comments_html);
                        $(this).fadeIn(100);
                        
                        this_article.element.find('.comment-form .comment-author-input, .comment-form .comment-textbox').val('');
                        this_article.element.find('.comment-form .comment-author-input, .comment-form .comment-textbox, .comment-form button').prop('disabled', false);
                    });
                }
            },
            'error': function(e) {
                console.log(e.responseText);
            },
        });
    }
};
    
$(document).ready(function(){
    var current_articles = [];
    $('.article-container .article-box').each(function() {
        current_articles.push(new Article($(this)));
    });
});