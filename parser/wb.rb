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
    # 用户UID
    link = @doc.css('div.ut > a').last
    @info[:uid] = link['href'].match(/\d+/).to_s

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
    @info[:all_page] = tweet_page_count

    return @info
  end

  # 获取不同分类页数
  def tweet_page_count
    if @doc.css('div#pagelist > form > div > input').length == 0
      return 1.to_s
    else
      return @doc.css('div#pagelist > form > div > input')[0]['value']
    end
  end

  # 获得用户所关注的人被别人关注的数量
  def follow_follower
  end

  # 获得发布的消息的状态,如客户端 消息id 其他人态度等
  # return:
  #   tid - tweet id
  #   isRetweet - this tweet is retweet others tweet
  #   tweet - tweet content
  #   support - the number of other support
  #   retweet_num - the retweet number
  #   retweet_url - the page url of retweet
  #   comment_num - the comments number
  #   comment_url - the page url of people who comment
  #   tweet_at - the post time of a tweet
  #   tweet_by - people using client to tweet
  def tweet_info
    tweets = Array.new
    tweet_list = @doc.css('div.c')
    tweet_list.each do |div|
      info = Hash.new
      if div['id'] != nil
        # tweet id
        tid = div['id'].sub('M_', '')
        info[:tid] = tid

        # retweet
        retweet = div.css('span.cmt')
        if retweet
          info[:isRetweet] = true
        end

        # content
        tweet_content = div.css('span.ctt').first
        info[:tweet] = tweet_content.content

        # @,label, attitude, retweet, comment, favorite
        attitude = ''
        links = div.css('a')
        act_link = Array.new
        links.each do |a|
          if a['href'].match(tid)
            act_link.push(a)
            attitude += a.content
          end
        end
        info[:support], info[:retweet_num], info[:comment_num] = attitude.scan(/\d+/)
        # 同时获取转发、评论的链接
        info[:retweet_url], info[:comment_url] = act_link[1]['href'], act_link[2]['href']

        # tweet time
        tc = div.css('span.ct')[0].content
        tweet_at = tc[0..tc.index("来自")-2]
        #   tweet time is not so long 
        tweet_time = tweet_at.scan(/\d/).join
        case tweet_time.length
        when 1..2
          info[:tweet_at] = (Time.now-tweet_time.to_i*60).strftime("%Y%m%d%H%M")
        when 4
          info[:tweet_at] = Time.now.strftime("%Y%m%d") +tweet_time
        when 8
          info[:tweet_at] = Time.now.year + tweet_time
        end

        # tweet client
        info[:tweet_by] = tc[tc.index("来自")+2..tc.length]
        tweets.push(info)
      end
    end
    return tweets
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
