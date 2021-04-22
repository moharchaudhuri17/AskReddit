-------------------------------------------------------------------------------------------------------------------
-- M2 STAT - DATABASE - ASKREDDIT DATASET ANALYSIS-----------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-- author: RAHAL Mira, CHAUDHURI Mohar
-- date: 12/03/2021
-- last mod. : 06/04/2021
-------------------------------------------------------------------------------------------------------------------
-- note: This Document contains the SQL code 
--
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
----- PART 1 : Creating the Database with the corresponding Tables ------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

-- Part I- Creating and Building the Database:

-- a. Creating the Database
.open askreddit_data.db

--b.Creating the Entities 
-- In what will follow, we will always start by specifying to drop the table if it exists 

DROP TABLE IF EXISTS author;
DROP TABLE IF EXISTS distinguished;
DROP TABLE IF EXISTS controversy;
DROP TABLE IF EXISTS removal;
DROP TABLE IF EXISTS score;
DROP TABLE IF EXISTS parent;
DROP TABLE IF EXISTS subreddit;
DROP TABLE IF EXISTS "comment";
DROP TABLE IF EXISTS is_distinguished;
DROP TABLE IF EXISTS removed;
DROP TABLE IF EXISTS depends;
 
-- We start with the tables with no foreign keys  

CREATE TABLE author(
	author	 TEXT,
	--CONSTRAINTS (key) 
	CONSTRAINT pk_author PRIMARY KEY (author)
);

CREATE TABLE distinguished(
	distinguished	 TEXT,
	--CONSTRAINTS (key) 
	CONSTRAINT pk_distinguished PRIMARY KEY (distinguished)
);

CREATE TABLE controversy(
	controversiality	 INT,
	--CONSTRAINTS (key) 
	CONSTRAINT pk_controversy PRIMARY KEY (controversiality)
);

CREATE TABLE removal(
	removal_reason	 TEXT,
	--CONSTRAINTS (key) 
	CONSTRAINT pk_removal PRIMARY KEY(removal_reason)
);

CREATE TABLE Parent(
	parent_id	 TEXT,
	link_id      TEXT,
	--CONSTRAINTS (key) 
	CONSTRAINT pk_parent PRIMARY KEY(parent_id)
);

CREATE TABLE subreddit(
	subreddit_id   TEXT,
	subreddit      TEXT,
	--CONSTRAINTS (key) 
	CONSTRAINT pk_subreddit PRIMARY KEY(subreddit_id)
);

-- We now create the tables with foreign keys, which have relations with the created tables

CREATE TABLE "comment"(
	id   		  TEXT,
	created_utc   INT,
	name          TEXT,
	"body"        TEXT,
    edited        INT,	
	author_fair_css_class   TEXT,
	author_fair_text        TEXT,
	author        TEXT,
	controversiality        TEXT,
	subreddit_id            TEXT, 
	--CONSTRAINTS (key) 
	CONSTRAINT pk_comment PRIMARY KEY(id),
	CONSTRAINT fk_comment_author FOREIGN KEY (author) REFERENCES author (author),
	CONSTRAINT fk_comment_controversy FOREIGN KEY (controversiality) REFERENCES controversy (controversiality),
	CONSTRAINT fk_comment_subreddit FOREIGN KEY (subreddit_id) REFERENCES subreddit (subreddit_id)
);

CREATE TABLE score(
	id	    TEXT,
	score   INT,
	ups     INT,
	downs   INT, 
	score_hidden   BOOLEAN,
	gilded     INT,
	--CONSTRAINTS (key) 
	CONSTRAINT pk_score PRIMARY KEY(id),
	CONSTRAINT fk_score_comment FOREIGN KEY (id) REFERENCES "comment" (id)
);

CREATE TABLE is_distinguished(
	id 	   TEXT,
	distinguished    TEXT,
	--CONSTRAINTS (key) 
	CONSTRAINT pk_is_distinguished PRIMARY KEY(id,distinguished),
	-- We have to specify that the foreign keys get updated when the table of Reference is updated
	CONSTRAINT fk_is_distinguished_comment FOREIGN KEY (id) REFERENCES "comment" (id) ON UPDATE CASCADE,
	CONSTRAINT fk_is_distinguished_distinguished FOREIGN KEY (distinguished) REFERENCES distinguished (distinguished) ON UPDATE CASCADE
);

CREATE TABLE removed(
	id 	   TEXT,
	removal_reason    TEXT,
	--CONSTRAINTS (key) 
	CONSTRAINT pk_removed PRIMARY KEY(id,removal_reason),
	CONSTRAINT fk_removed_comment FOREIGN KEY (id) REFERENCES "comment" (id) ON UPDATE CASCADE,
	CONSTRAINT fk_removed_removal FOREIGN KEY (removal_reason) REFERENCES removal (removal_reason) ON UPDATE CASCADE
);

CREATE TABLE depends(
	id 	   TEXT,
	parent_id    TEXT,
	--CONSTRAINTS (key) 
	CONSTRAINT pk_depends PRIMARY KEY(id,parent_id),
	CONSTRAINT fk_depends_comment FOREIGN KEY (id) REFERENCES "comment" (id) ON UPDATE CASCADE,
	CONSTRAINT fk_depends_parent FOREIGN KEY (parent_id) REFERENCES parent (parent_id) ON UPDATE CASCADE
);

-- We can do a final check up to see whether all of our tables were created successfully

.tables

-- Success ! :) 
-- We also check the  details on the columns of the table column as a checkup 

pragma table_info("comment");

-- All works perfectly !

--c. Loading the Data into the database

-- For each entitie we have a separate csv file, therefore for each table we import from the corresponding 
-- csv file. 
-- Important Note : Each csv file will be loaded into a temporary table so that we don't get mixed up with the data types

-- Following the same order of creation of the tables 

.mode csv  
.import exp_author.csv author_temp

-- To check whether the data was imported successfully, we check the number of elements in the table author by 
-- running the following SQL command 

SELECT COUNT(*) FROM author_temp;

-- Perfect !  

-- Proceeding in a similar manner with the other tables 
.mode csv 
.import exp_distinguihshed.csv distinguished_temp
.import exp_controverse.csv controversy_temp
.import exp_removal.csv removal_temp
.import exp_parent.csv parent_temp
.import exp_subreddit.csv subreddit_temp
.import exp_comment.csv "comment_copy"
.import exp_score.csv score_temp

-- Now we need to import all the data from the temporary tables into the original tables and we will have to check the types
-- Following the same order 
-- We first start with the table author 

INSERT INTO author SELECT * FROM author_temp;
INSERT INTO distinguished SELECT * FROM distinguished_temp;
INSERT INTO controversy SELECT * FROM controversy_temp;
INSERT INTO removal SELECT * FROM removal_temp;
INSERT INTO parent SELECT * FROM parent_temp;
INSERT INTO subreddit SELECT * FROM subreddit_temp;
INSERT INTO "comment" SELECT * FROM "comment_copy";
INSERT INTO score SELECT * FROM score_temp;

-- To check that we have the correct types we run the following command 

pragma table_info(score)

-- All is perfect ! 

-- We can therefore delete all the temp tables 
DROP TABLE author_temp;
DROP TABLE distinguished_temp;
DROP TABLE controversy_temp;
DROP TABLE removal_temp;
DROP TABLE parent_temp;
DROP TABLE subreddit_temp;
DROP TABLE "comment_copy";
DROP TABLE score_temp;

-- We check that our data was not deleted 

SELECT COUNT(*) FROM score;

-- Checked ! :) 

-- We have 3 other tables that are completely dependent of the loaded tables which we need to import data to 
-- which are respectively is_distinguished, removed, and depends 
-- We take them from the full table 

-- Similarly we create a temporary table 

.import exp_askreddit.csv full_table_temp
INSERT INTO is_distinguished SELECT id, distinguished FROM full_table_temp;
INSERT INTO removed SELECT id, removal_reason FROM full_table_temp;
INSERT INTO depends SELECT id, parent_id FROM full_table_temp;

-- Now we delete the temporary table 
DROP TABLE full_table_temp;

-- Work Done !

-------------------------------------------------------------------------------------------------------------------
----- PART 2 : Exploring the Dataset by Answering the question: What is inside the database ? ---------------------
-------------------------------------------------------------------------------------------------------------------
 
-- For finiding the total number of rows in each table  
-- We can find it in SQLite and in Python by running the following commands 
-- For SQLite, we have to put .mode columns 
-- For Python, we turn it into a dataframe 

.mode columns
SELECT 'author' AS Description, COUNT(*) AS MyCount  FROM author
UNION ALL 
SELECT  'distinguished' AS Description, COUNT(*) AS MyCount FROM distinguished
UNION ALL 
SELECT 'controversy' AS Description, COUNT(*) AS MyCount  FROM controversy
UNION ALL 
SELECT 'removal' AS Description, COUNT(*) AS MyCount  FROM removal
UNION ALL 
SELECT 'score' AS Description, COUNT(*) AS MyCount  FROM score
UNION ALL 
SELECT 'parent' AS Description, COUNT(*) AS MyCount  FROM parent
UNION ALL 
SELECT 'subreddit' AS Description, COUNT(*) AS MyCount  FROM subreddit
UNION ALL 
SELECT '"comment"' AS Description, COUNT(*) AS MyCount  FROM "comment"
UNION ALL 
SELECT 'is_distinguished' AS Description, COUNT(*) AS MyCount FROM is_distinguished
UNION ALL
SELECT 'removed' AS Description, COUNT(*) AS MyCount FROM removed
UNION ALL
SELECT 'depends' AS Description, COUNT(*) AS MyCount FROM depends;

-- What we are mostly interested in in this Database are the Comments 
-- What are the basic information we know about these comments ?

-- a. How many comments were distinguished ? 
-- To do that, 
-- First we start by creating an index for the distinguished variable in the is_distinguished table
-- In order to speed up the query

CREATE INDEX idx_comments_distinguished on is_distinguished(distinguished);

-- Let us now count th comments that are distinguished 

SELECT COUNT(id) as number_distinguished
	FROM is_distinguished as isdist
		WHERE isdist.distinguished <> ""; 

-- 39764 out of the 4234970 comments were distinguished 

-- To find it in percentages 

SELECT ((COUNT(id)*100.0) /(select count(*) from "comment"))
	FROM is_distinguished as isdist
		WHERE isdist.distinguished <> "";
		
-- b.How many comments were contreversial ?
-- We also here create an index related to controversiality

CREATE INDEX idx_comments_controversial on "comment"(controversiality);

SELECT SUM(controversiality) 
	FROM "comment";
	
-- 52218 out of 4234970 comments are controversial 

-- What percentage of data is contreversial 
SELECT (SUM(controversiality)*1.0/(select count(*) from "comment"))
	FROM "comment";

-- 0.012330193602316

-- c. How many comments were edited ? 
SELECT COUNT(id) as number_edited
	FROM "comment" as c
	WHERE c.edited <> 0;
	
-- 80620
-- We compute the percentage of comments that are edited 

SELECT ((COUNT(id)*100.0) /(select count(*) from "comment"))
	FROM "comment" as c
		WHERE c.edited <> 0; 

-- 1.90367346167741 %

-- d. What do we know about the Score of the Comments ?
-- What is the Min, Max, AVG Score we have in this database ?

SELECT AVG(score) as average_score FROM score;
-- 12.6062236568382
SELECT MIN(score) as min_score FROM score;
-- -333 
SELECT Max(score) as max_score FROM score;
-- 6761

-- Median Score
SELECT score.score  as median_score
FROM score 
ORDER BY score.score 
LIMIT 1 
OFFSET (SELECT COUNT(*) FROM score) / 2

-- Mode
SELECT 
    score.score,
    COUNT(*) as modecount
FROM score
GROUP BY score.score
ORDER BY COUNT(*) DESC
LIMIT 2

-- We take the sample variance, and then we take the square root manually
-- because sqlite does not have any command for it 
SELECT ((SUM(score)*SUM(score) - SUM(score * score))/((COUNT()-1)*(COUNT())))
FROM score ; 

-- Other insights 
-- We notice that Score coincides with "ups"

SELECT MAX(ups) as max_ups FROM score;
-- 6761
SELECT MIN(ups) as min_ups FROM score;
-- (-333)

-- We also note that negative values of ups can be related to downs, as the down column in our databse is always 0 
-- we discovered it by running the following queries 
SELECT MIN(downs) as min_downs FROM score;
SELECT MAX(downs) as max_downs FROM score;

-- What is the number of hidden scores ?
SELECT COUNT(id) as number_hidden
	FROM score as s
	WHERE s.score_hidden == 1;
	
-- 7011 
-- To find their percentage 
SELECT ((COUNT(id)*100.0) /(select count(*) from score))
	FROM score as s
		WHERE s.score_hidden == 1; 
-- 0.165550169186559  percent, very low

-- What is the number of Gilded/ Percentage 
SELECT COUNT(id) as number_gilded
	FROM score as s
	WHERE s.gilded <> 0;

-- 2991
-- To find their percentage 
SELECT ((COUNT(id)*100.0) /(select count(*) from score))
	FROM score as s
		WHERE s.gilded <> 0; 

-- 0.0706262382023958 percent, very low 

-- how many comments were removed ? 

SELECT COUNT(r.id) as removed
	FROM "comment" as c, removed as r
	WHERE c.id = r.id
		AND r.removal_reason <> NULL; 
-- None

-------------------------------------------------------------------------------------------------------------------
----- PART 3 : Doing some Advanced Analysis on this Database ------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
--a. Deep Analysis on Users/ Authors of the comments
------------------------------------------------------------------------------------------------------------------- 
 
-- We start by creating an index related to the user in each comment 
 CREATE INDEX index_user_comment on "comment"(author);
 
-- First let us see the number of promotional links 
SELECT COUNT(*) 
	FROM "comment" as c
	WHERE c.author <> ""; 
	
-- 4234970 We don't have promotional links :)

-- Do we have unknown authors ?
SELECT COUNT(*) 
	FROM "comment" as c
	WHERE c.author == "[deleted]";

-- we have 312007 comments with deleted users which is around 7% of the comments
-- However, 

SELECT COUNT(*) 
	FROM "comment" as c
	WHERE c.author == "[deleted]"
	AND c.'body' == "[deleted]" ;
	
-- 284202 which is 91% of the comments that had their authors deleted

-- Let's see the popularity of each user 
-- Let us see what is the maximum number of comments per author 
SELECT MAX(num)
	FROM (SELECT COUNT(com.id) as num
			FROM "comment" as com 
			GROUP BY com.author);

--- 312007 -- which belongs to a deleted user 
--- 36910 -- is the second number 

-- Let us see what is the minimum number of comments per author 
SELECT MIN(num)
	FROM (SELECT COUNT(com.id) as num
			FROM "comment" as com 
			GROUP BY com.author);
			
-- 1 


-- Let us now find the list of the top 1000 active users with the number of comments 
SELECT COUNT(com.id) as num_comments_per_author, a.author
	FROM "comment" as com, author as a
	WHERE a.author = com.author
	AND com.author <> "[deleted]"
	GROUP BY a.author
	ORDER BY COUNT(com.id) DESC
	LIMIT 1000;
			
-- Is 1000 a good number to consider ?
-- What is the median number of comments per authors 
-- Computing the median manually

SELECT num
	FROM (SELECT COUNT(com.id) as num
			FROM "comment" as com 
			GROUP BY com.author, com.id)
	ORDER BY num
	LIMIT 1
	OFFSET (SELECT COUNT(*)
        FROM(SELECT COUNT(com.id) as num
			FROM "comment" as com 
			GROUP BY com.author)) / 2; 

-- To check that we found the right median, let's check the number of authors whose count of comments is greater than 
-- or equal to 2 

SELECT COUNT(*)
	FROM (SELECT com.author
			FROM "comment" as com 
			GROUP BY com.author, com.id
			HAVING COUNT(com.id) >= 2);
-- 321728/570735 -- All makes sense !
-- So we notice here that most users have had 

-- Calculating cumulative distributions of the count of number of comments for the interesting users 

SELECT  
	num,
	CUME_DIST()
	OVER (
		ORDER BY num DESC) CumulativeDistribution
	FROM (SELECT COUNT(com.id) as num
			FROM "comment" as com 
			GROUP BY com.author)
	LIMIT 1000;
 -- we see that these users who have a range of number of comments beeing between 
 -- 36910 and 241 and their cumulative distribution is 0.0017643915302198
 -- so it's very hard to choose a certain threshhold but what's for sure is that 1000 is a big number 
 -- to choose to specify the set of interesting users if we define interesting to be related to the number of comments 
 -- the user makes as there is a high range of values between 241 and 36910. 
 
 -- Let us look at the characteristics of comments for the top 4 users with the HIGHEST number of comments
 
 SELECT COUNT(com.id) as num_comm, com.author,
			MAX(s.ups) as max_ups,
			MIN(s.ups) as min_ups,
			AVG(s.ups) as avg_ups
			FROM "comment" as com, score as s
			WHERE s.id = com.id
			AND com.author <> "[deleted]"
			GROUP BY com.author
			ORDER BY COUNT(com.id) DESC
			LIMIT 4;
 
 -- We know that Scores can define "interesting" users 
 -- Let us look at the characteristics of comments for the top 5 users with the HIGHEST Maximum scores
 
 SELECT	COUNT(com.id) as num_comm, com.author,
			MAX(s.ups) as max_ups,
			MIN(s.ups) as min_ups,
			AVG(s.ups) as avg_ups,
			SUM(com.controversiality) as cont_comm
			FROM "comment" as com, score as s
			WHERE s.id = com.id
			AND com.author <> "[deleted]"
			GROUP BY com.author
			ORDER BY MAX(s.ups) 
			LIMIT 5;

-- Let us look at the characteristics of comments for the top 5 users with the LOWEST Minimum scores	
		
SELECT	COUNT(com.id) as num_comm, com.author,
			MAX(s.ups) as max_ups,
			MIN(s.ups) as min_ups,
			AVG(s.ups) as avg_ups,
			SUM(com.controversiality) as cont_comm
			FROM "comment" as com, score as s
			WHERE s.id = com.id
			AND com.author <> "[deleted]"
			GROUP BY com.author
			ORDER BY MIN(s.ups) 
			LIMIT 5;
		
-- 	Let us look at the characteristics of comments for the top 5 users with the HIGHEST Average scores	
SELECT	COUNT(com.id) as num_comm, com.author,
			MAX(s.ups) as max_ups,
			MIN(s.ups) as min_ups,
			AVG(s.ups) as avg_ups
			FROM "comment" as com, score as s
			WHERE s.id = com.id
			AND com.author <> "[deleted]"
			GROUP BY com.author
			ORDER BY AVG(s.ups) DESC 
			LIMIT 5;

-------------------------------------------------------------------------------------------------------------------
--b. Deep Analysis on the comments
-------------------------------------------------------------------------------------------------------------------

-- We know that all comments depend on a parent_id, therefore it would be interesting to see the top 25
-- parent_ids that had the largest comments 

SELECT COUNT(d.id) as num_comments_per_parent_id, d.parent_id as name
			FROM depends as d
			GROUP BY d.parent_id
			ORDER BY COUNT(d.id) DESC
			LIMIT 25; 

-- Can we get some characteristics of these parent_id comments ? 
-- Let us try the following query 
SELECT num_comments_per_parent_id, c_com.name, s.score, s.gilded
	FROM (SELECT COUNT(d.id) as num_comments_per_parent_id, d.parent_id as name
			FROM depends as d
			GROUP BY d.parent_id
			ORDER BY COUNT(d.id) DESC
			LIMIT 25) as c_com, score as s, "comment" as com
	WHERE c_com.name = com.name 
	AND s.id = com.id; 
	
-- We don't get any results, and this suggests that in our database, parent_ids do not coincide with comments 
-- Let us then look at the Average score of comments for the top 25 parent ids, also the number of gilded, and distinguished 

SELECT COUNT(d.id) as num_comments_per_parent_id,
		d.parent_id as name, AVG(s.score), SUM(s.gilded), SUM(com.controversiality)
			FROM depends as d, score as s, is_distinguished as dist, "comment" as com
			WHERE com.id = d.id 
			AND s.id = dist.id
			AND s.id = d.id 
			GROUP BY d.parent_id
			ORDER BY COUNT(d.id) DESC
			LIMIT 25;

-- Nothing ! Which confirms our hypothesis that we don't have any information on parent_id 

-- Let us look at the comments that were controversial
-- Our motivation behind this analysis is that we want to check if some of the controversial comments 
-- attracted significant amount of attention

SELECT c.id as id, c.author as author, s.score as score,
	s.gilded as nb_gilded, s.score_hidden as if_hidden,
    c.edited as if_edited, d.distinguished as if_distinguished
	FROM "comment" as c, score as s, is_distinguished as d
	WHERE c.id = s.id AND c.id = d.id
	AND c.controversiality == 1
	AND s.gilded > 0;
	
-- We see that the comment with id cr3xezy is a controversial commment with a score of 1780 and 2 golds
-- We decide to look at it 

SELECT com."body" 
	FROM "comment" as com
	WHERE com.id = 'cr3xezy';
	
-- The body of the report is : 
-- “This is actually an incredible question. I have only one kid myself, and the relationship I have with him
-- wasn’t the greatest during his youth. The day I really realized that my boy was growing up was not too long ago. I
-- was doing some work around the yard, and he came and asked "Dad, can I ask you a question?" so I said, "Sure!"
-- After that he asked me what I make an hour, So I told him that I make 37 euros an hour (Before taxes, ofcourse. I’m
-- from holland) He then asked me "Can I borrow fifty bucks?" To which I replied "If the only reason you asked me
-- about my pay is so that you can borrow some money to buy some random bottle of booze, you can get away from
-- my house. You know I don’t support that." He quietly looked at me, thinking to himself in deep thought. I just got
-- angrier about my boy’s question, How dare he ask me about money after all I did for him? but then I thought: Maybe
-- there’s something he really needs for those fifty bucks. So I say "I’m sorry son. Here’s the cash." so a day later he
-- comes back, and I ask him where he needed the cash for. his reply was "I needed to buy a good pair of pants so I can
-- apply for this job." Needless to say, I was incredibly proud of him. From that moment I realized that my little boy
-- had become a man. Prioritizing a job above messing around with his friends. I then asked him: Son, was there any
-- change? He replied "Yes, About three fiddy." which he refused to give back. It was about that time I realized my son
-- was a 7 stories tall crustacean from the paleolithic era. That damn loch ness Monster had gotten me again. Damnit,
-- monsta, you ain’t getting no three fiddy. tl;dr. Son wanted to borrow money, was for serious stuff instead of booze.
-- Edit: Fuck you whoever gave me gold, be ashamed."


-- Let us look at some characteristics of the Top 20 scored comments 

SELECT top_20.id, top_20.score, com.'body'
	FROM (SELECT com.id, s.score
			FROM "comment" as com, score as s
			WHERE s.id = com.id 
			ORDER BY s.score DESC
			LIMIT 20) as top_20, "comment" as com, score as s, is_distinguished as d
	WHERE s.id = top_20.id 
	AND com.id = top_20.id 
	AND d.id = top_20.id
	ORDER BY top_20.score DESC;

-- After building the wordcloud of common words in Python, we decide to look at some statistics related to the 
-- most occuring words 

CREATE INDEX idx_comments_body on "comment"('body');

SELECT COUNT(com.id), AVG(s.score), MAX(s.score), MIN(s.score)
	FROM 'comment' as com, score as s
	WHERE s.id = com.id 
	AND com.'body' LIKE '%wood%' ;
	
SELECT COUNT(com.id), AVG(s.score), MAX(s.score), MIN(s.score)
	FROM 'comment' as com, score as s
	WHERE s.id = com.id 
	AND com.'body' LIKE '%fuck%' ;
	
SELECT COUNT(com.id), AVG(s.score), MAX(s.score), MIN(s.score)
	FROM 'comment' as com, score as s
	WHERE s.id = com.id 
	AND com.'body' LIKE '%asian%' ;
	
SELECT COUNT(com.id), AVG(s.score), MAX(s.score), MIN(s.score)
	FROM 'comment' as com, score as s
	WHERE s.id = com.id 
	AND com.'body' LIKE '%chink%' ;
	
SELECT COUNT(com.id), AVG(s.score), MAX(s.score), MIN(s.score)
	FROM 'comment' as com, score as s
	WHERE s.id = com.id 
	AND com.'body' LIKE '%attack%' ;

SELECT COUNT(com.id), AVG(s.score), MAX(s.score), MIN(s.score)
	FROM 'comment' as com, score as s
	WHERE s.id = com.id 
	AND com.'body' LIKE '%racial%' ;

SELECT COUNT(com.id), AVG(s.score), MAX(s.score), MIN(s.score)
	FROM 'comment' as com, score as s
	WHERE s.id = com.id 
	AND com.'body' LIKE '%lady%' ;
	
SELECT COUNT(com.id), AVG(s.score), MAX(s.score), MIN(s.score)
	FROM 'comment' as com, score as s
	WHERE s.id = com.id 
	AND com.'body' LIKE '%guy%';


-------------------------------------------------------------------------------------------------------------------
--c.Temporal Analysis
-------------------------------------------------------------------------------------------------------------------

-- We have a hypothesis that maybe the characteristics
-- of a comment depends on the day of the week the comment is posted, so we run the following query 

SELECT strftime('%w',DATETIME(c.created_utc,'unixepoch')) as Weekday,
	AVG(s.score) as score,
	COUNT(c.id) as Total_Comments,
	SUM(s.gilded),
	SUM(c.controversiality)
	FROM "comment" as c, score as s
	WHERE s.id = c.id
	GROUP BY Weekday;
	
-- Our results are further described in the Python Code 


-------------------------------------------------------------------------------------------------------------------
-- Part 4: To go further : Analysis on the comments of the Most Active users
-------------------------------------------------------------------------------------------------------------------

-- Selecting the top 5 users and putting them in a separate 5 MB table
.headers on 
.mode csv
.output Most_Active_Users.csv
 
SELECT com.id, com.'body', com.author, com.controversiality, com.edited,
	   s.score, s.gilded, s.score_hidden, d.distinguished, dep.parent_id
	FROM "comment" as com, score as s, is_distinguished as d, depends as dep,
		(SELECT com.author as name
			FROM "comment" as com 
			WHERE com.author <> "AutoModerator" 
			AND com.author <> "[deleted]"
			GROUP BY com.author
			ORDER BY COUNT(com.id) DESC 
			LIMIT 7) as int_users
	WHERE s.id = com.id 
	AND dep.id = com.id
	AND d.id = com.id 
	AND com.author = int_users.name; 
	
	
-- We now want to create a new database for the chosen active users 
.open active_users.db 

-- Let us import the table we've created 
.mode csv 
.import Most_Active_Users.csv users

-- We want to look at the Average Length of the Comments per user 

SELECT AVG(LENGTH(u.'body')), MIN(LENGTH(u.'body')), MAX(LENGTH(u.'body')), u.author
	FROM users as u
	GROUP BY u.author;

-- We now want to count the Average Number of words, Min and Max number of words for each author 
-- We run the following query 

-- We first create an index for the author AVG(count_words.NumOfWords),

CREATE INDEX index_user_comment on users(author);


-- Then we run the following query 

SELECT u.author , AVG(count_words.NumOfWords), MIN(count_words.NumOfWords), MAX(count_words.NumOfWords)
	FROM users as u, 
	(SELECT u.author,
		CASE WHEN length(u.'body') >= 1
		THEN
			(length(u.'body') - length(replace(u.'body', ' ', '')) + 1)
		ELSE
			(length(u.'body') - length(replace(u.'body', ' ', '')))
		END as NumOfWords
		FROM users as u) as count_words
	WHERE count_words.author = u.author 
	GROUP BY u.author;

-- We are interested in looking at the average scores and other associated characteristics of the comments 
-- of the most active user
SELECT u.author, SUM(u.controversiality) as nbre_controversial, AVG(u.score) as average_score, 
	   MIN(u.score) as min_score, MAX(u.score) as max_score, SUM(u.gilded) as nbre_gilded, SUM(u.score_hidden) as nbre_hidden
	FROM users as u
	GROUP BY u.author; 

-- This is the end of this Script ! :) 
