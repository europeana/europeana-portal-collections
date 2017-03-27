# frozen_string_literal: true
RSpec.describe GalleriesController do
  describe 'concerns' do
    subject { described_class }
    it { is_expected.to include(CacheHelper) }
    it { is_expected.to include(HomepageHeroImage) }
    it { is_expected.to include(PaginatedController) }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, locale: 'en'
      expect(response).to have_http_status(:success)
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

    context 'when the view was already cached' do
      before do
        allow(subject).to receive(:body_cached?) { true }
      end

      it 'does NOT searche the API for the gallery image metadata' do
        get :index, locale: 'en'
        expect(an_api_search_request).to_not have_been_made
      end
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

    it 'assigns the selected topic' do
      get :index, locale: 'en'
      expect(assigns(:selected_topic)).to be_a(String)
      expect(assigns(:selected_topic)).to eq('all')
    end

    context 'when filterd via topic' do
      let(:fashion_topic) { topics(:fashion_topic) }

      before do
        galleries(:fashion_dresses).topics
      end

      it 'assigns the selected topic' do
        get :index, locale: 'en', theme: 'fashion'
        expect(assigns(:selected_topic)).to be_a(String)
        expect(assigns(:selected_topic)).to eq('fashion')
      end

      it 'assigns published galleries with the applied topic categorization to @galleries' do
        get :index, locale: 'en', theme: 'fashion'
        expect(assigns[:galleries]).not_to be_blank
        assigns[:galleries].each do |gallery|
          expect(gallery).to be_published
          expect(gallery.topics).to include(fashion_topic)
        end
      end
    end

    context 'when there are no published galleries' do
      before do
        Gallery.published.destroy_all
      end

      it 'makes no API query' do
        get :index, locale: 'en'
        expect(an_api_search_request).not_to have_been_made
      end
    end

    context 'when requesting as an atom feed' do
      let(:format) { 'atom' }

      it 'returns http success' do
        get :index, locale: 'en', format: format
        expect(response).to have_http_status(:success)
      end

      it 'searches the API for the gallery image metadata' do
        get :index, locale: 'en', format: format
        ids = Gallery.published.map(&:images).flatten.map(&:europeana_record_id)
        api_query = %[europeana_id:("#{ids.join('" OR "')}")]
        expect(an_api_search_request.
          with(query: hash_including(query: api_query))).
          to have_been_made.at_least_once
      end

      it 'assigns image metadata to @documents' do
        get :index, locale: 'en', format: format
        expect(assigns(:documents)).to be_a(Array)
        assigns(:documents).each do |document|
          expect(document).to be_a(Europeana::Blacklight::Document)
        end
      end

      context 'when the view was already cached' do
        before do
          allow(subject).to receive(:body_cached?) { true }
        end

        it 'does NOT searche the API for the gallery image metadata' do
          get :index, locale: 'en', format: format
          expect(an_api_search_request).to_not have_been_made
        end
      end
    end
  end

  describe 'GET #show' do
    context 'when gallery is published' do
      let(:gallery) { galleries(:fashion_dresses) }

      it 'returns http success' do
        get :show, locale: 'en', slug: gallery.slug
        expect(response).to have_http_status(:success)
      end

      it 'assigns gallery to @gallery' do
        get :show, locale: 'en', slug: gallery.slug
        expect(assigns[:gallery]).to eq(gallery)
      end

      it 'assigns the edmIsShownBy of the first image to @hero_image_url' do
        get :show, locale: 'en', slug: gallery.slug
        expect(assigns[:hero_image_url]).to eq('providerurl/sample/record1')
      end

      it 'caches the hero_image_url' do
        expect(Rails.cache).to_not receive(:fetch)
        expect(Rails.cache).to receive(:write).with(an_instance_of(String), an_instance_of(String), expires_in: 24.hours + 1.minute)
        get :show, locale: 'en', slug: gallery.slug
      end

      it 'searches the API for the gallery image metadata' do
        get :show, locale: 'en', slug: gallery.slug
        ids = gallery.images.map(&:europeana_record_id)
        api_query = %[europeana_id:("#{ids.join('" OR "')}")]
        expect(an_api_search_request.
          with(query: hash_including(query: api_query))).
          to have_been_made.at_least_once
      end

      context 'when the view was already cached' do
        before do
          allow(subject).to receive(:body_cached?) { true }
        end

        it 'does NOT searche the API for the gallery image metadata' do
          get :show, locale: 'en', slug: gallery.slug
          expect(an_api_search_request).to_not have_been_made
        end

        it 'assigns a url from the cache to @hero_image_url' do
          expect(Rails.cache).to_not receive(:write)
          expect(Rails.cache).to receive(:fetch) { 'something' }
          get :show, locale: 'en', slug: gallery.slug
          expect(assigns[:hero_image_url]).to eq('something')
        end
      end
    end
  end
end
