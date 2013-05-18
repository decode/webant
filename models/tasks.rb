require File.dirname(__FILE__) + '/../db_connection.rb'

class Task < Sequel::Model
  def self.add_task(url, type='user', update=false)
    DB.transaction do
      tasks = Task.filter(:url => url)
      if tasks.count == 0
        Task.create :task_type => type, :url => url, :created_at => Time.now
      else update
        task = tasks.first
        task.url = url
        task.run_at = Time.now
        task.update_count += 1
        task.save
      end
    end
  end

  # If net problem or parse error occur, add to error count
  def self.add_error(target_id, type='user')
    DB.transaction do
      tasks = Task.filter(:target_id => target_id)
      return if tasks.count == 0
      task = tasks.first
      task.update :run_at => Time.now, :update_count => task[:update_count]+1, :error_count => task[:error_count]+1
      puts "[T]:      userid(#{target_id}), url(#{task[:url]})"
    end
  end
  
end
