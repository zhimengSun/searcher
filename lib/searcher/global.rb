module Global

  #require 'ap'                # gem install awesome_print
  require 'json'
  require 'nokogiri'
  require 'forkmanager'       # gem install parallel-forkmanager
  require 'beanstalk-client'
  require 'net/http'
  require 'uri'

  UserAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:13.0) Gecko/20100101 Firefox/13.0'
  Beanstalk_jobs = [['localhost:11300'], 'crawler-jobs']

  def self.html_get_web_url(url, user_agent = UserAgent, timeout = 20, redirect_limit = 3)
    raise ArgumentError, 'too many HTTP redirects' if redirect_limit == 0
    begin
      response = Net::HTTP.get_response(URI.parse(URI.decode(url)))
      case response
        when Net::HTTPSuccess then
          url
        when Net::HTTPRedirection then
          response['location']
        else
          nil
      end
    rescue => e
      e.message
    end
  end

  def self.get_whole_response(url, user_agent = UserAgent, timeout = 20)
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.path.to_s + '?' + uri.query.to_s)
    req.add_field('User-Agent', user_agent)
    res = Net::HTTP.start(uri.host, uri.port) do |http|
      http.read_timeout = timeout
      http.request(req)
    end
  end

  def self.get_whole_html(res, user_agent = UserAgent, timeout = 20)
    encoding = res.body.scan(/<meta.+?charset=["'\s]*([\w-]+)/i)[0]
    encoding = encoding ? encoding[0].upcase : 'GB18030'
    html = 'UTF-8'==encoding ? res.body : res.body.force_encoding('GB2312'==encoding || 'GBK'==encoding ? 'GB18030' : encoding).encode('UTF-8')
  end

  def self.get_final_url_from_response(url, user_agent = UserAgent, timeout = 20)
    res = get_whole_response(url, user_agent, timeout)
    res.header['location'] ? get_final_url_from_response(url, user_agent, timeout) : url
  end

  def self.save_link_info(url, info_type = 'baidu', path = '/link_infos')
    save_to_file(url,"#{info_type}.txt",path)
    #into DB ... some code ...
  end

  def self.save_to_file(content, file_name, path = '/link_infos')
    path = ".#{path}/"
    Dir.mkdir(path)  if !Dir.exist?(path)

    logfile = File.open(path + file_name, 'a')
    logfile.puts(content)
    logfile.close
  end






end
