require File.dirname(__FILE__) + '/../db_connection.rb'

class User < Sequel::Model
  one_to_many :tweets
  one_to_many :history, :class=>:user_history

  def self.find_or_create(uid)
    DB.transaction do
      users = User.filter(:uid => uid)
      users.count > 0 ? users.first : User.create(:uid => uid, :created_at => Time.now)
    end
  end

  def self.create(info)
    DB.transaction do
      user = find_or_create(info[:uid])
    end
  end
  
end
