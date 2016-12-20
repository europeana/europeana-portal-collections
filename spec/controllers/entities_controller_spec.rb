# frozen_string_literal: true
RSpec.describe EntitiesController do
  describe 'GET #suggest' do
    it 'returns http success' do
      get :suggest
      expect(response).to have_http_status(:success)
    end
  end
end
