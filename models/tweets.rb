require File.dirname(__FILE__) + '/../db_connection.rb'

class Tweet < Sequel::Model
  many_to_one :user

  many_to_one :origin_tweet, :class=>self
  one_to_many :retweets, :key=>:parent_id, :class=>self

  one_to_many :history, :class=>:tweet_history

end
