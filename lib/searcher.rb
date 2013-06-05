require 'core/nil'

class Searcher
 UsSearchers = %w(google bing)
 ChinaSearchers = %w(baidu sogou so360)
 AllSearchers = UsSearchers + ChinaSearchers
  class << self
      def get_links_from_searches(keywords,page=1,searchers=AllSearchers)
          infos = []
          start_time = Time.now
          searchers.each do |searcher|
           infos += send 'get_info_from_' + searcher,keywords,page
          end
          infos << (Time.now - start_time).round(4)
          infos
      end

      AllSearchers.each do |search|
        define_method "get_info_from_#{search}" do |keywords,page=1|
          if UsSearchers.include?(search)
            send 'get_list_from_' + search,keywords,page
          else
            searcher = send(search)
            searcher.get_list(keywords,page)
          end
        end
      end

      def get_infos_from_url(url,selector='title')
        crawler.fetch(url,selector)
      end

      def crawler
        @crawler = MultipleCrawler::Crawler.new
      end

      def baidu
         @baidu =  ChinaSearcher.new('baidu', 'http://www.baidu.com/s?wd=','10')
      end

      def sogou
         @sogou =  ChinaSearcher.new('sogou', 'http://www.sogou.com/web?query=', '1','page')
      end

      def so360
         @so360 = ChinaSearcher.new('so360','http://www.so.com/s?&q=')
      end

      def china_searchers
        [baidu,sogou,so360]
        #[sogou,so360]
      end
      

  end

end
require 'searcher/china_searcher'
require 'searcher/spider'
require 'searcher/bing'
require 'searcher/google'

