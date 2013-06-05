require 'searcher/global'

def search_from_bing(keyword, page = 2)
  account_key = 'Onm2ZtMfIJsKdKLopx6/VpyADuqrdJPhsacwUuez7Ds='
  bing_keyword = 'https://api.datamarket.azure.com/Bing/Search/Web?Query=%27' + URI.encode(keyword) + '%27' + '&$skip=0'
  uri = URI(bing_keyword)

  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth('', account_key)

  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') { |http|
    http.request(req)
  }

  res.body
end

def get_list_from_bing(keyword,page=2)
  content = search_from_bing(keyword,page)

  super_link = Array.new
  regex = /<d:Url.*?<\/d:Url>/
  #Global.save_to_file(content,'bing.html','/htmls')

  content.scan(regex).each  do  |n|
    regex_http = /http.*?</
    real_url = n.match(regex_http)
    real_url = real_url.to_s.delete('<')
    #super_link.push(real_url)
    #Global.save_link_info(real_url, 'bing')
    super_link <<  [real_url,"bing"]
  end
  super_link
end







