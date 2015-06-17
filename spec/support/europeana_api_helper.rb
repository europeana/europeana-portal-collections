module EuropeanaAPIHelper
  RSpec.configure do |config|
    config.before(:each) do
      # API Search
      stub_request(:get, Europeana::API.url + '/search.json').
        with(query: hash_including(wskey: 'test')).
        to_return(body: '{"success":true,"items":[]}',
                  status: 200,
                  headers: { 'Content-Type' => 'text/json' })

      # API Record
      stub_request(:get, %r{#{Europeana::API.url}/record/[^/]+/[^/]+.json}).
        with(query: hash_including(wskey: 'test')).
        to_return(body: '{"success":true,"object":{}}',
                  status: 200,
                  headers: { 'Content-Type' => 'text/json' })

      # Hierarchy API
      stub_request(:get, %r{#{Europeana::API.url}/record/[^/]+/[^/]+/(ancestor-self-siblings|children).json}).
        with(query: hash_including(wskey: 'test')).
        to_return(body: '{"success":false,"message":"This record has no hierarchical structure!"}',
                  status: 200,
                  headers: { 'Content-Type' => 'text/json' })
    end
  end

  def an_api_search_request
    a_request(:get, Europeana::API.url + '/search.json').
      with(query: hash_including(wskey: 'test'))
  end

  def an_api_record_request_for(id)
    a_request(:get, Europeana::API.url + "/record#{id}.json").
      with(query: hash_including(wskey: 'test'))
  end
end
