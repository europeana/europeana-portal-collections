require 'support/shared_examples/more_like_this_api_request'

RSpec.describe PortalController, type: :controller do
  describe 'GET index' do
    context 'without q param' do
      it 'redirects to root' do
        get :index
        expect(response).to redirect_to(root_url)
      end
    end

    context 'with q param' do
      before do
        get :index, params
      end

      context 'when q param empty' do
        let(:params) { { q: '' } }

        it 'searches the API' do
          expect(an_api_search_request.
            with(query: hash_including(query: '*:*'))).to have_been_made.at_least_once
        end

        it 'renders the search results Mustache template' do
          expect(response.status).to eq(200)
          expect(response).to render_template('templates/Search/Search-results-list')
        end
      end

      context 'when q param non-empty' do
        let(:params) { { q: 'paris' } }

        it 'searches the API' do
          expect(an_api_search_request.
            with(query: hash_including(query: 'paris'))).to have_been_made.at_least_once
        end

        it 'renders the search results Mustache template' do
          expect(response.status).to eq(200)
          expect(response).to render_template('templates/Search/Search-results-list')
        end
      end

      context 'with mlt param' do
        let(:params) { { mlt: '/abc/123' } }

        it_behaves_like 'a more like this api request' do
          let(:record_id) { params[:mlt] }
        end
      end
    end
  end

  describe 'GET similar' do
    context 'when format is JSON' do
      before do
        get :similar, params
      end
      let(:params) { { id: 'abc/123', format: 'json' } }
      it_behaves_like 'a more like this api request' do
        let(:record_id) { '/' + params[:id] }
      end
      it 'responds with JSON' do
        expect(response.content_type).to eq('application/json')
      end
      it 'has 200 status code' do
        expect(response.status).to eq(200)
      end
      it 'renders JSON ERB template' do
        expect(response).to render_template('portal/similar')
      end
      it 'accepts pagination params'
    end

    context 'when format is HTML' do
      let(:params) { { id: 'abc/123', format: 'html' } }
      it 'returns an unknown format error' do
        expect { get :similar, params }.to raise_error(ActionController::UnknownFormat)
      end
    end
  end
end
