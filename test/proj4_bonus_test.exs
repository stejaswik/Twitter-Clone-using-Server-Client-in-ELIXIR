defmodule Proj4BonusTest do
use ExUnit.Case, async: true

test "Test1" do

	numUsers = 5
	numTweets = 1

	map = getMap(numUsers, numTweets)

	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 1 : Adding #{numUsers} new users                               |"
	IO.puts "| ==============================                                   |"
	IO.puts "| This test will add new users and check if they are being added   |"
	IO.puts "| correctly into the server                                        |"
	IO.puts "--------------------------------------------------------------------"

	Storepid.start_link(map)

	IO.puts "Creating #{numUsers} users"

	userList = Tuple.to_list(List.first((:ets.lookup(:user_list, "user_list"))))
	IO.inspect(userList)

	length = length(Enum.at(userList, 1))
	IO.puts "Number of users registered on the server: #{length}"

	_x = true

	x = assert length == numUsers

	if x do
		IO.puts "Users got registered succesfully!"

		IO.puts "----------------------------------"
		IO.puts "| Test 1 completed succesfully   |"
		IO.puts "----------------------------------"
	end
end

test "Test2" do

	numUsers = 50
	numTweets = 1

	map = getMap(numUsers, numTweets)

	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 2 : Adding #{numUsers} new users                                |"
	IO.puts "| ==============================                                   |"
	IO.puts "| This test will add new users and check if they are being added   |"
	IO.puts "| correctly into the server                                        |"
	IO.puts "--------------------------------------------------------------------"

	Storepid.start_link(map)

	IO.puts "Creating #{numUsers} users"

	userList = Tuple.to_list(List.first((:ets.lookup(:user_list, "user_list"))))
	IO.inspect(userList)

	length = length(Enum.at(userList, 1))
	IO.puts "Number of users registered on the server: #{length}"

	_x = true

	x = assert length == numUsers

	if x do
		IO.puts "Users got registered succesfully!"

		IO.puts "----------------------------------"
		IO.puts "| Test 2 completed succesfully   |"
		IO.puts "----------------------------------"
	end
end

test "Test3" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 3 : Subscribing to a user                                   |"
	IO.puts "| ================================                                 |"
	IO.puts "| This test will test the user subscription part                   |"
	IO.puts "| If A subscribes to B, B should be in the subscription list of A  |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(2, 1)

	Storepid.start_link(map)

	list = Map.keys(map)
	c1 = Enum.at(list, 0)
	IO.puts "User1 is @#{c1}"

	c2 = Enum.at(list, 1)
	p = Storepid.get_pid(c1)
	IO.puts "User2 is @#{c2}"

	IO.puts "ets registry before subscription:"
	IO.inspect(:ets.lookup(:subscriberList, c2))

	Client.subscribe(p, c2)

	Process.sleep 100

	IO.puts "ets registry after subscription:"
	IO.inspect(:ets.lookup(:subscriberList, c2))

	subname = Tuple.to_list(List.first(:ets.lookup(:subscriberList, c2)))
	name = Enum.at(subname, 1)

	IO.puts "Username @#{c2} subscribed to: @#{name}"
	IO.puts "Subscriber name from ets registry: @#{c1}"

	_x = true

	x = assert name == c1

	Process.sleep 1000

	if x do
		IO.puts "Susbscriber name got updated succesfully!"

		IO.puts "----------------------------------"
		IO.puts "| Test 3 completed succesfully   |"
		IO.puts "----------------------------------"
	end
end

test "Test4" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 4 : Subscribing to a user - Multiple subscribers            |"
	IO.puts "| =======================================================          |"
	IO.puts "| This test will test the user subscription part                   |"
	IO.puts "| If A subscribes to B, B should be in the subscription list of A  |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(5, 1)

	Storepid.start_link(map)

	list = Map.keys(map)
	c1 = Enum.at(list, 0)
	p = Storepid.get_pid(c1)
	IO.puts "User1 : @#{c1}"

	c2 = Enum.at(list, 1)
	IO.puts "User2 : @#{c2}"

	c3 = Enum.at(list, 2)
	IO.puts "User3 : @#{c3}"

	c4 = Enum.at(list, 3)
	IO.puts "User4 is @#{c4}"

	IO.puts "ets registry of #{c2} before subscription:"
	IO.inspect(:ets.lookup(:subscriberList, c2))

	IO.puts "ets registry of #{c3} before subscription:"
	IO.inspect(:ets.lookup(:subscriberList, c3))

	IO.puts "ets registry of #{c4} before subscription:"
	IO.inspect(:ets.lookup(:subscriberList, c4))

	Client.subscribe(p, c2)
	Client.subscribe(p, c3)
	Client.subscribe(p, c4)

	Process.sleep 100

	IO.puts "ets registry after subscription:"
	IO.inspect(:ets.lookup(:subscriberList, c2))

	IO.puts "ets registry after subscription:"
	IO.inspect(:ets.lookup(:subscriberList, c3))

	IO.puts "ets registry after subscription:"
	IO.inspect(:ets.lookup(:subscriberList, c4))

	subname_c2 = Tuple.to_list(List.first(:ets.lookup(:subscriberList, c2)))
	name_c2 = Enum.at(subname_c2, 1)

	subname_c3 = Tuple.to_list(List.first(:ets.lookup(:subscriberList, c3)))
	name_c3 = Enum.at(subname_c3, 1)

	subname_c4 = Tuple.to_list(List.first(:ets.lookup(:subscriberList, c4)))
	name_c4 = Enum.at(subname_c4, 1)

	IO.puts "Username @#{c2} subscribed to: @#{name_c2}"
	IO.puts "Subscriber name from ets registry: @#{c1}"

	IO.puts "Username @#{c3} subscribed to: @#{name_c3}"
	IO.puts "Subscriber name from ets registry: @#{c1}"

	IO.puts "Username @#{c2} subscribed to: @#{name_c4}"
	IO.puts "Subscriber name from ets registry: @#{c1}"	

	# Checking that the followers of c1 are updated correctly
	numSubscribers_c1 = length(List.last(Tuple.to_list(List.first(:ets.lookup(:subscribersOf, c1)))))
	IO.puts "Number of people who followed @#{c1}: 3"
	IO.puts "Number of followers of @#{c1} updated: #{numSubscribers_c1}"

	_x = true

	x = assert name_c2 == c1 && assert name_c2 == c1 && assert name_c2 == c1 && numSubscribers_c1 == 3

	Process.sleep 1000

	if x do
		IO.puts "Susbscriber name got updated succesfully!"

		IO.puts "----------------------------------"
		IO.puts "| Test 4 completed succesfully   |"
		IO.puts "----------------------------------"
	end
end

test "Test5" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 5 : Sending tweet                                           |"
	IO.puts "| ======================                                           |"
	IO.puts "| This test will verify the tweet sending                          |"
	IO.puts "--------------------------------------------------------------------"

	numUsers = 5
	numTweets = 1

	map = getMap(numUsers, numTweets)

	list = Map.keys(map)
	user = Enum.at(list, 0)

	Storepid.start_link(map)

	IO.puts "#{numUsers} users tweeting #{numTweets} tweet each"
	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)
	Process.sleep 1000

	IO.puts "Check if the tweet got updated in the ets registry"
	tweetList = Tuple.to_list(List.first(:ets.lookup(:tweets, user)))
	IO.inspect(tweetList)
	length = length(tweetList)

	_x = true

	x = assert length == numTweets+1

	if x do
		IO.puts "Tweet got updated succesfully!"

		IO.puts "----------------------------------"
		IO.puts "| Test 5 completed succesfully   |"
		IO.puts "----------------------------------"
	end
end

test "Test6" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 6 : Sending tweet - Multiple tweets                         |"
	IO.puts "| ==========================================                       |"
	IO.puts "| This test will verify the tweet sending                          |"
	IO.puts "--------------------------------------------------------------------"

	numUsers = 1
	numTweets = 3

	map = getMap(numUsers, numTweets)

	list = Map.keys(map)
	user = Enum.at(list, 0)

	Storepid.start_link(map)

	IO.puts "#{numUsers} users tweeting #{numTweets} tweet each"
	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)

	Process.sleep 1000

	IO.puts "Check if the tweet got updated in the ets registry:"
	tweetList = List.last(Tuple.to_list(List.first(:ets.lookup(:tweets, user))))
	IO.inspect(tweetList)
	length = length(tweetList)
	IO.inspect(length)

	_x = true

	x = assert length == numTweets

	if x do
		IO.puts "Tweet got updated succesfully!"

		IO.puts "----------------------------------"
		IO.puts "| Test 6 completed succesfully   |"
		IO.puts "----------------------------------"
	end
end

test "Test7" do

	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 7 : Hashtags                                                |"
	IO.puts "| ===================                                              |"
	IO.puts "| This test checks if the hashtags mentioned in the tweet          |"
	IO.puts "| are updated on the server.                                       |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(1, 1)

	Storepid.start_link(map)
	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)
	hashtags = ["#florida", "#gators", "#gator_nights", "#gatorade"]

	Process.sleep 100

	list = Map.keys(map)

	tweet = :ets.lookup(:tweets, Enum.at(list, 0))
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)

	IO.puts "Tweet is:"
	IO.inspect(tweet)

	hashtags_tweet = get_hashtags(tweet, hashtags)

	_y = true

	y = if hashtags_tweet != [] do
		for x<-0..length(hashtags_tweet)-1 do
			hashtag = Enum.at(hashtags_tweet, x)
			if List.first(:ets.lookup(:hashTags, hashtag)) != [] do
				hashtags_ets = Tuple.to_list(List.first(:ets.lookup(:hashTags, hashtag)))
				hashtags_ets = Enum.at(hashtags_ets, 1)

				IO.puts "Tweet on the server with the hashtag #{hashtag}:"
				IO.inspect(hashtags_ets)

				assert tweet == hashtags_ets
			end
		end
	end

	Process.sleep 1000

	if y do
		IO.puts "Tweet with a hashtag is correctly updated on the server and is available while lookup!"

		IO.puts "----------------------------------"
		IO.puts "| Test 7 completed succesfully   |"
		IO.puts "----------------------------------"
	end
end

test "Test8" do

	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 8 : Hashtags - Multiple tweets                              |"
	IO.puts "| =====================================                            |"
	IO.puts "| This test checks if the hashtags mentioned in the tweet          |"
	IO.puts "| are updated on the server.                                       |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(1, 5)

	Storepid.start_link(map)
	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)
	hashtags = ["#florida", "#gators", "#gator_nights", "#gatorade"]

	Process.sleep 100

	list = Map.keys(map)

	tweet = :ets.lookup(:tweets, Enum.at(list, 0))
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)

	IO.puts "------------------------------"
	IO.puts "Tweet list:"
	IO.inspect(tweet)
	IO.puts "------------------------------"

	hashtags_tweet = []
	hashtags_tweet = for x<-0..length(tweet)-1 do
		hashtags_tweet ++ get_hashtags(Enum.at(tweet, x), hashtags)
	end

	hashtags_tweet = Enum.uniq(List.flatten(hashtags_tweet))

	IO.puts "------------------------------"
	IO.puts "Hashtags in tweets are:"
	IO.inspect(hashtags_tweet)
	IO.puts "------------------------------"	

	_y = true

	y = if hashtags_tweet != [] do
		for x<-0..length(hashtags_tweet)-1 do
			hashtag = Enum.at(hashtags_tweet, x)
			if List.first(:ets.lookup(:hashTags, hashtag)) != [] do
				hashtags_ets = Tuple.to_list(List.first(:ets.lookup(:hashTags, hashtag)))
				hashtags_ets = Enum.at(hashtags_ets, 1)

				IO.puts "Tweet on the server with the hashtag #{hashtag}:"
				IO.inspect(hashtags_ets)

				_z = Enum.member?(tweet, hashtags_ets)
				assert z = true
			end
		end
	end

	Process.sleep 1000

	if y do
		IO.puts "Tweets with a particular hashtag are correctly updated on the server and is available while lookup!"

		IO.puts "----------------------------------"
		IO.puts "| Test 8 completed succesfully   |"
		IO.puts "----------------------------------"
	end
end

test "Test9" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 9 : Mentions                                                |"
	IO.puts "| ===================                                              |"
	IO.puts "| This test checks if the usernames mentioned in the tweet         |"
	IO.puts "| are updated in the server.                                       |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(2, 1)

	Storepid.start_link(map)
	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)

	list = Map.keys(map)

	Process.sleep 1000

	tweet = :ets.lookup(:tweets, Enum.at(list, 0))
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)	
	IO.puts "Tweet is: #{tweet}"

	mentions_tweet = List.first(get_mentions(tweet, list))
	IO.puts "User mentioned in the tweet: #{mentions_tweet}"
	_user_tweet = :ets.lookup(:user_mention_tweets, mentions_tweet)

	_y = true

	y = if :ets.lookup(:user_mention_tweets, mentions_tweet) != [] do
		mentions_ets = Tuple.to_list(List.first(:ets.lookup(:user_mention_tweets, mentions_tweet)))

		mentions_ets = Enum.at(mentions_ets, 1)

		mentions_ets = if(is_list(mentions_ets)) do
			mentions_ets = for itr<-0..length(mentions_ets) do
				if Enum.at(mentions_ets, itr) == tweet do
					_mentions_ets = Enum.at(mentions_ets, itr)
				end
			end

			mentions_ets = Enum.filter(mentions_ets, fn v -> v != nil end)
			List.first(mentions_ets)
		end

		IO.puts "Tweet on the server with user mention:"
		IO.inspect(mentions_ets)

		_y = if mentions_ets != nil do
			assert tweet == mentions_ets
		end

		Process.sleep 1000
	end

	if y do
		IO.puts "Tweet with an user mentioned is correctly updated on the server and 
				 is available while lookup!"

		IO.puts "----------------------------------"
		IO.puts "| Test 9 completed succesfully   |"
		IO.puts "----------------------------------"
	end
end

test "Test10" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 10 : Mentions - in multiple tweets                          |"
	IO.puts "| ========================================                         |"
	IO.puts "| This test checks if the usernames mentioned in the tweet         |"
	IO.puts "| are updated on the server.                                       |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(2, 5)

	Storepid.start_link(map)
	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)

	list = Map.keys(map)

	Process.sleep 1000

	tweet = :ets.lookup(:tweets, Enum.at(list, 0))
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)	

	IO.puts "------------------------------"
	IO.puts "Tweet list:"
	IO.inspect(tweet)
	IO.puts "------------------------------"

	mentions_tweet = []
	mentions_tweet = for x<-0..length(tweet)-1 do
		mentions_tweet ++ get_mentions(Enum.at(tweet, x), list)
	end

	mentions_tweet = Enum.uniq(List.flatten(mentions_tweet))

	IO.puts "------------------------------"
	IO.puts "Users mentioned in the tweets are:"
	IO.inspect(mentions_tweet)
	IO.puts "------------------------------"	

	_y = true

	y = if :ets.lookup(:user_mention_tweets, Enum.at(list, 0)) != [] do
			mentions_ets = Tuple.to_list(List.first(:ets.lookup(:user_mention_tweets, Enum.at(list, 0))))
			mentions_ets = Enum.at(mentions_ets, 1)

			IO.puts "Tweets with above mentions:"
			IO.inspect(mentions_ets)
			mentions_ets = if(is_list(mentions_ets)) do
				mentions_ets = for itr<-0..length(mentions_ets) do
					if Enum.at(mentions_ets, itr) == tweet do
						_mentions_ets = Enum.at(mentions_ets, itr)
					end
				end

				mentions_ets = Enum.filter(mentions_ets, fn v -> v != nil end)
				List.first(mentions_ets)
			end

			_z = Enum.member?(tweet, mentions_ets)
			assert z = true

			Process.sleep 1000
	end

	if y do
		IO.puts "Tweet with an user mentioned is correctly updated on the server and 
				 is available while lookup!"

		IO.puts "----------------------------------"
		IO.puts "| Test 10 completed succesfully  |"
		IO.puts "----------------------------------"
	end
end

test "Test11" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 11 : Query tweets - subscribed to                           |"
	IO.puts "| ======================================                           |"
	IO.puts "| This test will query for the tweets which a user is              |"
	IO.puts "| subscribed to                                                    |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(2, 1)

	Storepid.start_link(map)

	list = Map.keys(map)

	c1 = Enum.at(list, 0)
	c2 = Enum.at(list, 1)

	IO.puts "User1 is @#{c1}"
	IO.puts "User2 is @#{c2}"

	p = Storepid.get_pid(c1)

	#c2 is following c1
	Client.subscribe(p, c2) 
	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)

	Process.sleep 1000

	l = :ets.lookup(:subscriberList, c2)
	l = List.first(l)

	_y = true

	y = if l != [] do
		l = Tuple.to_list(l)
		subList = l -- [c2]

		subscriber = Enum.random(subList)

        # when you query tweets of c1, they should match with above
        IO.puts "Tweet by user @#{c1}:"
		tweet = :ets.lookup(:tweets, c1)
		tweet = Tuple.to_list(List.first(tweet))
		tweet = Enum.at(tweet, 1)
		IO.inspect(tweet)

		assert Client.query_tweets_subscriber(Storepid.get_pid(c2), subscriber) == :ok
	end

	Process.sleep 1000

	if y do
		IO.puts "User successfully queried the tweet of an user he/she is subscribed to!"

		IO.puts "----------------------------------"
		IO.puts "| Test 11 completed succesfully  |"
		IO.puts "----------------------------------"
	end
end

test "Test12" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 12 : Query tweets - subscribed to - Multiple subscribers    |"
	IO.puts "| ==============================================================   |"
	IO.puts "| This test will query for the tweets which a user is              |"
	IO.puts "| subscribed to                                                    |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(5, 1)

	Storepid.start_link(map)

	list = Map.keys(map)

	c1 = Enum.at(list, 0)
	c2 = Enum.at(list, 1)
	c3 = Enum.at(list, 2)
	c4 = Enum.at(list, 3)

	IO.puts "User1 is @#{c1}"
	IO.puts "User2 is @#{c2}"
	IO.puts "User3 is @#{c3}"
	IO.puts "User4 is @#{c4}"

	p = Storepid.get_pid(c1)

	#c2 is following c1
	Client.subscribe(p, c2)
	#c3 is following c1
	Client.subscribe(p, c3)
	#c4 is following c1
	Client.subscribe(p, c4)

	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)

	Process.sleep 1000

	subs = [c2] ++ [c3] ++ [c4]
	_y = true
	IO.puts "--------------------------------"
	IO.puts "Querying tweets of subscriptions"
	IO.puts "--------------------------------"
	y = for sub<-0..length(subs)-1 do

		l = :ets.lookup(:subscriberList, Enum.at(subs, sub))
		l = List.first(l)

		if l != [] do
			l = Tuple.to_list(l)
			subList = l -- [Enum.at(subs, sub)]

			subscriber = Enum.random(subList)

	        # when you query tweets of c1, they should match with above
	        IO.puts "Tweet by user @#{c1}:"
			tweet = :ets.lookup(:tweets, c1)
			tweet = Tuple.to_list(List.first(tweet))
			tweet = Enum.at(tweet, 1)
			IO.inspect(tweet)

			assert Client.query_tweets_subscriber(Storepid.get_pid(Enum.at(subList, sub)), subscriber) == :ok
		end
	end

	Process.sleep 1000

	if y do
		IO.puts "User successfully queried the tweet of an user he/she is subscribed to!"

		IO.puts "----------------------------------"
		IO.puts "| Test 12 completed succesfully  |"
		IO.puts "----------------------------------"
	end
end

test "Test13" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 13 : Query tweets - with specific hashtag                   |"
	IO.puts "| ===============================================                  |"
	IO.puts "| This test will query for the tweets with a specific hashtag      |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(1, 1)

	Storepid.start_link(map)
	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)
	hashtags = ["#florida", "#gators", "#gator_nights", "#gatorade"]

	Process.sleep 100

	list = Map.keys(map)

	tweet = :ets.lookup(:tweets, Enum.at(list, 0))
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)
	IO.puts "Tweet by user @#{Enum.at(list, 0)}:"
	IO.inspect(tweet)

	hashtags_tweet = get_hashtags(tweet, hashtags)

	IO.puts "Hashtags in tweet are:"
	IO.inspect(hashtags_tweet)

	_y = true

	y = if hashtags_tweet != [] do
		hashtag = Enum.random(hashtags_tweet)
		assert Client.query_tweets_hashtag(Storepid.get_pid(Enum.at(list, 0)), hashtag) == :ok
	end

	Process.sleep 1000

	if y do
		IO.puts "User successfully queried the tweet of a particular hashtag!"

		IO.puts "----------------------------------"
		IO.puts "| Test 13 completed succesfully  |"
		IO.puts "----------------------------------"
	end
end

test "Test14" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 14 : Query tweets - with specific hashtag                   |"
	IO.puts "| ===============================================                  |"
	IO.puts "| This test will query for the tweets with a specific hashtag      |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(1, 10)

	Storepid.start_link(map)
	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)
	hashtags = ["#florida", "#gators", "#gator_nights", "#gatorade"]

	Process.sleep 100

	list = Map.keys(map)

	tweet = :ets.lookup(:tweets, Enum.at(list, 0))
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)
	IO.puts "Tweet list by user @#{Enum.at(list, 0)}:"
	IO.inspect(tweet)

	hashtags_tweet = []
	hashtags_tweet = for x<-0..length(tweet)-1 do
		hashtags_tweet ++ get_hashtags(Enum.at(tweet, x), hashtags)
	end

	hashtags_tweet = Enum.uniq(List.flatten(hashtags_tweet))

	IO.puts "Hashtags in tweet are:"
	IO.inspect(hashtags_tweet)

	_y = true

	y = if hashtags_tweet != [] do
		hashtag = Enum.random(hashtags_tweet)
		assert Client.query_tweets_hashtag(Storepid.get_pid(Enum.at(list, 0)), hashtag) == :ok
	end

	Process.sleep 1000

	if y do
		IO.puts "User successfully queried the tweet of a particular hashtag!"

		IO.puts "----------------------------------"
		IO.puts "| Test 14 completed succesfully  |"
		IO.puts "----------------------------------"
	end
end

test "Test15" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 15 : Query tweets - with user mentions                     |"
	IO.puts "| ==========================================                       |"
	IO.puts "| This test will query for the tweets having user mentions         |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(2, 1)
	list = Map.keys(map)
	#c1 = Enum.at(list, 0)
	#c2 = Enum.at(list, 1)

	Storepid.start_link(map)
	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)

	Process.sleep 100

	tweet = :ets.lookup(:tweets, Enum.at(list, 0))
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)
	IO.puts "Tweet by user @#{Enum.at(list, 0)}:"
	IO.inspect(tweet)

	mentions_tweet = get_mentions(tweet, list)

	IO.puts "Users mentions in tweet are:"
	IO.inspect(mentions_tweet)

	_y = true

	y = if mentions_tweet != [] do
		mention = Enum.random(mentions_tweet)
		assert Client.query_tweets_mention(Storepid.get_pid(mention)) == :ok
	end

	Process.sleep 1000

	if y do
		IO.puts "User successfully queried the tweet in which he/she is mentioned!"

		IO.puts "----------------------------------"
		IO.puts "| Test 15 completed succesfully  |"
		IO.puts "----------------------------------"
	end
end

test "Test16" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 16 : Query tweets - with user mentions                      |"
	IO.puts "| ============================================                     |"
	IO.puts "| This test will query for the tweets having user mentions         |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(1, 10)
	list = Map.keys(map)
	#c1 = Enum.at(list, 0)

	Storepid.start_link(map)
	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)

	Process.sleep 1000

	tweet = :ets.lookup(:tweets, Enum.at(list, 0))
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)
	IO.puts "Tweets by user @#{Enum.at(list, 0)}:"
	IO.inspect(tweet)

	mentions_tweet = []
	mentions_tweet = for x<-0..length(tweet)-1 do
		mentions_tweet ++ get_mentions(Enum.at(tweet, x), list)
	end

	mentions_tweet = Enum.uniq(List.flatten(mentions_tweet))

	IO.puts "Users mentions in tweet are:"
	IO.inspect(mentions_tweet)

	_y = true

	y = if mentions_tweet != [] do
		mention = Enum.random(mentions_tweet)
		assert Client.query_tweets_mention(Storepid.get_pid(mention)) == :ok
	end

	Process.sleep 1000

	if y do
		IO.puts "User successfully queried the tweet in which he/she is mentioned!"

		IO.puts "----------------------------------"
		IO.puts "| Test 16 completed succesfully |"
		IO.puts "----------------------------------"
	end
end

test "Test17" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 17 : Retweet - from subscriptions                           |"
	IO.puts "|========================================                          |"
	IO.puts "| This test will test the retweet feature                          |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(2, 1)

	Storepid.start_link(map)
	list = Map.keys(map)

	c1 = Enum.at(list, 0)
	c2 = Enum.at(list, 1)
	IO.puts "User1 is @#{c1}"
	IO.puts "User2 is @#{c2}"

	p = Storepid.get_pid(c1)
	Client.subscribe(p, c2)
	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)
	Process.sleep 1000

	tweet = :ets.lookup(:tweets, c1)
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)
	IO.puts "Tweet by user @#{c1}:"
	IO.inspect(tweet)

	Client.retweet(Storepid.get_pid(c2), 0)
	Process.sleep 1000

	retweet = :ets.lookup(:tweets, c2)
	retweet = Tuple.to_list(List.first(retweet))
	retweet = Enum.at(retweet, 1)
	# if(is_list(retweet)) do
	# 	retweet = Enum.at(retweet, 1)	
	# end
	IO.puts "Retweet on the server:"
	IO.inspect retweet

	_y = true

	y = assert tweet = retweet

	if y do
		IO.puts "Retweet from subscriptions verified!"

		IO.puts "----------------------------------"
		IO.puts "| Test 17 completed succesfully  |"
		IO.puts "----------------------------------"
	end
end

test "Test18" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 18 : Retweet - from subscriptions - cascaded retweets       |"
	IO.puts "|========================================                          |"
	IO.puts "| This test will test the retweet feature                          |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(3, 1)

	Storepid.start_link(map)
	list = Map.keys(map)

	c1 = Enum.at(list, 0)
	c2 = Enum.at(list, 1)
	c3 = Enum.at(list, 2)

	IO.puts "User1 is @#{c1}"
	IO.puts "User2 is @#{c2}"
	IO.puts "User3 is @#{c3}"

	p1 = Storepid.get_pid(c1)
	p2 = Storepid.get_pid(c2)
	p3 = Storepid.get_pid(c3)

	Client.subscribe(p1, c2)
	Client.subscribe(p2, c3)

	Client.tweeting(p1)
	Process.sleep 3000

	tweet = :ets.lookup(:tweets, c1)
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)
	IO.puts "Tweet by user @#{c1}:"
	IO.inspect(tweet)

	Client.retweet(p2 , 0)
	Process.sleep 5000

	retweet_c2 = :ets.lookup(:tweets, c2)
	retweet_c2 = Tuple.to_list(List.first(retweet_c2))
	retweet_c2 = Enum.at(retweet_c2, 1)
	# retweet = if(is_list(retweet)) do
	# 	retweet = Enum.at(retweet, 1)	
	# end
	IO.puts "Retweet by @#{c2}:"
	IO.inspect List.first(retweet_c2)

	Client.retweet(p3 , 0)
	Process.sleep 3000

	retweet_c3 = :ets.lookup(:tweets, c3)
	retweet_c3 = Tuple.to_list(List.first(retweet_c3))
	retweet_c3 = Enum.at(retweet_c3, 1)
	IO.puts "Retweet by @#{c3}:"
	IO.inspect List.first(retweet_c3)

	_y = true

	y = assert tweet = retweet_c3

	if y do
		IO.puts "Retweet from subscriptions verified!"

		IO.puts "----------------------------------"
		IO.puts "| Test 18 completed succesfully  |"
		IO.puts "----------------------------------"
	end
end

test "Test19" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 19 : Retweet - from mentions                                |"
	IO.puts "|========================================                          |"
	IO.puts "| This test will test the retweet feature                          |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(2, 1)

	Storepid.start_link(map)
	list = Map.keys(map)

	c1 = Enum.at(list, 0)
	c2 = Enum.at(list, 1)

	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)
	Process.sleep 1000

	tweet = :ets.lookup(:tweets, c1)
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)
	IO.puts "Tweet by user @#{c1}:"
	IO.inspect(tweet)

	tweet_mentions = get_mentions(tweet, list)
	tweet_mentions = tweet_mentions -- [c1]

	_y = true 

	y = if tweet_mentions != [] do
		Client.retweet(Storepid.get_pid(c2), 1)
		Process.sleep 1000

		retweet = :ets.lookup(:tweets, c2)
		retweet = Tuple.to_list(List.first(retweet))
		retweet = Enum.at(retweet, 1)
		if is_list(retweet) do
			_retweet = Enum.at(retweet, 1)
		end
		IO.puts "Retweet on the server:"
		IO.inspect retweet

		assert tweet = retweet
	end

	if y do
		IO.puts "Retweet from mentions verified!"

		IO.puts "-----------------------------------"
		IO.puts "| Test 19 completed succesfully   |"
		IO.puts "-----------------------------------"
	end
end

test "Test20" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 20 : Retweet - from mentions                                |"
	IO.puts "|========================================                          |"
	IO.puts "| This test will test the retweet feature                          |"
	IO.puts "--------------------------------------------------------------------"

	map = getMap(3, 1)

	Storepid.start_link(map)
	list = Map.keys(map)

	c1 = Enum.at(list, 0)
	c2 = Enum.at(list, 1)
	c3 = Enum.at(list, 2)

	p1 = Storepid.get_pid(c1)
	p3 = Storepid.get_pid(c3)

	Client.subscribe(p3, c2)
	Client.subscribe(p1, c3)
	Client.subscribe(p1, c2)

	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)
	Process.sleep 1000

	tweet = :ets.lookup(:tweets, c1)
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)
	IO.puts "Tweet by user @#{c1}: #{tweet}\n"
	#IO.inspect(tweet)

	tweet_mentioned_c3 = get_mentions(tweet, [c3])

	_y = true

	y = if tweet_mentioned_c3 != [] do
		IO.puts "Tweet of @#{c1} in which @#{c3} is mentioned: #{tweet}\n"
		Client.retweet(p3, 1)
		Process.sleep 1000

		retweet = :ets.lookup(:tweets, c3)
		retweet = Tuple.to_list(List.first(retweet))
		retweet = Enum.at(retweet, 1)
		if is_list(retweet) do
			_retweet = Enum.at(retweet, 1)
		end
		IO.puts "Retweet on the server: #{retweet}\n"

		assert tweet = retweet
	end

	if y do
		IO.puts "Retweet from mentions verified!"

		IO.puts "-----------------------------------"
		IO.puts "| Test 20 completed succesfully   |"
		IO.puts "-----------------------------------"
	end
end

test "Test21" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 21 : Testing all the functionalities together               |"
	IO.puts "|===================================================               |"
	IO.puts "| This test will test all the twitter functionalities implemented  |"
	IO.puts "--------------------------------------------------------------------"

	numUsers = 5
	numTweets = 1

	map = getMap(numUsers, numTweets)

	# Register Users
	Storepid.start_link(map)

	IO.puts "Creating #{numUsers} users"

	Process.sleep 200

	userList = Tuple.to_list(List.first((:ets.lookup(:user_list, "user_list"))))
	IO.inspect(userList)

	length = length(Enum.at(userList, 1))
	IO.puts "Number of users registered on the server: #{length}"

	assert length == numUsers

	# Subscribing to users
	list = Map.keys(map)
	c1 = Enum.at(list, 0)
	IO.puts "User1 is @#{c1}"

	c2 = Enum.at(list, 1)
	p = Storepid.get_pid(c1)
	IO.puts "User2 is @#{c2}"

	IO.puts "ets registry before subscription:"
	IO.inspect(:ets.lookup(:subscriberList, c2))

	Client.subscribe(p, c2)

	Process.sleep 1000

	IO.puts "ets registry after subscription:"
	IO.inspect(:ets.lookup(:subscriberList, c2))

	subname = Tuple.to_list(List.first(:ets.lookup(:subscriberList, c2)))
	name = Enum.at(subname, 1)

	IO.puts "Username @#{c2} subscribed to: @#{name}"
	IO.puts "Subscriber name from ets registry: @#{c1}"

	assert name == c1

	# Sending Tweets
	IO.puts "#{numUsers} users tweeting #{numTweets} tweet each"
	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)
	Process.sleep 1000

	# Check if the tweet got updated on the server
	IO.puts "Check if the tweet got updated in the ets registry"
	tweetList = Tuple.to_list(List.first(:ets.lookup(:tweets, c1)))
	IO.inspect(tweetList)
	length = length(tweetList)

	assert length == 2

	# Check if the hashtags in the tweet are updated
	hashtags = ["#florida", "#gators", "#gator_nights", "#gatorade"]

	Process.sleep 1000

	list = Map.keys(map)

	tweetList = []
	tweetList = for x<-0..length(list)-1 do
		tweetList ++ List.last(Tuple.to_list(List.first(:ets.lookup(:tweets, Enum.at(list, x)))))
	end

	IO.puts "------------------------------"
	IO.puts "Tweet list:"
	IO.inspect(tweetList)
	IO.puts "------------------------------"

	hashtags_tweet = []
	hashtags_tweet = for x<-0..length(tweetList)-1 do
		hashtags_tweet ++ get_hashtags(Enum.at(tweetList, x), hashtags)
	end

	hashtags_tweet = Enum.uniq(List.flatten(hashtags_tweet))

	IO.puts "------------------------------"
	IO.puts "Hashtags in tweets are:"
	IO.inspect(hashtags_tweet)
	IO.puts "------------------------------"	

	_y = true

	_y = if hashtags_tweet != [] do
		for x<-0..length(hashtags_tweet)-1 do
			hashtag = Enum.at(hashtags_tweet, x)
			if List.first(:ets.lookup(:hashTags, hashtag)) != [] do
				hashtags_ets = Tuple.to_list(List.first(:ets.lookup(:hashTags, hashtag)))
				hashtags_ets = Enum.at(hashtags_ets, 1)

				IO.puts "Tweets on the server with the hashtag #{hashtag}:"
				IO.inspect(hashtags_ets)

				_z = Enum.member?(tweetList, hashtags_ets)
				assert z = true
			end
		end
	end

	assert y = true

	# Check if the mentions in the tweet are updated
	tweetList = []
	tweetList = for x<-0..length(list)-1 do
		tweetList ++ List.last(Tuple.to_list(List.first(:ets.lookup(:tweets, Enum.at(list, x)))))
	end

	IO.puts "------------------------------"
	IO.puts "Tweet list:"
	IO.inspect(tweetList)
	IO.puts "------------------------------"

	mentions_tweet = []
	mentions_tweet = for x<-0..length(tweetList)-1 do
		mentions_tweet ++ get_mentions(Enum.at(tweetList, x), list)
	end

	mentions_tweet = Enum.uniq(List.flatten(mentions_tweet))

	IO.puts "------------------------------"
	IO.puts "Users mentioned in the tweets are:"
	IO.inspect(mentions_tweet)
	IO.puts "------------------------------"	

	_y = true

	_y = if mentions_tweet != [] do
		for x<-0..length(mentions_tweet)-1 do
			mention = Enum.at(mentions_tweet, x)
			#if List.first(:ets.lookup(:user_mention_tweets, Enum.at(list, x))) != [] do
			if :ets.lookup(:user_mention_tweets, Enum.at(list, x)) != [] do
				mention_ets = Tuple.to_list(List.first(:ets.lookup(:user_mention_tweets, Enum.at(list, x))))
				mention_ets = Enum.at(mention_ets, 1)

				IO.puts "Tweets on the server with the user mention #{mention}:"
				IO.inspect(mention_ets)

				_z = Enum.member?(tweetList, mention_ets)
				assert z = true
			end
		end
	end

	assert y = true

	# Query tweet - subscribed to
	IO.puts "\nQuerying tweets of people the user is subscribed to:"
	l = :ets.lookup(:subscriberList, c2)
	l = List.first(l)

	_y = true

	_y = if l != [] do
		l = Tuple.to_list(l)
		subList = l -- [c2]

		subscriber = Enum.random(subList)

        # when you query tweets of c1, they should match with above
		tweet = :ets.lookup(:tweets, c1)
		tweet = Tuple.to_list(List.first(tweet))
		tweet = Enum.at(tweet, 1)
		IO.inspect(tweet)

		assert Client.query_tweets_subscriber(Storepid.get_pid(c2), subscriber) == :ok
	end

	# Query tweet - with a specific hashtag
	user = Enum.random(list)
	tweet = :ets.lookup(:tweets, user)
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)

	hashtags_tweet = get_hashtags(tweet, hashtags)

	_y = true

	_y = if hashtags_tweet != [] do
		hashtag = Enum.random(hashtags_tweet)
		assert Client.query_tweets_hashtag(Storepid.get_pid(user), hashtag) == :ok
	end

	Process.sleep 1000

	# Query tweet - with user mention
	mentions_tweet = get_mentions(tweet, list)

	IO.puts "Users mentions in tweet are:"
	IO.inspect(mentions_tweet)

	_y = true

	_y = if mentions_tweet != [] do
		mention = Enum.random(mentions_tweet)
		assert Client.query_tweets_mention(Storepid.get_pid(mention)) == :ok
	end

	assert y = true

	# Retweet - from subscriptions
	tweet = :ets.lookup(:tweets, c1)
	tweet = Tuple.to_list(List.first(tweet))
	tweet = Enum.at(tweet, 1)
	IO.puts "Tweet by user @#{c1}:"
	IO.inspect(tweet)

	Client.retweet(Storepid.get_pid(c2), 0)
	Process.sleep 1000

	retweet = :ets.lookup(:tweets, c2)
	retweet = Tuple.to_list(List.first(retweet))
	retweet = Enum.at(retweet, 1)
	# if(is_list(retweet)) do
	# 	retweet = Enum.at(retweet, 1)	
	# end
	IO.puts "Retweet on the server:"
	IO.inspect List.last(retweet)

	IO.puts "-----------------------------------"
	IO.puts "| Test 21 completed succesfully   |"
	IO.puts "-----------------------------------"	
end

test "Test22" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 22 : Delete User                                            |"
	IO.puts "|========================================                          |"
	IO.puts "| This test will test the delete user functionality. When a user   |"
	IO.puts "| account is deleted, the server removes the traces of the user    |"
	IO.puts "| tweets, retweets, followers, mentions, susbcriptions, hashtags.  |"
	IO.puts "--------------------------------------------------------------------"

	numUsers = 4
	numTweets = 1

	map = getMap(numUsers, numTweets)
	IO.inspect map
	
	Storepid.start_link(map)

	list = Map.keys(map)
	c1 = Enum.at(list, 0)
	IO.puts "User1 is @#{c1}"

	c2 = Enum.at(list, 1)
	p1 = Storepid.get_pid(c1)
	IO.puts "User2 is @#{c2}"

	c3 = Enum.at(list, 2)
	p3 = Storepid.get_pid(c3)
	IO.puts "User3 is @#{c3}"

	IO.inspect(:ets.lookup(:user_list, "user_list"),label: "Registration list")
	reg_length_before = length(List.last(Tuple.to_list(List.first(:ets.lookup(:user_list, "user_list")))))
	IO.inspect(reg_length_before, label: "reg_length_before")

	Client.subscribe(p1, c2)
	Process.sleep(1000)

	Client.subscribe(p3, c2)
	Process.sleep(1000)

	IO.inspect(:ets.lookup(:subscriberList, c2),label: "subscriber list of User @#{c2} before deletion")
	sub_length_before = length(List.last(Tuple.to_list(List.first(:ets.lookup(:subscriberList, c2)))))
	IO.inspect(sub_length_before, label: "sub_length_before")

	Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)

	Process.sleep(200)

	Client.deleteAccount(c1)

	Process.sleep(1000)
	IO.inspect(:ets.lookup(:user_list, "user_list"),label: "Registration list after account deletion")
	reg_length_after = length(List.last(Tuple.to_list(List.first(:ets.lookup(:user_list, "user_list")))))
	IO.inspect(reg_length_after, label: "reg_length_after")

	Process.sleep(200)
	IO.inspect(:ets.lookup(:subscriberList, c2),label: "subscriber list of User @#{c2} after deletion")
	sub_length_after = length(List.last(Tuple.to_list(List.first(:ets.lookup(:subscriberList, c2)))))
	IO.inspect(sub_length_after, label: "sub_length_after")

	Process.sleep(200)

	assert reg_length_before = reg_length_after + 1
	assert sub_length_before = sub_length_after + 1

	IO.puts "-----------------------------------"
	IO.puts "| Test 22 completed succesfully   |"
	IO.puts "-----------------------------------"	
end

test "Test23" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 23 : Login - Logout                                         |"
	IO.puts "|========================================                          |"
	IO.puts "| This test will test the login and logout functionalities         |"
	IO.puts "| User receives notifications when the login is true               |"
	IO.puts "--------------------------------------------------------------------"

	numUsers = 20
	numTweets = 1

	map = getMap(numUsers, numTweets)
	IO.inspect map
	
	Storepid.start_link(map)

	list = Map.keys(map)
	c1 = Enum.at(list, 0)
	IO.puts "User1 is @#{c1}"

	c2 = Enum.at(list, 1)
	p = Storepid.get_pid(c1)
	IO.puts "User2 is @#{c2}"

	IO.puts "ets registry before subscription:"
	IO.inspect(:ets.lookup(:subscriberList, c2))

	Client.subscribe(p, c2)

	Process.sleep 1000

	IO.puts "@#{c2} logging out"
	Client.loginLogout(c2)
	Process.sleep 1000

	IO.puts "when @#{c2} is logged out, it won't receie the notification"
	Client.tweeting(Storepid.get_pid(c1))

	IO.puts "@#{c2} logging in"
	Client.loginLogout(c2)
	Process.sleep 1000

	IO.puts "when @#{c2} is logged in, it will receive the notification"
	Client.tweeting(Storepid.get_pid(c1))

	IO.puts "-----------------------------------"
	IO.puts "| Test 23 completed succesfully   |"
	IO.puts "-----------------------------------"	
end

test "Test24" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 24 : Zipf distribution for subscription                     |"
	IO.puts "|========================================                          |"
	IO.puts "| This test will test the zipf distribution effect on performance. |"
	IO.puts "--------------------------------------------------------------------"

	numUsers = 10
	numTweets = 5

	map = getMap(numUsers, numTweets)
	#IO.inspect map
	usernames = Map.keys(map)
	
	Storepid.start_link(map)

	s = numUsers
	zipf = Enum.map(Enum.map(1..numUsers, fn(i) -> round(Float.floor(s/(numUsers-i+1)))-1 end), fn(x) -> if(x>0) do x else 0 end end)

	IO.inspect(usernames, label: "usernames in order")
	IO.inspect(zipf, label: "zipf subscription for users")
	IO.puts "\n"

	for i <- 0..numUsers-1 do
	  if (Enum.at(zipf,i) > 0) do
	    c2 = Enum.at(usernames,i)
	    subList = usernames -- [c2]
	    subscriber = Enum.take_random(subList,Enum.at(zipf,i))
	    for sub <- subscriber do
	              Client.subscribe(Storepid.get_pid(c2), sub) 
	            end
	  end
	end

	Process.sleep 100

	IO.puts "-----------------------------------"
	IO.puts "| Test 24 completed succesfully   |"
	IO.puts "-----------------------------------"
end


def getMap(numUsers, numMsg) do

	# Generate unique usernames
	map_set = MapSet.new
	map_set = Randomizer.generate_unique_usernames(numUsers,map_set)
	usernames = MapSet.to_list(map_set)    

	# server name
	serverName = Boss_Server

	# hashtags
	hashtags = ["#florida", "#gators", "#gator_nights", "#gatorade"]

	input = [usernames] ++ [hashtags] ++ [serverName] ++ [numMsg]

	Server.start_link([[usernames] ++ [hashtags]])

	# Starting twitter supervisor
	# input has usernames and servername
	{:ok, pid} = Twitter_Supervisor.start_link(input)
	c = Supervisor.which_children(pid)
	c = Enum.sort(c)

	len = length(c)-1
	map = %{}
	map = Enum.map(0..len, fn i ->
	head = Enum.at(c,i)
	h_list = Tuple.to_list(head)
	key = Enum.at(h_list,0)
	val = Enum.at(h_list,1)
	Map.put(map,key,val)
	end)

	map = Enum.reduce(map,fn(x,acc) -> Map.merge(x,acc,fn _k,v1,v2 -> [v1,v2] end) end)
	map
end

def get_hashtags(tweet, hashtags) do
	hashtags_tweet = []
	hashtags_tweet = for x<-0..length(hashtags)-1 do
	_hashtags_tweet = if tweet =~ Enum.at(hashtags, x) do
			_hashtags_tweet = hashtags_tweet ++ Enum.at(hashtags, x)
		end
	end
	hashtags_tweet = Enum.filter(hashtags_tweet, fn v -> v != nil end)
	hashtags_tweet
end

def get_mentions(tweet, users) do
	mentions_tweet = []
	mentions_tweet = for x<-0..length(users)-1 do
	_mentions_tweet = if tweet =~ Enum.at(users, x) do
			_mentions_tweet = mentions_tweet ++ Enum.at(users, x)
		end
	end
	mentions_tweet = Enum.filter(mentions_tweet, fn v -> v != nil end)
	mentions_tweet
end

end


