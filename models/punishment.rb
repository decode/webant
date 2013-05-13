require File.dirname(__FILE__) + '/../db_connection'

DB = DBConnection.connect

class Punishment < Sequel::Model
  def self.store_base_info(shop, update = false)
    DB.transaction do
      if User.filter(:name => shop[:name]).count == 0
        user = User.create shop
        return user
      else
        user = User.filter(:name => shop[:name]).first
        user.update shop if update
        return user 
      end
    end
  end

  def self.find_or_create(name)
    DB.transaction do
      users = User.filter(:name => name)
      return if users.count > 0
      punish = Punishment.filter(:user_id => users[0][:id]).first
      punish = Punishment.create(:user_id => users[0][:id], :created_at => Time.now) if punish.nil?
      return punish
    end
  end
  
end
