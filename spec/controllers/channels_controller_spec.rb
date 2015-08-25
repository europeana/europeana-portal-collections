require 'rails_helper'

RSpec.describe ChannelsController, type: :controller do
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
    before do
      get :show, params
    end

    context 'with id=home' do
      let(:channel) { FactoryGirl.create(:channel, key: 'home') }
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
        expect(an_api_search_request).not_to have_been_made
      end

      it 'responds with 404' do
        expect(response.status).to eq(404)
        expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
      end
    end

    context 'with id=[known channel]' do
      let(:channel) { FactoryGirl.create(:channel, :music) }

      context 'without search params' do
        let(:params) { { id: channel.key } }

        it 'queries API for channel stats' do
          %w(TEXT VIDEO SOUND IMAGE 3D).each do |type|
            expect(an_api_search_request.with(query: hash_including(query: "TYPE:#{type}"))).to have_been_made.once
          end
        end

        it 'queries API for recent additions' do
          expect(an_api_search_request.with(query: hash_including(query: /timestamp_created/))).to have_been_made.at_least_times(1)
          expect(an_api_search_request.with(query: hash_including(query: /timestamp_created/))).to have_been_made.at_most_times(3)
        end

        it 'does not get RSS blog posts' do
          expect(a_europeana_blog_request).not_to have_been_made
        end

        it 'renders channels landing template' do
          expect(response.status).to eq(200)
          expect(response).to render_template('channels/show')
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
