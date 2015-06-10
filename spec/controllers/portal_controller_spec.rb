require 'rails_helper'

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
          get :index, params
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
          get :index, params
          expect(response.status).to eq(200)
          expect(response).to render_template('templates/Search/Search-results-list')
        end
      end
    end
  end
end
