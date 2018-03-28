# frozen_string_literal: true

RSpec.describe HomeController do
  describe 'GET index' do
    it 'should not get total record count from API' do
      get :index, locale: 'en'
      expect(an_api_search_request).not_to have_been_made
    end

    it 'renders the homepage Mustache template' do
      get :index, locale: 'en'
      expect(response.status).to eq(200)
      expect(response).to render_template('home/index')
    end
  end
end
