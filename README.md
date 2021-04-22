
In this README file we:

	1-Explain the architecture of the archive provided

	2-Explain the steps for running our code 

	3-Give the motivation/intuition behind every feature we engineered 

	4-Provide some final remark related to our work


1- Our script contains 3 main files:

 	a. Feature_Engineering: This Script contains all the preliminary steps for the manipulation of our data in terms
                          	of data cleaning, and building the features we have decided to use in the model. 
	
	b. Modelling: This Script contains the steps of running a Random Forest Regressor model on the features extracted
                     from .a., with the prediction results. 

	c. Extra Attempted Work: This script contains two main methods that we have attempted in order to extract interesting
                                 features, the first being LDA and the second relating to a specific Network Building, 
				 yet these methods were very difficult/not possible to implement given our computational power on the full data.
				 Thus, we add them to this file. 



 2- For successfully running our code, the order that needs to be followed is the same as the order listed. We would also like to note that at the end 
    of "Feature Engineering" we have saved our data with the created features in a new file named "final_features" that we've loaded in the beginning 
    of the "Modelling" script. Moreover, we would like to mention that in the final script, only the part corresponding to LDA can be run on a very small 
    sample of the data, while the second part is not necessary to be run, as we only wanted to present our attempt and ideas. 



 3- For our features we chose to add:
	- 'comment_count_author' : Number of comments per author, as we believe that the higher the number of comments per author, the more likely 
                                   is for the author to be known, which might affect the score of his/her comment 

        - 'is_AutoModerator' : A dummy variable that is equal to 1 if the author of the comment is Auto_Moderator, as in our data we have lots of comments
			       belonging to AutoModerator and a majority of them have received at least one upvote

        - 'time_elapse' : Amount of time elapsed since first comment in the thread was posted. It is the difference in time between the comment under 
		          question was posted and the very first comment posted in the same thread. As we believe that the more recent is the comment, 
                          the more likely it is for the comment to to be noticed, thus receive upvotes
        
        - 'hour_of_comment' : The specific hour a comment was made. We believe that there are some 'active' hours for the comments to be noticed, 
			      which motivates us to include this feature

	- 'weekday' : The day of the week a comment was posted. Similarly to hour_of_comment, we believe that some weekdays attract more user engagement
		      and participation

	- 'word_count' : The length of a comment in number of words. We decide to include this feature because we believe that sometimes long comments are 
                         likely to be ignored by some users, which lowers their chance to receive upvotes

	- 'no_of_linked_urls' : The number of urls found in the comment. We believe that a comment containing a url can usually provide useful information,
			        thus it is likely to receive more upvotes 

	- 'depth' : The depth of a comment which translates to the number of posts that have led to this comment. We believe that having a higher depth 
		    indicates a thread which is interesting, thus it is more likely to have comments with high upvotes

	- 'degree_author' : The degree centrality measure for the author of a comment, as we believe that the higher the degree of the author, the more
			    he's connected to other authors, thus the higher the chances for his comment to receive upvotes

	- 'eigenVector_author' : The eigenVector centrality measure of the author, which gives the importance of an "author" depending on the importance of his neighbours.
				 We chose to also account for this centrality measure to distinguish the 'popular' authors which have a higher chance of receiving
				 upvotes

	- 'degree' : The degree centrality measure for the comment, as we believe that the higher the comment is linked to other comments, the more likely
		     it is for it to be popular and receive upvotes 

	- 'eigenVector' : The eigenVector centrality measure of the comment, as which gives the importance of a "comment" depending on the importance of its neighbours. 
			  We chose to also account for this centrality measure to distinguish the 'popular' comments which have a higher chance of receiving
			  upvotes

	- 'word_count_cleaned' : The number of "significant" words in a comment. Obtained after cleaning the text of each comment, we decided to use this as a feature 
				 as we believe that the more a comment contains significant words, the higher it has chance to receive upvotes. 

	- 'Hard_Cluster' : The number associated to the topic/cluster a comment belongs to. After implementing a Hard Clustering, we included this feature because 
			   we believe that surely some topics are more attractive than others, thus might receive higher upvotes. 

	- 'author_nb_hard_clusters' : The number of clusters an author appears in. We believe that authors who post about a variety of topics, are more likely to be popular 
				      thus might receive higher upvotes. 
	
	- 'degree_author_topic' : The degree centrality measure of an author in a 'specific' cluster. We decide to include this feature because we believe that 
				  an author who posts comments on a variety of topics, might be very connected and central to other authors in a "specific" topic only! Hence
				  he is more likely to receive more upvotes for the comments included in this cluster.Thus, including this feature will account for the 
				  centrality of the author of a comment, with respect to the specific topic included in this comment, which is likely to affect the 
				  number of upvotes. 

	- 'contains_?' : A dummy variable that is equal to 1 if the comment contains the special character '?', 0 otherwise. The motivation behind using this feature is that 
			 often questions attract attention and can affect the upvotes. 

	- 'contains_!' : A dummy variable that is equal to 1 if the comment contains the special character '!', 0 otherwise. The motivation behind using this feature is that 
			 often hysteric comments, ending with '!' attract attention and can affect the upvotes. 
 

4- For our study we have used the following machine learning algorithms for a regression case:
	- XGBoost 
	- CatBoost 
	- Random Forest 
	- LightGBM

The lowest MAE was achieved by the Random Forest Regressor. We tried some hyper-parameter tuning with the help of `GridSearchCV` but the code took a long time to run and the 
system ultimately crashed. 

We would like to thank Professor Yoann Pitarch for giving us the opportunity to work in such an intensive project. Handling such a huge dataset being first-time Kagglers was indeed daunting but we faired well and Professor and fellow classmates were always available to lend their helping hand.

Also, attached is a formal report and SQLite codes along with some Python visualizations. 
