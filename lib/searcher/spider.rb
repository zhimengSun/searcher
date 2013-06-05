#encoding: UTF-8
require 'searcher/global'
require 'core/nil'

class Searcher::MultipleCrawler
  class Crawler

    def initialize(user_agent = Global::UserAgent, redirect_limit = 1)
      @user_agent = user_agent
      @redirect_limit = redirect_limit
      @timeout = 20
    end

    attr_accessor :user_agent, :redirect_limit, :timeout

    def fetch(website,selector='')
      p "Pid:#{Process.pid}, fetch: #{website}\n"
      res = Global.get_whole_response(website,@user_agent,@timeout)
      html = Global.get_whole_html(res,@user_agent,@timeout)
      doc = Nokogiri::HTML(html)
      #doc.css(selector)  if selector != ''
    end

  end

  def initialize(websites, beanstalk_jobs = Global::Beanstalk_jobs, pm_max = 10, user_agent = Global::UserAgent, redirect_limit = 1)
    @websites = websites                # the url we ready to crawl
    @beanstalk_jobs = beanstalk_jobs    # beanstalk host port and so on
    @pm_max = pm_max                    # max process number
    @user_agent = user_agent
    @redirect_limit = redirect_limit
    @ipc_reader, @ipc_writer = IO.pipe
  end

  attr_accessor :user_agent, :redirect_limit

  def init_beanstalk_jobs
    beanstalk = Beanstalk::Pool.new(*@beanstalk_jobs)
    begin
      while job = beanstalk.reserve(0.1)
        job.delete
      end
    rescue Beanstalk::TimedOut
      print "Beanstalk queues cleared!\n"
    end
    @websites.size.times{|i| beanstalk.put(i)} # 将所有的任务压栈
    beanstalk.close
      rescue => e
        puts e
        exit
  end


  def process_jobs
    pm = Parallel::ForkManager.new(@pm_max)

    @pm_max.times do |i|
      pm.start(i) and next
      beanstalk = Beanstalk::Pool.new(*@beanstalk_jobs)
      @ipc_reader.close
      loop do
        begin
          job = beanstalk.reserve(0.1) # timeout 0.1s
          index = job.body
          job.delete
          website = @websites[index.to_i]
          result = Crawler.new.fetch(website)
          @ipc_writer.puts(result)
        rescue Beanstalk::DeadlineSoonError, Beanstalk::TimedOut, SystemExit, Interrupt
          break
        end
      end
      pm.finish(i)
    end

    @ipc_writer.close

    begin
      pm.wait_all_children
    rescue SystemExit, Interrupt
      print "Interrupt wait all children!\n"
    end

  end

  def read_results
    results = []
    while result = @ipc_reader.gets
      results << result
    end
    results
  end

  def run
    init_beanstalk_jobs
    process_jobs
    read_results
  end
end
