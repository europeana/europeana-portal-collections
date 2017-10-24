# frozen_string_literal: true

RSpec.shared_context 'Gallery Image request', :gallery_image_request do
  before do
    stub_request(:get, Europeana::API.url + '/v2/search.json').
      with(query: hash_including(
        wskey: ENV['EUROPEANA_API_KEY'],
        query: /\Aeuropeana_id:\(.*\)\z/,
        rows: '100',
        profile: 'rich'
      )).
      to_return do |request|
      query_param = Rack::Utils.parse_nested_query(request.uri.query)['query']
      ids = query_param.scan(/"([^"]+)"/).flatten
      {
        body: gallery_image_search_api_response(ids, gallery_image_search_api_response_options).to_json,
        status: 200,
        headers: { 'Content-Type' => 'application/json' }
      }
    end
  end

  let(:gallery_image_search_api_response_options) { {} }

  def gallery_image_search_api_response(ids, **options)
    options.reverse_merge!(item: true, edm_is_shown_by: true, type: 'IMAGE')
    {
      success: true,
      itemsCount: ids.size,
      totalResults: ids.size,
      items: gallery_image_search_api_response_items(ids, **options)
    }
  end

  def gallery_image_search_api_response_items(ids, **options)
    if !options[:item]
      nil
    else
      ids.map do |id|
        {
          id: id,
          edmIsShownBy: options[:edm_is_shown_by] ? "http://www.example.com/media#{id}" : nil,
          type: options[:type]
        }
      end
    end
  end

  def gallery_image_portal_urls(number: 10, format: 'http://www.europeana.eu/portal/record/sample/record%{n}.html')
    (1..number).map { |n| format(format, n: n) }.join(' ')
  end
end
