module EuropeanaAPIHelper
  RSpec.configure do |config|
    config.before(:each) do
      # webmock stubbed requests
      stub_request(:get, Europeana::API.url + '/search.json').
        with(query: hash_including(wskey: 'test')).
        to_return(body: '{"success":true,"items":[]}',
                  status: 200,
                  headers: { 'Content-Type' => 'text/json' })
    end
  end

  def an_api_search_request
    a_request(:get, Europeana::API.url + '/search.json').
      with(query: hash_including(wskey: 'test'))
  end
end
