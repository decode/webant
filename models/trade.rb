require File.dirname(__FILE__) + '/../db_connection'
DB = DBConnection.connect

class Tweets < Sequel::Model

  def self.add_trade(seller_id, buyer_id, item_id, trade_time, update=false)
    trades = Trade.filter(:seller_id => seller_id, :customer_id => buyer_id, :trade_time => trade_time)
    if trades.count > 0
      return trades.first if update
    else
      return Trade.create(:seller_id => seller_id, :customer_id => buyer_id, :item_id => item_id, :trade_time => trade_time)
    end
  end
  
  def self.find_or_create(seller_name, buyer_name, trade_time)
    seller = User.find_or_create(:name => seller_name)
    buyer = User.find_or_create(:name => buyer_name)
    DB.transaction do
      trades = Trade.filter(:seller_id => seller.id, :customer_id => buyer.id, :trade_time => trade_time)
      trades.count > 0 ? trades.first : Trade.create(:seller_id => seller.id, :customer_id => buyer.id, :trade_time => trade_time)
    end
  end
  
end
