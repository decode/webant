require File.dirname(__FILE__) + '/../db_connection'

DB = DBConnection.connect

class Task < Sequel::Model
  def self.add_task(target_id, url, type='person', depth=0, update=false)
    DB.transaction do
      tasks = Task.filter(:url => url)
      if tasks.count == 0
        Task.create :target_id => target_id, :type => type, :url => url, :depth => depth, :created_at => Time.now
      else update
        task = tasks.first
        task.url = url
        task.added_at = Time.now
        task.update_count += 1
        task.save
      end
    end
  end

  # If net problem or parse error occur, add to error count
  def self.add_error(target_id, type='person', depth=0)
    DB.transaction do
      tasks = Task.filter(:target_id => target_id)
      return if tasks.count == 0
      #Task.create :user_id => user_id, :type => type, :depth => depth, :error_count => 1, :created_at => Time.now
      task = tasks.first
      task.update :added_at => Time.now, :update_count => task[:update_count]+1, :error_count => task[:error_count]+1
      puts "[T]:      userid(#{target_id}), url(#{task[:url]})"
    end
  end
  
end
