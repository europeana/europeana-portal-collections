module EuropeanaAPIHelper
  # @todo move into europeana-api gem
  RSpec.configure do |config|
    config.before(:each) do
      # API Search
      stub_request(:get, Europeana::API.url + '/search.json').
        with(query: hash_including(wskey: 'test')).
        to_return(body: '{"success":true,"itemsCount":1,"totalResults":1,"items":[{"id":"/abc/123","title":["sample record"]}]}',
                  status: 200,
                  headers: { 'Content-Type' => 'text/json' })

      # API Record
      stub_request(:get, %r{#{Europeana::API.url}/record/[^/]+/[^/]+.json}).
        with(query: hash_including(wskey: 'test')).
        to_return { |request|
          id = request.uri.path.match(%r{/record(/[^/]+/[^/]+).json})[1]
          {
            body: '{"success":true,"object":{"about": "' + id + '"}}',
            status: 200,
            headers: { 'Content-Type' => 'text/json' }
          }
        }

      # Hierarchy API
      stub_request(:get, %r{#{Europeana::API.url}/record/[^/]+/[^/]+/(self|parent|children|ancestor-self-siblings|precee?ding-siblings|following-siblings).json}).
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

  def an_api_hierarchy_request_for(id)
    a_request(:get, %r{#{Europeana::API.url}/record#{id}/(self|parent|children|ancestor-self-siblings|precee?ding-siblings|following-siblings).json}).
      with(query: hash_including(wskey: 'test'))
  end
end
