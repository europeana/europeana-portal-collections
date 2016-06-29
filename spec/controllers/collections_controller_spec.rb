RSpec.describe CollectionsController do
  describe 'GET index' do
    before do
      get :index, { locale: 'en' }
    end

    it 'does not query API' do
      expect(an_api_search_request).not_to have_been_made
    end

    it 'redirects to home' do
      expect(response).to redirect_to(home_url)
    end
  end

  describe 'GET show' do
    context 'with id=all' do
      before do
        get :show, params
      end
      let(:collection) { Collection.find_by_key('all') }
      let(:params) { { locale: 'en', id: collection.key } }

      it 'does not query API' do
        expect(an_api_search_request).not_to have_been_made
      end

      it 'redirects to home' do
        expect(response).to redirect_to(home_url)
      end
    end

    context 'with id=[unknown collection]' do
      let(:params) { { locale: 'en', id: 'unknown' } }

      it 'does not query API' do
        get :show, params
        expect(an_api_search_request).not_to have_been_made
      end

      it 'responds with 404' do
        get :show, params
        expect(response.status).to eq(404)
        expect(response).to render_template('pages/custom/errors/not_found')
      end
    end

    context 'with id=[known collection]' do
      before do
        get :show, params
      end
      let(:collection) { Collection.find_by_key('music') }
      let(:landing_page) { Page::Landing.find_by_slug('collections/music') }

      context 'without search params' do
        let(:params) { { locale: 'en', id: collection.key } }

        it 'should not query API for collection stats' do
          %w(TEXT VIDEO SOUND IMAGE 3D).each do |type|
            expect(an_api_search_request.with(query: hash_including(query: "TYPE:#{type}"))).not_to have_been_made
          end
        end

        it 'should not query API for recent additions' do
          expect(an_api_search_request.with(query: hash_including(query: /timestamp_created/))).not_to have_been_made
        end

        it 'renders collections landing template' do
          expect(response.status).to eq(200)
          expect(response).to render_template('collections/show')
        end

        it 'assigns @landing_page' do
          expect(assigns(:landing_page)).to eq(landing_page)
        end
      end

      context 'with search params' do
        let(:params) { { locale: 'en', id: collection.key, q: 'search' } }

        it 'queries API' do
          expect(an_api_search_request).to have_been_made.at_least_once
        end

        it 'renders search results template' do
          expect(response.status).to eq(200)
          expect(response).to render_template('portal/index')
        end
      end
    end
  end
end
