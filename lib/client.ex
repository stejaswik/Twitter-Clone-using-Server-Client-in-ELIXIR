# Twitter Supervisor 
defmodule Twitter_Supervisor do
  use Supervisor

  def start_link(input) do
    Supervisor.start_link(__MODULE__, input)
  end

  def init(input) do
    serverName = Enum.at(input, 2)
    userNames = Enum.at(input, 0)
    hashtags = Enum.at(input, 1)
    numMsg = Enum.at(input, 3)

    children = Enum.map(userNames, fn(worker_id) ->
      worker(Client, [[worker_id] ++ [serverName] ++ [userNames] ++ [hashtags] ++ [numMsg]], [id: worker_id, restart: :permanent])
    end)

    supervise(children, strategy: :one_for_one, name: Supervise_topology)
  end
end

# Twitter Client
defmodule Client do
  use GenServer

  def start_link(list) do
    # IO.inspect(list)
    GenServer.start_link(__MODULE__, list)
  end

  def init(stack) do
    serverName = Enum.at(stack, 1)
    userName = Enum.at(stack, 0)
    userNames = Enum.at(stack, 2)
    hashtags = Enum.at(stack, 3)
    numMsg = Enum.at(stack, 4)
    # Initialize the client map
    userMap = %{}
    userMap = Map.put(userMap, "user", userName)
    userMap = Map.put(userMap, "server", serverName)
    userMap = Map.put(userMap, "userList", userNames)
    userMap = Map.put(userMap, "hashtags", hashtags)
    userMap = Map.put(userMap, "login", 1)
    userMap = Map.put(userMap, "num", numMsg)
    userMap = Map.put(userMap, "subscribers", [])

    stack = userMap

    Server.register_user(Map.get(stack, "server"),Map.get(stack, "user"))
    #Server.print(Map.get(stack, "server"))
    loginLogout(Map.get(stack, "user"))
    {:ok, stack}

  end

  def loginLogout(user) do
    # toggle login/ logout state of an user
    # login -> 1, logout -> 0
    Process.send_after(self(), {:toggle, user}, 2000*Enum.random(10..50))
  end

  def deleteAccount(user) do
    # delete an user account
    GenServer.call(Storepid.get_pid(user), {:delete, user})
  end

  def tweeting(pid) do
    # called when client tweets
    GenServer.cast(pid, {:tweet})
  end

  def subscribe(pid, c2) do
    # called when client c2 subscribes to self()
    GenServer.call(pid, {:subscribe, c2})
  end

  def notification(pid, user, tweet, info) do
    # sends live notification to user 
    # info = 1 -> when they are mentioned in a tweet
    # info = 0 -> when user's subscriptions tweet
    GenServer.cast(pid, {:notification, user, tweet, info})
  end

  def retweet(pid, info) do 
    # called when user retweets
    # info "0" -> to retweet a subscriber's tweet
    # info "1" -> to retweet a tweet in which user is mentioned
    GenServer.cast(pid, {:retweet, info})
  end

  def query_tweets_subscriber(pid, subscriber) do
    # queries subscriber's tweets
    GenServer.cast(pid, {:querytweet, subscriber})
  end

  def query_tweets_hashtag(pid, hashtag) do
    # queries tweets of the mentioned hashtag
    GenServer.cast(pid, {:queryhashtag, hashtag})
  end

  def query_tweets_mention(pid) do
    # queries tweets in which user is mentioned
    GenServer.cast(pid, {:querymention})
  end

  def update_userList(pid, newList) do
    # updates the user list after an account deletion
    GenServer.cast(pid, {:update, newList})
  end

  def handle_info({:toggle, user}, stack) do
    login = Map.get(stack, "login")
    login = if login == 0 do
              IO.puts "-------------------------"
              IO.puts "@#{user} is logged in now"
              IO.puts "-------------------------"
              1
            else
              IO.puts "-------------------------"
              IO.puts "@#{user} logged out"
              IO.puts "-------------------------"
              0
            end

    loginLogout(user)

    stack = Map.put(stack, "login", login)

    {:noreply, stack}
  end

  def handle_cast({:update, newList}, stack) do
    stack = Map.put(stack, "userList", newList)
    #user = Map.get(stack, "user")
    {:noreply, stack}
  end

  def handle_cast({:querymention}, stack) do
    user = Map.get(stack, "user")
    Server.query_tweets_mention(Map.get(stack, "server"), user)
    {:noreply, stack}
  end

  def handle_cast({:queryhashtag, hashtag}, stack) do
    user = Map.get(stack, "user")
    Server.query_tweets_hashtag(Map.get(stack, "server"), user, hashtag)
    {:noreply, stack}
  end

  def handle_cast({:querytweet, user}, stack) do
    subscriber = Map.get(stack, "user")
    Server.query_tweets_subscriber(Map.get(stack, "server"), subscriber, user)
    {:noreply, stack}
  end

  def handle_cast({:retweet, info}, stack) do
    login = Map.get(stack, "login")
    user = Map.get(stack, "user")

    if login == 1 do
      Server.retweet(Map.get(stack, "server"), user, info)
    end
    {:noreply, stack}
  end 

  def handle_cast({:notification, user_generating, tweet, info}, stack) do
    user = Map.get(stack, "user")
    login = Map.get(stack, "login")
    if login == 1 do
      if info == 1 do
        IO.puts("Notification to @#{user}: User @#{user_generating} has mentioned you in tweet < #{tweet} >\n")
      else
        IO.puts("Notification to @#{user}: User @#{user_generating} has tweeted < #{tweet} >\n")
      end
    end
    {:noreply, stack}
  end 

  def handle_cast({:tweet}, stack) do
    login = Map.get(stack, "login")
    stack = if login == 1 do
      hashtags = Map.get(stack, "hashtags")
      usernames = Map.get(stack, "userList")

      map_set = MapSet.new
      strings = Randomizer.generate_unique_usernames(50, map_set)
      strings = MapSet.to_list(strings)

      userLength = length(usernames)
      tweetLength = List.first(Enum.take_random(5..8, 1))
      hashLength = List.first(Enum.take_random(0..tweetLength-2, 1))
      remainingLength = tweetLength-hashLength
      mentionLength = if (userLength < round(remainingLength/2)) do
                        userLength
                      else
                        round(remainingLength/2)
                      end
      stringLength = remainingLength - mentionLength

      hashList = Enum.take_random(hashtags, hashLength)
      mentionList = Enum.take_random(usernames, mentionLength)
      stringList = Enum.take_random(strings, stringLength)
      mentionListNew = Enum.map(mentionList, fn(x) -> "@"<>x end)

      tweet = Enum.shuffle(hashList ++ mentionListNew ++ stringList)
      tweet = Enum.join(tweet, " ")
      user = Map.get(stack, "user")
      IO.puts("User @#{user} tweet: #{tweet}\n")
      Server.sendTweet(Map.get(stack, "server"), user, tweet,  hashList, mentionList)
      msgReq = Map.get(stack, "num")
      msgReq = msgReq - 1
      Map.put(stack, "num", msgReq)
    else
      stack
    end
    if (login == 1) do
      Dispstore.save_node("user")
      msgReq = Map.get(stack, "num")
      if msgReq > 0 do
        tweeting(self())
      end
    end
    {:noreply, stack}
  end

  def handle_call({:subscribe, user2}, _from, stack) do
    sub = Map.get(stack, "subscribers")
    user1 = Map.get(stack, "user")
    list = sub ++ [user2]
    list = List.flatten(list)
    stack = Map.put(stack, "subscribers", list) 
    IO.puts("User @#{user2} is following User @#{user1}\n")
    val = Server.subscribeTo(Map.get(stack, "server"),user1,user2)
    {:reply, val ,stack}
  end

  def handle_call({:delete, user}, _from, stack) do
    stack = Map.put(stack, "login", 0)
    userList = Map.get(stack, "userList")
    newList = userList -- [user]
    for u <- newList do
      update_userList(Storepid.get_pid(u), newList)
    end
    val = Server.delete_user(Map.get(stack, "server"), user)
    IO.puts("User @#{user} is successfully deleted")
    {:reply, val, stack}
  end

end

# Unique usernames generator
defmodule Randomizer do
  def randomizer(length) do
   numbers = "0123456789abcdefghijklmnopqrstuvwxyz"
   lists = numbers |> String.split("", trim: true)
   do_randomizer(length, lists)
  end

  def generate_unique_usernames(numUsers,map_set) do
       if(MapSet.size(map_set) < numUsers) do
           map_set = MapSet.put(map_set,randomizer(10))
           generate_unique_usernames(numUsers,map_set)
       else
           map_set
       end
  end

  defp get_range(length) when length > 1, do: (1..length)
    defp get_range(_), do: [1]

    defp do_randomizer(length, lists) do
       get_range(length)
       |> Enum.reduce([], fn(_, acc) -> [Enum.random(lists) | acc] end)
       |> Enum.join("")
    end

end

# Get number of users as an input from CLI
numUsers = Enum.at(System.argv(),0)
numMsg = Enum.at(System.argv(),1)

numUsers = if numUsers != "test" && numUsers != nil && numUsers != "--trace" do
               String.to_integer(numUsers)
          else
            0
          end

numMsg = if numMsg != "test" && numMsg != nil && numMsg != "--trace" do
               String.to_integer(numMsg)
          else
            0
          end

if numUsers != 0 && numMsg != 0 do

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

Storepid.start_link(map)

s = numUsers
zipf = Enum.map(Enum.map(1..numUsers, fn(i) -> round(Float.floor(s/(numUsers-i+1)))-1 end), fn(x) -> if(x>0) do x else 0 end end)
#IO.inspect(zipf,label: "zipf")

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

Process.sleep(100)

#create a list consisting of total number of hops
parent = self()
convergence_factor = numUsers * numMsg 
start = System.system_time(:millisecond)
diff = 0
quit = [parent]++[diff]++[start]++[convergence_factor]

#send the above created list to Dispstore so that it knows when to quit
Task.start_link(fn ->
    Dispstore.start_link(quit)
end)

# Clients tweeting
Enum.each(Map.keys(map), fn(s) -> Client.tweeting(Storepid.get_pid(s)) end)

# # Deletion of an user account
# IO.inspect(Enum.at(usernames,1))
# Client.deleteAccount(Enum.at(usernames,1))

# Process.sleep(100)
# IO.inspect(:ets.lookup(:user_list, "user_list"))

time_wait = 60_000

#Quit storing when we reach required convergence, otherwise wait till default time
receive do
:work_is_done -> :ok
after
# Optional timeout
time_wait -> :timeout
end
end