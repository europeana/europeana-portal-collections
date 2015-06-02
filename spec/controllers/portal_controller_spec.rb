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
      let(:params) { { q: 'paris' } }

      before do
        get :index, params
      end

      it 'searches the API' do
        expect(an_api_search_request.
          with(query: hash_including(query: 'paris'))).to have_been_made
      end

      it 'renders the search results Mustache template' do
        get :index, params
        expect(response.status).to eq(200)
        expect(response).to render_template('templates/Search/Search-results-list')
      end
    end
  end
end
