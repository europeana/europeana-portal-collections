require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET index' do
    before do
      get :index
    end

    it { is_expected.not_to query_europeana_api }

    it 'renders the homepage Mustache template' do
      expect(response.status).to eq(200)
      expect(response).to render_template('templates/Search/Search-home')
    end
  end
end
