# frozen_string_literal: true

require 'support/shared_examples/jobs'

shared_examples 'colour facet caching job' do
  it_behaves_like 'a caching job'
  it_behaves_like 'an API requesting job'

  it 'should write colour facets to cache' do
    subject.perform(*args)
    cached = Rails.cache.fetch(cache_key)
    expect(cached).to be_a(Array)
    cached.each do |facet|
      expect(facet).to respond_to(:hits)
      expect(facet).to respond_to(:value)
    end
  end
end

RSpec.describe Cache::ColourFacetsJob do
  context 'without collection ID' do
    let(:cache_key) { 'browse/colours/facets' }
    let(:args) {}
    let(:api_request) { an_api_search_request }

    it_behaves_like 'colour facet caching job'
  end

  context 'with collection ID' do
    let(:collection) { Collection.published.first }
    let(:cache_key) { "browse/colours/facets/#{collection.key}" }
    let(:args) { collection.id }
    let(:api_request) { an_api_collection_search_request(collection.id) }

    it_behaves_like 'colour facet caching job'
  end
end
