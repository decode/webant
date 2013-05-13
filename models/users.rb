require File.dirname(__FILE__) + '/../db_connection'

DB = DBConnection.connect

class User < Sequel::Model

  def self.find_or_create(uid)
    DB.transaction do
      users = User.filter(:uid => uid)
      users.count > 0 ? users.first : User.create(:uid => uid, :created_at => Time.now)
    end
  end
  
end
