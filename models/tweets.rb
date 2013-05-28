require File.dirname(__FILE__) + '/../db_connection.rb'

Dir[File.dirname(__FILE__) + '/*.rb'].each do |file|
  require "#{file}"
end

class Tweet < Sequel::Model
  many_to_one :user

  many_to_one :origin_tweet, :key=>:parent_id, :class=>self
  one_to_many :retweets, :key=>:parent_id, :class=>self

  one_to_many :history, :class=>'TweetHistory'

end
