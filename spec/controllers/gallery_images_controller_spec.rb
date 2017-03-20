# frozen_string_literal: true
RSpec.describe GalleryImagesController do
  describe '#show' do
    context 'when gallery is published' do
      let(:gallery) { galleries(:fashion_dresses) }
      let(:image) { gallery.images.first }
      let(:params) { { locale: 'en', gallery_slug: gallery.slug, position: image.position, format: 'json' } }

      it 'returns http success' do
        get :show, params
        expect(response).to have_http_status(:success)
      end

      it 'assigns gallery to @gallery' do
        get :show, params
        expect(assigns[:gallery]).to eq(gallery)
      end

      it 'assigns image to @image' do
        get :show, params
        expect(assigns[:image]).to eq(image)
      end

      it 'requests image metadata from the record API' do
        get :show, params
        expect(an_api_record_request_for(image.europeana_record_id)).
          to have_been_made.at_least_once
      end
    end
  end
end
