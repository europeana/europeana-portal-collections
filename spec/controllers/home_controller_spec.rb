require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe 'GET index' do
    before do
      home_landing_page = FactoryGirl.create(:landing_page, :home)
      home_landing_page.publish
      home_landing_page.save
      home_channel = FactoryGirl.create(:channel, :home)
      home_channel.publish
      home_channel.save
      get :index
    end

    it 'should not get total record count from API' do
      expect(an_api_search_request).not_to have_been_made
    end

    it 'renders the homepage Mustache template' do
      expect(response.status).to eq(200)
      expect(response).to render_template('home/index')
    end
  end
end
