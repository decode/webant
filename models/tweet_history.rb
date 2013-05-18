require File.dirname(__FILE__) + '/../db_connection.rb'

class TweetHistory < Sequel::Model
  many_to_one :tweet
end
