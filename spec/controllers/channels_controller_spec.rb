require 'rails_helper'

RSpec.describe ChannelsController, type: :controller do
  describe 'GET index' do
    before do
      get :index
    end

    it { is_expected.not_to query_europeana_api }

    it 'redirects to root' do
      expect(response).to redirect_to(root_url)
    end
  end

  describe 'GET show' do
    before do
      get :show, params
    end

    context 'with id=home' do
      let(:params) { { id: 'home' } }

      it { is_expected.not_to query_europeana_api }

      it 'redirects to root' do
        expect(response).to redirect_to(root_url)
      end
    end

    context 'with id=[unknown channel]' do
      let(:params) { { id: 'unknown' } }

      it 'responds with 404' do
        expect(response.status).to eq(404)
        expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
      end
    end

    context 'with id=[known channel]' do
      let(:channel_id) { Europeana::Portal::Application.config.channels.keys.reject { |k| k == :home }.first }
      before do
#        channel = class_double(Channel).as_stubbed_const
#        allow(channel).to receive(:find).and_return(instance_double('Channel'))
        # stub portal channels config to know about this channel
      end

      context 'without search params' do
        let(:params) { { id: channel_id } }

        it 'renders channels landing template' do
          expect(response.status).to eq(200)
          expect(response).to render_template('templates/Search/Channels-landing')
        end
      end

      context 'with search params' do
        let(:params) { { id: channel_id, q: 'search' } }

        it 'renders search results template' do
          expect(response.status).to eq(200)
          expect(response).to render_template('templates/Search/Search-results-list')
        end
      end
    end
  end
end
