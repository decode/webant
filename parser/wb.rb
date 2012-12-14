# encoding: utf-8
require 'nokogiri'
require 'hpricot'

class Wb

  def initialize(body, encoding=nil)
    #nbsp = Nokogiri::HTML("&nbsp;").text
    #body.gsub(/#{nbsp}/, ' ')
    @doc = Nokogiri::HTML::parse(body, nil, encoding)   
    @info = Hash.new
  end

  # Mechanize::Page class as param
  def get_uid(page)
    @info[:uid] = page.uri.to_s.match(/\d+/).to_s
  end

  def user_info
    # 用户名一栏 ------------------------------ 
    content = @doc.css('div.ut > span.ctt')[0].content
    info = content.split(/[[:blank:]]/)
    name = info[0]
    # if user online
    if name.include?('[')
      name = name[0..name.index('[')-1]
    end
    @info[:name] = name
    if info.length == 3
      @info[:sex], @info[:from] = info[2].split(/\//)
    end

    # 用户状态一栏 ------------------------------ 
    content = @doc.css('div.tip2')
    c = content[0].content
    d = c.scan(/\d+/)
    @info[:tweet], @info[:follow], @info[:follower], @info[:group] = d
    # 相关关注
    if content.length > 1
    end

    # 信息类别 ------------------------------ 
    # all tweet page number
    count_tweet_page(:all_page)

    return @info
  end

  # 获取不同分类页数
  def count_tweet_page(page_type)
    if @doc.css('div#pagelist > form > div > input').length == 0
      @info[page_type] = 1.to_s
    else
      @info[page_type] = @doc.css('div#pagelist > form > div > input')[0]['value']
    end
  end

  # 获得用户所关注的人被别人关注的数量
  def follow_follower
  end

  # 获得发布的消息的状态,如客户端 消息id 其他人态度等
  # TODO: 获取转发/评论的链接,是否能够抓取
  def tweet_info
    tweet_list = @doc.css('div.c')
    tweet_list.each do |div|
      if div['id'] != nil
        # tweet id
        tid = div['id'].sub('M_', '')
        @info[:tid] = tid

        #@,label, attitude, retweet, comment, favorite, client
        attitude = ''
        links = div.css('a')
        links.each do |a|
          if a['href'].match(tid)
            attitude += a.content
          end
        end
        @info[:good], @info[:retweet_num], @info[:comment_num] = attitude.scan(/\d+/)

        # tweet time
        tc = div.css('span.ct')[0].content
        tweet_at = tc[0..tc.index("来自")-2]
        #   tweet time is not so long 
        tweet_time = tweet_at.scan(/\d/).join
        case tweet_time.length
        when 1..2
          @info[:tweet_at] = (Time.now-tweet_time.to_i*60).strftime("%Y%m%d%H%M")
        when 4
          @info[:tweet_at] = Time.now.strftime("%Y%m%d") +tweet_time
        when 8
          @info[:tweet_at] = Time.now.year + tweet_time
        end

        # tweet client
        @info[:tweet_by] = tc[tc.index("来自")+2..tc.length]
        return @info
      end
    end
  end

  # 获得排行榜中的列表
  def top_user_list
    top_list = @doc.css('a.nk')
    @top = Hash.new
    top_list.each do |u|
      @top[u.content] = u['href']
    end
    return @top
  end

end

