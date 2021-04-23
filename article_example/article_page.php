<?php
	// Get articles from db
	
	// Connect to db
	$conn = new mysqli('localhost', 'root', '', 'article_example');
	if ($conn->connect_error) {
		die("Connection failed: " . $conn->connect_error);
	}
		
	// Get articles
	$articles = $conn->query("SELECT id, author, title, content, views FROM `articles` ORDER BY id DESC");
	if ( $articles->num_rows == 0 ) {
		echo "No articles found.";    
	}
?>
<html>
	<head>
        <title>Articles</title>
		<script src="js/jquery-3.4.1.js"></script>
		<script src="js/article_page.js"></script>
        <link rel="stylesheet" type="text/css" href="css/article_page.css">
	</head>
	<body>
		<div class="topbar">
            <div class="page-title">Example Page</div>
        </div>
		<div class="main-content">
            <div class="article-container">
                <h2>Articles</h2>
				<?php
					while ( $article = $articles->fetch_assoc() ) {
				?>
                    <div class="article-box" data-article_id="<?php echo $article['id'] ?>">
                        <div class="title-section">
                            <span class="title"><?php echo $article['title'] ?></span> 
                            <span class="instructions">(click to expand)</span>
                        </div>
                        <div class="content-section">
                            <div class="author">Author: <?php echo $article['author'] ?></div>
                            <div class="views">Views: <?php echo $article['views'] ?></div>
                            <div class="article-text"><?php echo $article['content'] ?></div>
                            <div class="comment-section">
                                <h4>Comments</h4>
                                <form class="comment-form">
                                    <div class="invite">Would you like to add a comment?</div>
                                    <div class="form-entry">
                                        <span>Name:</span>
                                        <input type="text" class="comment-author-input" name="comment_author">
                                    </div>
                                    <div class="form-entry">
                                        <span>Comment:</span>
                                        <textarea class="comment-textbox" name="comment_text"></textarea>
                                    </div>
                                    <button type="submit">Post Comment</button>
                                </form>
                                <div class="comments">
								<?php	
									// Get comments
									$comments = $conn->query("SELECT id, author, content FROM `comments` WHERE article_id = " . $article['id']);
	
									if ( $comments->num_rows > 0 ) {
										while ( $comment = $comments->fetch_assoc() ) {
								?>
									<div class="comment" data-comment_id="<?php echo $comment['id'] ?>">
										<div class="comment-author"><?php echo $comment['author'] ?></div>
										<div class="comment-text"><?php echo $comment['content'] ?></div>
									</div>
								<?php
										}
									}
									else {
								?>
									<div>No comments</div>
								<?php
									}
								?>
                                </div>
                            </div>
                        </div>
                    </div>
				<?php 
					}
					
					// Close the db
					$conn->close();
				?>
            </div>
        </div>
		<div class="foot">
            <div class="foot-content">This is an example</div>
        </div>
	</body>
</html>