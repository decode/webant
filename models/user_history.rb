require File.dirname(__FILE__) + '/../db_connection.rb'

class UserHistory < Sequel::Model
  many_to_one :user
end
