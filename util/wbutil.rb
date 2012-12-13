# encoding: utf-8
require 'rubygems'
require 'mechanize'

Dir[File.dirname(__FILE__) + '/../parser/*.rb'].each do |file|
  require "#{file}"
end

class WbUtil
  attr_accessor :web

  def initialize
    @url = 'http://weibo.cn/pub/top?cat=grass&rl=0'
    @web = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari' 
    end
  end

  def login
    page = @web.get('http://login.weibo.cn/login/?ns=1&revalid=2&backURL=http%3A%2F%2Fweibo.cn%2F&backTitle=%D0%C2%C0%CB%CE%A2%B2%A9&vt=')
    file = File.new("login.html", "w")
    file << page.body
    
    doc = Nokogiri::HTML::parse(page.body)
    vk = doc.css('input')[-2]['value']
    front = vk.split('_')[0]
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

  # 使用cookie免登录
  def load_cookie
    if File.exist?('wb') 
      @web.cookie_jar = Mechanize::CookieJar.new.load('wb')
    end
  end

  # 获得用户的主页链接
  # TODO: url需要获得
  def get_user_home_page
   page = @web.get(@url)
   return page.uri.to_s
  end

  # 获取用户的消息内容所占页面数,使用search函数也可实现
  # param:
  #   0:全部 1:原创 2:图片
  # return:
  #   page count
  def get_tweet_page(tweet_type)
    base_url = get_user_home_page
    url = base_url + "?filter=#{tweet_type}"
    page = @web.get(url)
    wb = Wb.new(page.body)
    return wb.count_tweet_page(:origin_page)
  end

  # 指定获取用户的消息类型集合
  # TODO 如何获取用户uid
  def special_tweet_page
    uid = '1266321801'
    page = search(uid, :isOrigin=>true, :isPic=>false)
    wb = Wb.new(page.body)
    p wb.count_tweet_page(:search_page)
  end

  # 搜索功能,通过网站的'筛选'实现
  # params:
  #   keyword 关键字
  #   isOrigin 是否原创
  #   isPic 是否图片
  #   start_time 开始时间
  #   end_time 结束时间
  # return:
  #   mechanize object
  def search(uid, options={})
    url = "http://weibo.cn/#{uid}/search?f=u&rl=0"
    page = @web.get(url)
    search_page = page.form_with(:action=>"/#{uid}/profile") do |f|
      f.keyword = options[:keyword]
      f.radiobutton_with(:name=>'hasori', :value=>'1').check if options[:isOrigin]
      f.radiobutton_with(:name=>'haspic', :value=>'2').check unless options[:isPic]
      f.starttime = options[:start_time]
      f.endtime = options[:end_time].nil? ? Time.now.strftime("%Y%m%d"):options[:end_time]
    end.click_button

    file = File.new("search.html", "w")
    file << search_page.body

    return search_page
  end

  # param:
  #   四种排行榜类型: star, grass, content, media
  #   页面限制: 2 to 10 pages
  # return:
  #   Hash
  def get_top_list(top_type, limit=10)
    #file = File.new("top.html", "r")
    #body = file.read
    url = "http://weibo.cn/pub/top?cat=#{top_type}&rl=0"
    page = @web.get(url)
    file = File.new("top.html", "w")
    file << page.body
    wb = Wb.new(body)
    top_list = wb.top_user_list
    # the next page
    limit = limit>10 ? 10:limit
    (2..limit).each do |page_num|
      url = "http://weibo.cn/pub/top?cat=#{top_type}&page=#{page_num}"
      page = @web.get(url)
      top_list += Wb.new(page.body).top_user_list
    end
    return top_list
  end

  def get_tweet_list
    file = File.new("search.html", "r")
    body = file.read
    wb = Wb.new(body)
    wb.tweet_info
  end

end

u = WbUtil.new
u.load_cookie
#p u.get_top_list('grass')
u.get_tweet_list

