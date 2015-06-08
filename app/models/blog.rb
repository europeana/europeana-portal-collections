require 'rss'
require 'uri'
require 'net/http'

class Blog
  def initialize(url)
    @url = url
  end

  def get
    uri = URI(@url)
    res = Net::HTTP.get_response(uri)
    RSS::Parser.parse(res.body)
  end
end
