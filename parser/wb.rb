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

end

