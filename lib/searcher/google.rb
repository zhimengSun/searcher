require 'searcher/global'

def search_from_google(keyword, page = 2)
  res,links = '',[]
  (1..page).each do |pn|
    url_with_keyword = 'https://www.googleapis.com/customsearch/v1?key=AIzaSyBvybq0NEaMtMkAkPUd7hhC-17AzcOc9x8&cx=013036536707430787589:_pqjad5hr1a&alt=json&fields=items(link)&q=' + URI.encode(keyword) + '&start=' + pn.to_s
    url = URI.parse(url_with_keyword)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url.request_uri)
    response = http.request(request)
    res += response.body
    links_strings = JSON.parse(response.body) rescue nil
    links_strings['items'].each do |link|
      links << [link['link'],"google"]
      #Global.save_link_info(link['link'], 'google')
    end
  end
  links
end

def get_list_from_google(keyword, page = 2)
  #content = search_from_google(keyword,page)
  #Global.save_to_file(content,'google.html','/htmls')
  search_from_google(keyword,page)
end


