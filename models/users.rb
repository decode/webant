require File.dirname(__FILE__) + '/../db_connection.rb'

Dir[File.dirname(__FILE__) + '/*.rb'].each do |file|
  require "#{file}"
end

class User < Sequel::Model
  one_to_many :tweets
  one_to_many :histories, :class=>"UserHistory"

  def self.find_or_create(uid)
    DB.transaction do
      users = User.filter(:uid => uid)
      users.count > 0 ? users.first : User.create(:uid => uid, :created_at => Time.now)
    end
  end

  def self.find_or_create_by_name(name)
    DB.transaction do
      users = User.filter(:name => name)
      users.count > 0 ? users.first : User.create(:name => name, :created_at => Time.now)
    end
  end

  def self.create_from_userpage(info, history)
    DB.transaction do
      users = User.filter(:uid => info[:uid])
      if users.count == 0
        #user = User.create(:uid=>info[:uid], :name=>info[:name], :gender=>info[:gender], :form=>info[:from], :level=>info[:level])
        user = User.create(info)
        #history = History.create(:tweet_num=>info[:tweet_num], :follow_num=>info[:follow_num], :follower_num=>info[:follower_num], :group_num=>info[:group_num], :created_at=>Time.now)
        h = History.create(history)
        h.user = user
      else
        user = users.first
        user.update(info)
      end
    end
  end

  
end
