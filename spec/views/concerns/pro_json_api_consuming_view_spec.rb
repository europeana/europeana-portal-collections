# frozen_string_literal: true

RSpec.describe ProJsonApiConsumingView do
  let(:view_class) do
    Class.new do
      include ProJsonApiConsumingView
    end
  end

  let(:view_instance) { view_class.new }

  describe '#pro_json_api_posts_for_record_url' do
    subject { view_instance.send(:pro_json_api_posts_for_record_url, record_id) }

    let(:record_id) { '/123/abc' }
    let(:query_params) { Rack::Utils.parse_nested_query(URI.parse(subject).query) }

    it 'starts with Pro site base URL plus "posts"' do
      expect(subject).to start_with(Pro::Base.site + 'posts')
    end

    it 'is sorted by -datepublish' do
      expect(query_params['sort']).to eq('-datepublish')
    end

    it 'has page size 6' do
      expect(query_params['page']['size']).to eq('6')
    end

    it 'filters by image_attribution_link containing record ID' do
      expect(query_params['contains']['image_attribution_link']).to eq(record_id)
    end
  end
end
