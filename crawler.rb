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

  def fetch
  end

end

# TODO 根据数据库tasks 表中的网址,使用get_tweet_list获取用户信息
#tasks = Task.first(10)
#puts tasks[0].url
#u = WbUtil.new
##u.login
#u.load_cookie
#info = u.fetch_user_page(tasks[0].url)
#print info[0][:uid]

Crawler.new.prepare_tasks
