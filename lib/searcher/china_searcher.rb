class Searcher::ChinaSearcher

  require 'searcher/global'

  attr_accessor :name, :url, :page_no, :page_name
  PAGE_NUM = 2

  def initialize(name,url, page_no = '1', page_name = 'pn')
    @name =  name
    @url = url
    @page_no = page_no
    @page_name = page_name
  end

  def search_keywords(keyword, page = PAGE_NUM)
    res = ''
      keyword_urls(keyword,page).each do |url|
        res << Net::HTTP.get_response(URI.parse(url)).body
      end
    res
  end

  def keyword_urls(keyword, page = PAGE_NUM)
    i =  'baidu' == @name ? 0 : 1
    sites = []
    loop do
       url_with_keyword = @url + URI.encode(keyword) + '&' + @page_name + '=' + i.to_s
       sites << url_with_keyword
       i += page_no.to_i
       break if i > (page * @page_no.to_i)
     end
    sites
  end

  def get_list(keyword, page = PAGE_NUM)
    content = search_keywords(keyword,page)
    super_link = Array.new
    regex = /<a.*?href.*?<\/a>/

    #Global.save_to_file(content, @name + '.html','/htmls')

    content.scan(regex).each do |n|
      if n.index('<em>') != nil
        url =/"http.*?"/.match(n)
        if url != nil
          string_url = url.to_s.delete('"')
          redirect_url = Global.html_get_web_url(string_url)
          if redirect_url != nil
            super_link << [redirect_url,@name]
            #Global.save_link_info(redirect_url, @name)
          end
        end
      end
    end
    super_link
  end

  class << self
    def  keyword_urls(names, keyword, page = PAGE_NUM)
      names.inject([]) {|us, name| us << name.keyword_urls(keyword,page)}.flatten
    end
  end

end






