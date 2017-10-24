RSpec.describe  GalleryValidationJob do

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
          edmIsShownBy: options[:edm_is_shown_by] ? ["http://www.example.com/media#{id}"] : nil,
          type: options[:type]
        }
      end
    end
  end

  def provider_response(**options)
    content_type = options[:content_type] || 'image/jpeg'
    code = options[:code] || 200
    double('provider_response', code: code, headers: { content_type: content_type })
  end

  context 'when everything is valid' do
    it 'loads all the images for the gallery and makes sure they are valid' do

      expect(RestClient).to receive(:get).with(gallery_images(:fashion_dresses_image1).image_url).once { provider_response }
      expect(RestClient).to receive(:get).with(gallery_images(:fashion_dresses_image2).image_url).once { provider_response }
      subject.perform(galleries(:fashion_dresses).id)
      expect(an_api_search_request).to have_been_made.at_least_once
    end
  end

  context 'when a record can NOT be found' do
    it 'sends an email saying the record may be delted' do

    end
  end


  context 'when an image can NOT be found' do
    it 'sends an email saying the image is not valid' do

    end
  end

  context 'when an image is NOT a valid image' do
    it 'sends an email saying the image is not valid' do

    end
  end

end
