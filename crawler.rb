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
  
  def login
    page = @web.get('http://login.weibo.cn/login/?ns=1&revalid=2&backURL=http%3A%2F%2Fweibo.cn%2F&backTitle=%D0%C2%C0%CB%CE%A2%B2%A9&vt=')
    file = File.new("login.html", "w")
    file << page.body
    
    doc = Nokogiri::HTML::parse(page.body)
    vk = doc.css('input')[-2]['value']
    p vk
    front = vk.split('_')[0]
    p front
    action =doc.css('form').first['action']

    login_page = page.form_with(:action=>action) do |f|
      f.mobile = 'basicme@sina.cn'
      eval("f.password_#{front} = '123654'")
      f.checkbox_with(:name=>'remember').check
      f.vk = vk
    end.click_button

    # save cookies
    @web.cookie_jar.save_as('wb')
  end

  def load_cookie
    if File.exist?('wb') 
      @web.cookie_jar = Mechanize::CookieJar.new.load('wb')
    end
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

  
  def get_user_home_page
   page = @web.get(@url)
   return page.uri.to_s
  end

  def get_tweet_page(tweet_type)
    page = @web.get(@url)
    base_url = page.uri.to_s
    url = base_url + "?filter=#{tweet_type}"
    page = @web.get(url)
    wb = Wb.new(page.body)
    p wb.count_tweet_page(:origin_page)
  end

end

c = Crawler.new
c.load_cookie
c.get_tweet_page(2)
