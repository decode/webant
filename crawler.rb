# encoding: utf-8
require 'rubygems'
require 'mechanize'
require 'logger'

Dir[File.dirname(__FILE__) + '/parser/*.rb'].each do |file|
  require "#{file}"
end

Dir[File.dirname(__FILE__) + '/models/*.rb'].each do |file|
  require "#{file}"
end

Dir[File.dirname(__FILE__) + '/util/*.rb'].each do |file|
  require "#{file}"
end

class Crawler
  def initialize
  end

  def run
  end
  
  def prepare_tasks
    u = WbUtil.new
    u.load_cookie
    u.get_top_list('star', 10)
    u.get_top_list('grass', 10)
  end

  # 根据数据库tasks表中的网址,使用WbUtil.fetch_user_page获取用户信息
  def fetch_user_info
    u = WbUtil.new
    u.check_login
    #tasks = Task.filter(:done=>false)
    tasks = Task.filter(:id=>1..100)
    tasks.each do |task|
      puts task.url
      u.fetch_user_page(task.url)
      sleep(rand(10))
    end
  end

  def fetch_user_tweets
    u = WbUtil.new
    u.check_login
    users = User.first(100)
    users.each do |user|
      u.fetch_tweets(user, 3)
      sleep(rand(10))
    end
  end

end

Crawler.new.fetch_user_tweets
