RSpec.shared_context 'Annotations API', :annotations_api do
  let(:annotations_api_url) { 'https://www.example.com/api' }
  let(:annotations_api_create_method_url) { %r{\A#{annotations_api_url}/annotations/(\?|\z)} }
  let(:annotations_api_search_method_url) { %r{\A#{annotations_api_url}/annotations/search(\?|\z)} }
  let(:annotations_api_delete_method_url) { %r{\A#{annotations_api_url}/annotations/[^/]+/[^/]+(\?|\z)} }
  let(:annotations_api_key) { 'annotations_api_key' }
  let(:annotations_api_user_token) { 'annotations_api_user_token' }

  before(:each) do
    Rails.application.config.x.europeana[:annotations].api_url = annotations_api_url
    Rails.application.config.x.europeana[:annotations].api_key = annotations_api_key

    stub_request(:get, annotations_api_search_method_url).
      to_return(status: 200,
                body: api_responses(:annotations_search),
                headers: { 'Content-Type' => 'application/ld+json' })

    stub_request(:post, annotations_api_create_method_url).
      to_return(status: 200)

    stub_request(:delete, annotations_api_delete_method_url).
      to_return(status: 204)
  end

  def an_annotations_api_search_request_for(id)
    a_request(:get, annotations_api_search_method_url).
      with(query: hash_including(
        wskey: annotations_api_key,
        qf: %(target_uri:"http://data.europeana.eu/item#{id}")
      ))
  end
end
