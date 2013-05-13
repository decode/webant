require File.dirname(__FILE__) + '/../db_connection'
require File.dirname(__FILE__) + '/trade'

DB = DBConnection.connect

class Item < Sequel::Model
  #one_to_one :trade

  def self.add_item(seller_id, item, item_url, update=false)
    items = Item.filter(:seller_id => seller_id, :name => item, :url => item_url)
    if items.count > 0
      return items.first #if update
    else
      item = Item.create(:name => item, :url => item_url, :seller_id => seller_id, :created_at => Time.now)
      return item
    end
  end

  def self.find_or_create(seller_name, item_url)
    seller = User.find_or_create(:name => seller_name)
    DB.transaction do
      items = Item.filter(:seller_id => seller.id, :url => item_url)
      items.count > 0 ? items.first : Item.create(:url => item_url, :seller_id => seller.id, :created_at => Time.now)
    end
  end
    
  
end
