# frozen_string_literal: true
RSpec.describe FederationsController do
  describe '#show' do
    context 'when within the all collection' do
      let(:collection) { collections(:all) }
      let(:provider) { 'dpla' }
      let(:query) { 'searchterm' }
      let(:params) { { locale: 'en', id: provider, collection: collection.key, query: query, format: 'json' } }

      it 'returns http success' do
        get :show, params
        expect(response).to have_http_status(:success)
      end
    end
  end
end
