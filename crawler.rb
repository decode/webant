#!/usr/bin/env ruby
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
  @logger = nil

  def initialize
    @logger = Logger.new(File.dirname(__FILE__) + '/log/crawl.log', 10, 1024000)
    @logger.info 'Start Crawing ----------'
  end

  def prepare_tasks
    u = WbUtil.new
    u.check_login
    @logger.info('Prepare Fetch URLs')
    u.get_top_list('star', 5)
    u.get_top_list('grass', 5)
    @logger.info('Prepare Fetch URLs Finished')
  end

  # 根据数据库tasks表中的网址,使用WbUtil.fetch_user_page获取用户信息
  def fetch_user_info
    u = WbUtil.new
    u.check_login
    tasks = Task.where(:task_type=>['star', 'grass']).all
    @logger.info "Fetching Count: --------------------- " + tasks.count
    tasks.each do |task|
      @logger.info "Fetching User[#{task.task_type}] Info: " + task.url
      u.fetch_user_page(task.url)
      sleep(rand(10))
    end
    @logger.info('Fetch User Infomation Finished')
  end

  def fetch_user_tweets
    u = WbUtil.new
    u.check_login
    users = User.first(100)
    users.each do |user|
      @logger.info 'Fetching User Tweet ...' + user.uid
      u.fetch_tweets(user, 3)
      sleep(rand(10))
    end
    @logger.info('Fetch User Tweets Finished')
  end

end

if __FILE__ == $0
  # Put "main" code here
  case ARGV[0]
  when 'user'
    Crawler.new.fetch_user_info
  when 'tweet'
    Crawler.new.fetch_user_tweets
  when 'task'
    Crawler.new.prepare_tasks
  end
end
