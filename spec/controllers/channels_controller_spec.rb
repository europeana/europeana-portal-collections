require 'rails_helper'

RSpec.describe ChannelsController, type: :controller do
  before do
    FactoryGirl.create(:error_page, :not_found)
  end

  describe 'GET index' do
    before do
      get :index
    end

    it 'does not query API' do
      expect(an_api_search_request).not_to have_been_made
    end

    it 'redirects to root' do
      expect(response).to redirect_to(root_url)
    end
  end

  describe 'GET show' do
    context 'with id=home' do
      before do
        channel.publish
        channel.save
        get :show, params
      end
      let(:channel) { FactoryGirl.create(:channel, :home) }
      let(:params) { { id: channel.key } }

      it 'does not query API' do
        expect(an_api_search_request).not_to have_been_made
      end

      it 'redirects to root' do
        expect(response).to redirect_to(root_url)
      end
    end

    context 'with id=[unknown channel]' do
      let(:params) { { id: 'unknown' } }

      it 'does not query API' do
        get :show, params
        expect(an_api_search_request).not_to have_been_made
      end

      it 'responds with 404' do
        get :show, params
        expect(response.status).to eq(404)
        expect(response).to render_template('pages/errors/not_found')
      end
    end

    context 'with id=[known channel]' do
      before do
        landing_page.publish
        landing_page.save
        channel.publish
        channel.save
        get :show, params
      end
      let(:channel) { FactoryGirl.create(:channel, :music) }
      let(:landing_page) { FactoryGirl.create(:landing_page, :music_channel) }

      context 'without search params' do
        let(:params) { { id: channel.key } }

        it 'should not query API for channel stats' do
          %w(TEXT VIDEO SOUND IMAGE 3D).each do |type|
            expect(an_api_search_request.with(query: hash_including(query: "TYPE:#{type}"))).not_to have_been_made
          end
        end

        it 'should not query API for recent additions' do
          expect(an_api_search_request.with(query: hash_including(query: /timestamp_created/))).not_to have_been_made
        end

        it 'renders channels landing template' do
          expect(response.status).to eq(200)
          expect(response).to render_template('channels/show')
        end

        it 'assigns @landing_page' do
          expect(assigns(:landing_page)).to eq(landing_page)
        end
      end

      context 'with search params' do
        let(:params) { { id: channel.key, q: 'search' } }

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
