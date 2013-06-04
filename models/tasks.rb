require File.dirname(__FILE__) + '/../db_connection.rb'

class Task < Sequel::Model
  def self.add_task(url, type='user', update=false)
    # 去掉网址?号后的尾巴
    url = url[0...url.index('?')] unless url.index('?').nil?
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
  # Not used!
  def self.add_error(target_id, type='user')
    DB.transaction do
      tasks = Task.filter(:target_id => target_id)
      return if tasks.count == 0
      task = tasks.first
      task.update :run_at => Time.now, :update_count => task[:update_count]+1, :error_count => task[:error_count]+1
      puts "[T]:      userid(#{target_id}), url(#{task[:url]})"
    end
  end

  # 标记该任务己完成,目前暂时作为调试观察使用
  def self.mark_finish(url)
    tasks = Task.filter :url => url
    if tasks.count > 0
      DB.transaction do
        task = tasks.first
        task.done = true
        task.save
      end
    end
  end
  
end
