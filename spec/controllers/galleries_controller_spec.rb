# frozen_string_literal: true
RSpec.describe GalleriesController do
  describe 'GET #index' do
    it 'returns http success' do
      get :index, locale: 'en'
      expect(response).to have_http_status(:success)
    end

    it 'assigns published galleries to @galleries' do
      get :index, locale: 'en'
      expect(assigns[:galleries]).not_to be_blank
      assigns[:galleries].each do |gallery|
        expect(gallery).to be_published
      end
    end

    it 'paginates galleries' do
      allow_any_instance_of(Gallery).to receive(:validate_image_source_items) { true }
      (1..30).each do |gallery_num|
        urls = (1..6).map { |image_num| "http://www.europeana.eu/portal/record/#{gallery_num}/#{image_num}.html" }.join(' ')
        Gallery.create!(title: "Gallery #{gallery_num}", image_portal_urls: urls).publish!
      end

      get :index, locale: 'en'
      expect(assigns[:galleries].length).to eq(24)
    end

    it 'searches the API for the gallery image metadata' do
      get :index, locale: 'en'
      ids = Gallery.published.map(&:images).flatten.map(&:europeana_record_id)
      api_query = %[europeana_id:("#{ids.join('" OR "')}")]
      expect(an_api_search_request.
        with(query: hash_including(query: api_query))).
        to have_been_made.at_least_once
    end

    it 'assigns image metadata to @documents' do
      get :index, locale: 'en'
      expect(assigns(:documents)).to be_a(Array)
      assigns(:documents).each do |document|
        expect(document).to be_a(Europeana::Blacklight::Document)
      end
    end
  end

  describe 'GET #show' do
    context 'when gallery is published' do
      let(:gallery) { Gallery.published.first }

      it 'returns http success' do
        get :show, locale: 'en', slug: gallery.slug
        expect(response).to have_http_status(:success)
      end

      it 'assigns gallery to @gallery' do
        get :show, locale: 'en', slug: gallery.slug
        expect(assigns[:gallery]).to eq(gallery)
      end

      it 'searches the API for the gallery image metadata' do
        get :show, locale: 'en', slug: gallery.slug
        ids = gallery.images.map(&:europeana_record_id)
        api_query = %[europeana_id:("#{ids.join('" OR "')}")]
        expect(an_api_search_request.
          with(query: hash_including(query: api_query))).
          to have_been_made.at_least_once
      end
    end
  end
end
