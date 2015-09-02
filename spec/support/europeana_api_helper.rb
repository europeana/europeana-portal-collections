module EuropeanaAPIHelper
  # @todo move into europeana-api gem
  RSpec.configure do |config|
    config.before(:each) do
      # API Search
      items = (0..20).map do |index|
        id = '/sample/record' + index.to_s
        '{"id":"' + id + '","title":["' + id + '"]}'
      end.join(',')

      stub_request(:get, Europeana::API.url + '/search.json').
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return(body: '{"success":true,"itemsCount":' + items.size.to_s + ',"totalResults":' + items.size.to_s + ',"items":[' + items + ']}',
                  status: 200,
                  headers: { 'Content-Type' => 'text/json' })

      # API Record
      stub_request(:get, %r{#{Europeana::API.url}/record/[^/]+/[^/]+.json}).
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return do |request|
          id = request.uri.path.match(%r{/record(/[^/]+/[^/]+).json})[1]
          {
            body: '{"success":true,"object":{"about": "' + id + '", "title":["' + id + '"], "proxies": [{"dcCreator":{"def":["Mister Smith"]}}], "aggregations": [{"edmIsShownBy":"http://provider.example.com/ ' + id + '"}]}}',
            status: 200,
            headers: { 'Content-Type' => 'text/json' }
          }
        end

      # Hierarchy API
      stub_request(:get, %r{#{Europeana::API.url}/record/[^/]+/[^/]+/(self|parent|children|ancestor-self-siblings|precee?ding-siblings|following-siblings).json}).
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return(body: '{"success":false,"message":"This record has no hierarchical structure!"}',
                  status: 200,
                  headers: { 'Content-Type' => 'text/json' })

      # Media proxy
      stub_request(:head, %r{#{Rails.application.config.x.edm_is_shown_by_proxy}/[^/]+/[^/]+}).
        to_return(status: 200,
                  headers: { 'Content-Type' => 'application/pdf' })
    end
  end

  def an_api_search_request
    a_request(:get, Europeana::API.url + '/search.json').
      with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY']))
  end

  def an_api_record_request_for(id)
    a_request(:get, Europeana::API.url + "/record#{id}.json").
      with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY']))
  end

  def an_api_hierarchy_request_for(id)
    a_request(:get, %r{#{Europeana::API.url}/record#{id}/(self|parent|children|ancestor-self-siblings|precee?ding-siblings|following-siblings).json}).
      with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY']))
  end

  def a_media_proxy_request_for(id)
    a_request(:head, Rails.application.config.x.edm_is_shown_by_proxy + id)
  end
end
