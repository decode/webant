require File.dirname(__FILE__) + '/../db_connection.rb'

Dir[File.dirname(__FILE__) + '/*.rb'].each do |file|
  require "#{file}"
end

class Tweet < Sequel::Model
  many_to_one :user

  many_to_one :origin_tweet, :key=>:parent_id, :class=>self
  one_to_many :retweets, :key=>:parent_id, :class=>self

  one_to_many :history, :class=>'TweetHistory'

  def self.create_or_update(tweet)
    ts = Tweet.filter :tid => tweet[:tid]
    if ts.count > 0
      t = ts.first
      t.update(tweet)
      return t
    else
      return Tweet.create tweet
    end
  end

end
