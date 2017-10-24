# frozen_string_literal: true
require 'models/concerns/is_permissionable_examples'
RSpec.describe Gallery do
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

  def gallery_image_portal_urls(number: 10, format: 'http://www.europeana.eu/portal/record/sample/record%{n}.html')
    (1..number).map { |n| format(format, n: n) }.join(' ')
  end

  it_behaves_like 'permissionable'

  it { is_expected.to have_many(:images).inverse_of(:gallery).dependent(:destroy) }
  it { is_expected.to have_many(:topics).through(:categorisations) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_length_of(:title).is_at_most(60) }
  it { is_expected.to validate_length_of(:description).is_at_most(280) }
  it { is_expected.to be_versioned }
  it { is_expected.to accept_nested_attributes_for(:images).allow_destroy(true) }
  it { is_expected.to accept_nested_attributes_for(:translations).allow_destroy(true) }

  it 'should have publication states' do
    expect(described_class).to include(HasPublicationStates)
  end

  it 'should be categorisable' do
    expect(described_class).to include(IsCategorisable)
  end

  context 'publishing' do
    let(:stubbed_now) { DateTime.now }
    let(:gallery) { galleries(:draft) }
    before do
      stubbed_now # Calling to set this, and avoid infinite recursion
      allow(DateTime).to receive(:now) { stubbed_now }
      allow(gallery).to receive(:validate_image_source_items) { true }
      allow(gallery).to receive(:validate_number_of_image_portal_urls) { true }
      allow(gallery).to receive(:validate_image_portal_urls) { true }
      allow(::PaperTrail).to receive(:whodunnit) { users(:user) }
    end

    it 'should set the publisher and published_at date when first publishing' do
      gallery.publish!
      expect(gallery.published_at).to eq(stubbed_now)
      expect(gallery.publisher).to eq(users(:user))
    end

    it 'should NOT modify the publisher and published_at date when un and re-publishing' do
      gallery.publish!
      gallery.unpublish!
      allow(DateTime).to receive(:now) { stubbed_now + 1.hour }
      allow(::PaperTrail).to receive(:whodunnit) { users(:admin) }
      gallery.publish!
      expect(gallery.published_at).to eq(stubbed_now)
      expect(gallery.publisher).to eq(users(:user))
    end
  end

  it 'should translate title' do
    expect(described_class.translated_attribute_names).to include(:title)
  end

  it 'should enforce unique titles' do
    g1 = Gallery.create!(title: 'Stuff', image_portal_urls: gallery_image_portal_urls)
    g2 = Gallery.create!(title: 'Stuff', image_portal_urls: gallery_image_portal_urls)
    g3 = Gallery.create!(title: 'Stuff', image_portal_urls: gallery_image_portal_urls)
    expect(g1.reload.title).to eq('Stuff')
    expect(g2.reload.title).to eq('Stuff 1')
    expect(g3.reload.title).to eq('Stuff 2')
  end

  it 'should translate description' do
    expect(described_class.translated_attribute_names).to include(:description)
  end

  describe '#to_param' do
    it 'should return the slug' do
      gallery = Gallery.new(title: 'Pianos', slug: 'pianos')
      expect(gallery.to_param).to eq('pianos')
    end
  end

  describe '#image_portal_urls' do
    it 'should return a new line-separated list of gallery image record URLs' do
      expect(galleries(:fashion_dresses).image_portal_urls).to eq("http://www.europeana.eu/portal/record/sample/record1.html\n\nhttp://www.europeana.eu/portal/record/sample/record2.html")
    end
  end

  describe '#set_images_from_portal_urls' do
    context '(on create)' do
      let(:gallery) { Gallery.new(title: 'Pictures', image_portal_urls: gallery_image_portal_urls(number: 10)) }

      it 'should create images for new URLs' do
        gallery.save
        expect(gallery.images.count).to eq(10)
        gallery.images.reload
        (1..10).each do |number|
          expect(gallery.images.detect { |image| image.europeana_record_id == "/sample/record#{number}" }).not_to be_blank
        end
      end

      it 'should set image position' do
        gallery.save
        gallery.images.reload
        expect(gallery.images.detect { |image| image.europeana_record_id == '/sample/record1' }.position).to eq(1)
        expect(gallery.images.detect { |image| image.europeana_record_id == '/sample/record2' }.position).to eq(2)
      end
    end

    context '(on update)' do
      let(:gallery) { Gallery.create(title: 'Pictures', image_portal_urls: gallery_image_portal_urls(number: 10)) }

      it 'should create images for new URLs' do
        gallery.image_portal_urls = gallery_image_portal_urls(number: 20)
        gallery.save
        gallery.images.reload
        (1..20).each do |number|
          expect(gallery.images.detect { |image| image.europeana_record_id == "/sample/record#{number}" }).not_to be_blank
        end
      end

      it 'should set image position' do
        gallery.images.find_by_europeana_record_id('/sample/record1').update_attributes(position: 2)
        gallery.images.find_by_europeana_record_id('/sample/record2').update_attributes(position: 1)
        gallery.image_portal_urls = gallery_image_portal_urls(number: 20)
        gallery.save
        gallery.images.reload
        expect(gallery.images.detect { |image| image.europeana_record_id == '/sample/record1' }.position).to eq(1)
        expect(gallery.images.detect { |image| image.europeana_record_id == '/sample/record2' }.position).to eq(2)
      end

      it 'should delete images for absent URLs' do
        gallery.image_portal_urls = gallery_image_portal_urls(number: 8)
        gallery.save!
        expect(gallery.images.reload.count).to eq(8)
      end
    end
  end

  it 'should validate image URLs before saving' do
    gallery = galleries(:empty)
    gallery.image_portal_urls = gallery_image_portal_urls(format: 'http://www.example.com/%{n}')
    expect(gallery).not_to be_valid
    expect(gallery.errors[:image_portal_urls]).not_to be_none
  end

  it 'should require 6-48 images' do
    gallery = galleries(:empty)
    (1..50).each do |number|
      gallery.image_portal_urls = gallery_image_portal_urls(number: number)
      if number < 6 || number > 48
        expect(gallery).not_to be_valid
        expect(gallery.errors[:image_portal_urls]).not_to be_none
      else
        expect(gallery).to be_valid
      end
    end
  end

  describe 'per-image API response validation' do
    context 'when image_portal_urls has other errors' do
      it 'is skipped' do
        gallery = Gallery.new
        gallery.valid?
        expect(gallery.errors[:image_portal_urls]).not_to be_none
        expect(an_api_search_request).not_to have_been_made
      end
    end

    context 'when image_portal_urls has no other errors' do
      it 'is performed' do
        gallery = galleries(:empty)
        gallery.image_portal_urls = gallery_image_portal_urls
        expect(gallery).to be_valid
        expect(an_api_search_request).to have_been_made.once
      end

      context 'when images have no item in API response' do
        let(:gallery_image_search_api_response_options) { { item: false } }
        it 'is invalid' do
          gallery = galleries(:empty)
          gallery.image_portal_urls = gallery_image_portal_urls
          expect(gallery).not_to be_valid
          expect(gallery.errors[:image_portal_urls]).not_to be_none
          expect(gallery.errors[:image_portal_urls]).to include(match('item not found by the API'))
        end
      end

      context 'when items in API response are type="TEXT"' do
        let(:gallery_image_search_api_response_options) { { type: 'TEXT' } }
        it 'is valid' do
          gallery = galleries(:empty)
          gallery.image_portal_urls = gallery_image_portal_urls
          expect(gallery).to be_valid
          expect(gallery.errors[:image_portal_urls]).to be_none
        end
      end

      context 'when items in API response are type="SOUND"' do
        let(:gallery_image_search_api_response_options) { { type: 'SOUND' } }
        it 'is invalid' do
          gallery = galleries(:empty)
          gallery.image_portal_urls = gallery_image_portal_urls
          expect(gallery).not_to be_valid
          expect(gallery.errors[:image_portal_urls]).not_to be_none
          expect(gallery.errors[:image_portal_urls]).to include(match('item has type "SOUND", not'))
        end
      end

      context 'when items in API response have no edm:isShownBy' do
        let(:gallery_image_search_api_response_options) { { edm_is_shown_by: false } }
        it 'is invalid' do
          gallery = galleries(:empty)
          gallery.image_portal_urls = gallery_image_portal_urls
          expect(gallery).not_to be_valid
          expect(gallery.errors[:image_portal_urls]).not_to be_none
          expect(gallery.errors[:image_portal_urls]).to include(match('item has no edm:isShownBy'))
        end
      end
    end
  end
end
