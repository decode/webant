# encoding: utf-8
require 'rubygems'
require 'mechanize'
require 'logger'

Dir[File.dirname(__FILE__) + '/parser/*.rb'].each do |file|
  require "#{file}"
end

#Dir[File.dirname(__FILE__) + '/models/*.rb'].each do |file|
  #require "#{file}"
#end

class Crawler
  #@url = 'http://weibo.cn/yaochen'
  #@url = 'http://weibo.cn/kaifulee'
  #@url = 'http://weibo.cn/u/3020788201'
  @web = nil
  def initialize
    @url = 'http://weibo.cn/n/崔向红'
    @web = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari' 
    end
  end

  def run
    page = @web.get(@url)
    puts page

    file = File.new("test.html", "w")
    file << page.body
  end
  
  def read
    file = File.new("test.html", "r")
    body = file.read
    wb = Wb.new(body)
    p wb.user_info
  end

  def index_page
    page = @web.get('http://weibo.cn')
    file = File.new("index.html", "w")
    file << page.body
  end

end

c = Crawler.new
c.load_cookie
c.get_tweet_page(2)
