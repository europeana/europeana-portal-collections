# frozen_string_literal: true

RSpec.shared_context :collection_with_custom_api_url do
  before do
    stub_request(:get, "#{collection.api_url}/v2/search.json").
      with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
      to_return(body: api_responses(:search),
                status: 200,
                headers: { 'Content-Type' => 'application/json' })
  end
end
