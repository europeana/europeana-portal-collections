# frozen_string_literal: true

module EuropeanaAPIHelper
  def record_id_from_request_uri(request)
    request.uri.path.match(%r{/record(/[^/]+/[^/]+).json})[1]
  end

  # @todo move into europeana-api gem?
  RSpec.configure do |config|
    config.before(:each) do
      # API Search
      stub_request(:get, Europeana::API.url + '/v2/search.json').
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return(body: api_responses(:search),
                  status: 200,
                  headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, Europeana::API.url + '/v2/search.json').
        with(query: hash_including(
          wskey: ENV['EUROPEANA_API_KEY'],
          facet: 'PROVIDER',
          rows: '0'
        )).
        to_return(
          body: api_responses(:search_facet_provider),
          status: 200,
          headers: { 'Content-Type' => 'application/json' }
        )

      stub_request(:get, Europeana::API.url + '/v2/search.json').
        with(query: hash_including(
          wskey: ENV['EUROPEANA_API_KEY'],
          facet: 'DATA_PROVIDER',
          rows: '0'
        )).
        to_return(
          body: api_responses(:search_facet_data_provider),
          status: 200,
          headers: { 'Content-Type' => 'application/json' }
        )

      # API Record
      stub_request(:get, %r{#{Europeana::API.url}/v2/record/[^/]+/[^/]+.json}).
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return do |request|
          {
            body: api_responses(:record, id: record_id_from_request_uri(request)),
            status: 200,
            headers: { 'Content-Type' => 'application/json' }
          }
        end

      # Record with dcterms:hasPart in proxy
      stub_request(:get, %r{#{Europeana::API.url}/v2/record/with/dcterms:hasPart.json}).
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return do |request|
          {
            body: api_responses(:record_with_dcterms_haspart, id: record_id_from_request_uri(request)),
            status: 200,
            headers: { 'Content-Type' => 'application/json' }
          }
        end

      # Record with dcterms:isPartOf in proxy
      stub_request(:get, %r{#{Europeana::API.url}/v2/record/with/dcterms:isPartOf.json}).
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return do |request|
          {
            body: api_responses(:record_with_dcterms_ispartof, id: record_id_from_request_uri(request)),
            status: 200,
            headers: { 'Content-Type' => 'application/json' }
          }
        end

      # Record with dcterms:isPartOf in proxy
      stub_request(:get, %r{#{Europeana::API.url}/v2/record/with/colourpalette.json}).
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return do |request|
          {
            body: api_responses(:record_with_colourpalette, id: record_id_from_request_uri(request)),
            status: 200,
            headers: { 'Content-Type' => 'application/json' }
          }
        end

      # Record with edm:dataProvider in aggregation
      stub_request(:get, %r{#{Europeana::API.url}/v2/record/with/edm:dataProvider.json}).
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return do |request|
          {
            body: api_responses(:record_with_edm_dataprovider, id: record_id_from_request_uri(request)),
            status: 200,
            headers: { 'Content-Type' => 'application/json' }
          }
        end

      # Hierarchy API
      stub_request(:get, %r{#{Europeana::API.url}/v2/record/[^/]+/[^/]+/(self|parent|children|ancestor-self-siblings|precee?ding-siblings|following-siblings).json}).
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return(body: api_responses(:no_hierarchy),
                  status: 200,
                  headers: { 'Content-Type' => 'application/json' })

      # Media proxy
      stub_request(:head, %r{#{Rails.application.config.x.europeana_media_proxy}/[^/]+/[^/]+}).
        to_return(status: 200,
                  headers: { 'Content-Type' => 'application/pdf' })
    end
  end

  def an_api_search_request
    a_request(:get, Europeana::API.url + '/v2/search.json').
      with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY']))
  end

  def an_api_collection_search_request(collection_id)
    collection = Collection.find(collection_id)
    a_request(:get, Europeana::API.url + '/v2/search.json').
      with(query: hash_including(
        { wskey: ENV['EUROPEANA_API_KEY'] }.merge(Rack::Utils.parse_query(collection.api_params))
      ))
  end

  def an_api_record_request_for(id, format: 'json')
    a_request(:get, Europeana::API.url + "/v2/record#{id}.#{format}").
      with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY']))
  end

  def an_api_hierarchy_request_for(id)
    a_request(:get, %r{#{Europeana::API.url}/v2/record#{id}/(self|parent|children|ancestor-self-siblings|precee?ding-siblings|following-siblings).json}).
      with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY']))
  end

  def a_media_proxy_request_for(id)
    a_request(:head, Rails.application.config.x.europeana_media_proxy + id)
  end
end
