module EuropeanaAPIHelper
  ##
  # Renders ERB fixtures with local variables
  class Fixture
    def self.empty_binding
      binding
    end

    def self.render(template_content, **locals)
      b = empty_binding
      locals.each { |k, v| b.local_variable_set(k, v) }
      ERB.new(template_content).result(b)
    end
  end

  ##
  # Renders one API response fixture, mimicking Rails fixture accessor naming
  #
  # API response fixtures are .json.erb files in spec/fixtures/api_response/
  #
  # @param name [Symbol] API response fixture name
  # @param locals [Hash] Local variables to pass to the ERB template
  # @return [String] JSON string for an API response to use in a stubbed request
  def api_responses(name, **locals)
    path = File.expand_path("../../../fixtures/api_response/#{name}.json.erb", __FILE__)
    Fixture.render(File.read(path), **locals)
  end

  def record_id_from_request_uri(request)
    request.uri.path.match(%r{/record(/[^/]+/[^/]+).json})[1]
  end

  # @todo move into europeana-api gem?
  RSpec.configure do |config|
    config.before(:each) do
      # API Search
      stub_request(:get, Europeana::API.url + '/search.json').
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return(body: api_responses(:search),
                  status: 200,
                  headers: { 'Content-Type' => 'text/json' })

      stub_request(:get, Europeana::API.url + '/search.json').
        with(query: hash_including(
          wskey: ENV['EUROPEANA_API_KEY'],
          facet: 'PROVIDER',
          rows: '0'
        )).
        to_return(
          body: api_responses(:search_facet_provider),
          status: 200,
          headers: { 'Content-Type' => 'text/json' })

      stub_request(:get, Europeana::API.url + '/search.json').
        with(query: hash_including(
          wskey: ENV['EUROPEANA_API_KEY'],
          facet: 'DATA_PROVIDER',
          rows: '0'
        )).
        to_return(
          body: api_responses(:search_facet_data_provider),
          status: 200,
          headers: { 'Content-Type' => 'text/json' })

      # API Record
      stub_request(:get, %r{#{Europeana::API.url}/record/[^/]+/[^/]+.json}).
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return do |request|
          {
            body: api_responses(:record, id: record_id_from_request_uri(request)),
            status: 200,
            headers: { 'Content-Type' => 'text/json' }
          }
        end

      # Record with dcterms:hasPart in proxy
      stub_request(:get, %r{#{Europeana::API.url}/record/with/dcterms:hasPart.json}).
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return do |request|
          {
            body: api_responses(:record_with_dcterms_haspart, id: record_id_from_request_uri(request)),
            status: 200,
            headers: { 'Content-Type' => 'text/json' }
          }
        end

      # Record with dcterms:isPartOf in proxy
      stub_request(:get, %r{#{Europeana::API.url}/record/with/dcterms:isPartOf.json}).
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return do |request|
          {
            body: api_responses(:record_with_dcterms_ispartof, id: record_id_from_request_uri(request)),
            status: 200,
            headers: { 'Content-Type' => 'text/json' }
          }
        end

      # Hierarchy API
      stub_request(:get, %r{#{Europeana::API.url}/record/[^/]+/[^/]+/(self|parent|children|ancestor-self-siblings|precee?ding-siblings|following-siblings).json}).
        with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
        to_return(body: api_responses(:no_hierarchy),
                  status: 200,
                  headers: { 'Content-Type' => 'text/json' })

      # Media proxy
      stub_request(:head, %r{#{Rails.application.config.x.europeana_media_proxy}/[^/]+/[^/]+}).
        to_return(status: 200,
                  headers: { 'Content-Type' => 'application/pdf' })
    end
  end

  def an_api_search_request
    a_request(:get, Europeana::API.url + '/search.json').
      with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY']))
  end

  def an_api_collection_search_request(collection_id)
    collection = Collection.find(collection_id)
    a_request(:get, Europeana::API.url + '/search.json').
      with(query: hash_including(
        { wskey: ENV['EUROPEANA_API_KEY'] }.merge(Rack::Utils.parse_query(collection.api_params))
      ))
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
    a_request(:head, Rails.application.config.x.europeana_media_proxy + id)
  end
end
