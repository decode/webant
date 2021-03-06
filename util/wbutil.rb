# encoding: utf-8
require 'rubygems'
require 'mechanize'
require 'yaml'

Dir[File.dirname(__FILE__) + '/../parser/*.rb'].each do |file|
  require "#{file}"
end

Dir[File.dirname(__FILE__) + '/../models/*.rb'].each do |file|
  require "#{file}"
end

class WbUtil
  attr_accessor :web

  @logger = nil

  def initialize
    @web = Mechanize.new
    @web.user_agent_alias = 'Mac Safari' 
    @logger = Logger.new(File.dirname(__FILE__) + '/../log/auth.log', 10, 1024000)
  end

  def login
    page = @web.get('http://login.weibo.cn/login/')
    #file = File.new("login.html", "w")
    #file << page.body
    
    doc = Nokogiri::HTML::parse(page.body)
    vk = doc.css('input')[-2]['value']
    front = vk.split('_')[0]
    action = doc.css('form').first['action']
    
    # Load config
    config_file = File.dirname(__FILE__) + '/../config/settings.yml'
    if File.exist?(config_file)
      @params = YAML.load(File.open(config_file))

      login_page = page.form_with(:action=>action) do |f|
        f.mobile = @params['username']
        eval("f.password_#{front} = #{@params['password']}")
        f.checkbox_with(:name=>'remember').check
        f.vk = vk
      end.click_button

      # save cookies
      @web.cookie_jar.save_as('wb.yml')
    else
      puts 'Settings config file not existed!!!'
    end
  end

  # 使用cookie免登录
  def load_cookie
    begin
      # 优先使用浏览噐导出的cookies文件
      cookie_file = File.dirname(__FILE__) + '/../cookies.txt'
      if File.exist? cookie_file
        @web.cookie_jar = Mechanize::CookieJar.new.load(cookie_file, :format => :cookiestxt)
        @logger.info 'Load cookies.txt'
        return
      end
      cookieyml_file = File.dirname(__FILE__) + '/../wb.yml'
      if File.exist? cookieyml_file
        @web.cookie_jar = Mechanize::CookieJar.new.load(cookieyml_file)
        @logger.info 'Load wb.yml'
        return
      end
    rescue
      @logger.error 'Loading cookies error!!!'
    end
  end

  # 检查是否登录, 自动加载cookies
  def check_login
    # 如果使用这个函数,mechanize2.7.1会报錯,2.6.0没有这个问题
    load_cookie
    page = @web.get('http://weibo.cn')
    wb = Wb.new(page.body)
    #file = File.new("index.html", "w")
    #file << page.body
    unless wb.login?
      @logger.info 'Not loggin!! Re-login!!'
      login 
    end
  end

  # 获得用户的主页链接
  # TODO: url需要获得
  # Not used
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
  # params:
  #   uid - 用户平台ID, uid可通过parser/Wb.user_info函数获得
  #   special_type - 'nopic'原创无图片, 'haspic'原创有图片, 'retweet_nopic'转发无图, 'retweet_haspic'转发有图
  # return:
  #   page_count
  def special_tweet_page(uid, special_type)
    case special_type
    when 'nopic'
      options = {:isOrigin=>true, :isPic=>false}
    when 'haspic'
      options = {:isOrigin=>true, :isPic=>true}
    when 'retweet_nopic'
      options = {:isOrigin=>false, :isPic=>false}
    when 'retweet_haspic'
      options = {:isOrigin=>false, :isPic=>true}
    end
    page = search(uid, options)
    wb = Wb.new(page.body)
    p wb.tweet_page_count
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

    #file = File.new("search.html", "w")
    #file << search_page.body

    return search_page
  end

  # param:
  #   四种排行榜类型: star, grass, content, media
  #   页面限制: 2 to 10 pages
  # return:
  #   Hash: 
  #     key: 用户名
  #     value: 网址,网址中可能包含uid也可能是用户名,需要判断
  def get_top_list(top_type, limit=10)
    url = "http://weibo.cn/pub/top?cat=#{top_type}"
    page = @web.get(url)
    #file = File.new("top.html", "w")
    #file << page.body
    wb = Wb.new(page.body)

    top_list = wb.top_user_list
    # the next page
    limit = limit>10 ? 10:limit
    (2..limit).each do |page_num|
      page_url = url + "&page=#{page_num}"
      page = @web.get(page_url)
      top_list.merge! Wb.new(page.body).top_user_list
      sleep rand(5)
    end
    top_list.each do |k, v|
      Task.add_task(v, top_type)
    end
    return top_list
  end

  # 获得用户个人信息和消息列表
  def fetch_user_page(url)
    page = @web.get(url)
    #file = File.new("user.html", "w")
    #file << page.body
    wb = Wb.new(page.body)

    info, history = wb.user_info
    tweets = wb.tweet_info
    sleep rand(5)

    # 获取用户生日
    info_url = "http://weibo.cn/" + info[:uid] + "/info"
    page = @web.get(info_url)
    wb = Wb.new(page.body)
    info[:birthday] = wb.user_birthday
    sleep rand(5)

    # 获取用户的标签
    info_url = "http://weibo.cn/account/privacy/tags/?uid=" + info[:uid]
    page = @web.get(info_url)
    wb = Wb.new(page.body)
    info[:tag] = wb.user_tag

    user = User.create_or_update(info)

    # 添加用户变量数据到数据库
    DB.transaction do
      h = UserHistory.create history
      h.user = user
      h.created_at = Time.now
      h.save
    end

    save_tweet(user, tweets)

    # 标记任务完成
    Task.mark_finish(url)
    return info, history, tweets
  end

  def save_tweet(user, tweets)
    tweets.each do |t|
      #puts '---------------------------------------'
      #puts t[:tweet]
      DB.transaction do
        tweet = Tweet.create_or_update t[:tweet]
        history = TweetHistory.create t[:history]
        history.tweet = tweet
        history.save

        if t[:retweet].length > 0
          ret = Tweet.create_or_update t[:retweet]
          if t[:retweet_user].length > 0
            retweet_user = User.find_or_create_by_name t[:retweet_user][:name]
            ret.user = retweet_user
            Task.add_task t[:retweet_user][:url]
          end
          ret.save
          rhistory = TweetHistory.create t[:retweet_history]
          rhistory.tweet = ret
          rhistory.save
          tweet.origin_tweet = ret
        end

        tweet.user = user
        tweet.save
      end
    end
  end

  # 获取用户每一页的消息
  def fetch_tweets(user, page_num=5)
    return if page_num < 1
    for i in 1..page_num
      url = "http://weibo.cn/#{user.uid}?page=#{i}"
      page = @web.get(url)
      #file = File.new("tweet.html", "w")
      #file << page.body
      wb = Wb.new(page.body)
      save_tweet(user, wb.tweet_info)

      sleep(rand(15))
    end
  end

end
