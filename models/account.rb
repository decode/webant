require File.dirname(__FILE__) + '/../db_connection'
require File.dirname(__FILE__) + '/trade'

DB = DBConnection.connect

class Account < Sequel::Model
  one_to_many :trades
  #many_to_many :customers, :class => :Account, :key => :customer_id, :join_table => :trades,  :graph_conditions => {:seller_id => id} #:dataset=>proc{Account.eager_graph(:trade).filter(:trades__customer_id=>id)}

  #many_to_many :sellers, :class => :Account, :key => :seller_id, :join_table => :trades, :graph_conditions => {:customer_id => id}

  def self.store_shop_list(shops)
    shops.each do |shop|
      DB.transaction do
        Account.filter(:rate_url)
        if User.filter(:id => shop[:name]).count == 0
          shop[:created_at] = Time.now
          Account.create shop
        else
          Account.filter(:name => shop[:name]).first.update shop
        end
      end
    end
  end

  def self.find_or_create(user_name)
    user = User.filter(:name => user_name).first
    # if there is no user information, then there is no need to store.
    return if user.nil?
    accounts = Account.filter(:user_id => user.id)
    accounts.count > 0 ? accounts.first : Account.create(:user_id => user.id, :created_at => Time.now)
  end
    
  
end
