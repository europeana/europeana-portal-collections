# frozen_string_literal: true
RSpec.describe GalleriesController do
  describe 'documents' do
    let(:images_array) { Gallery.published.map(&:images).flatten }

    it 'searches the API for the gallery image metadata' do
      subject.instance_variable_set(:@images, images_array)
      subject.send(:documents)
      ids = images_array.map(&:europeana_record_id)
      api_query = %[europeana_id:("#{ids.join('" OR "')}")]
      expect(an_api_search_request.
        with(query: hash_including(query: api_query))).
        to have_been_made.at_least_once
      expect(assigns(:documents)).to be_a(Array)
      assigns(:documents).each do |document|
        expect(document).to be_a(Europeana::Blacklight::Document)
      end
    end
  end

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

    it 'assigns all images to @images' do
      get :index, locale: 'en'
      expect(assigns(:images)).to be_a(Array)
      assigns(:images).each do |image|
        expect(image).to be_a(GalleryImage)
      end
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

      it 'assigns gallery to @gallery' do
        get :show, locale: 'en', slug: gallery.slug
        expect(assigns[:gallery]).to eq(gallery)
      end

      it 'assigns all images to @images' do
        get :show, locale: 'en', slug: gallery.slug
        expect(assigns(:images)).to eq(gallery.images)
      end
    end
  end
end
