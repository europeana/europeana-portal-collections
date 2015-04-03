require 'rails_helper'

RSpec.describe ChannelsController, type: :controller do
  describe 'GET index' do
    it 'renders templates/Search/Search-home' do
      get :index
      expect(response.status).to eq(200)
      expect(response).to render_template('templates/Search/Search-home')
    end
  end

  describe 'GET show' do
    context 'with id=home' do
      let(:params) { { id: 'home' } }
      it 'redirects to index' do
        get :show, params
        expect(response).to redirect_to(action: :index)
      end
    end

    context 'with id=[unknown channel]' do
      let(:params) { { id: 'unknown' } }
      it 'responds with 404' do
        get :show, params
        expect(response.status).to eq(404)
        expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
      end
    end

    context 'with id=[known channel]' do
      before do
        # stub portal channels config to know about this channel
        # prevent actual Europeana API calls
      end

      context 'without search params' do
        let(:params) { { id: 'known' } }
        it 'renders show' do
          get :show, params
          expect(response.status).to eq(200)
          expect(response).to render_template('show')
        end
      end

      context 'without search params' do
        let(:params) { { id: 'known', q: 'search' } }
        it 'renders templates/Search/Search-results-list' do
          get :show, params
          expect(response.status).to eq(200)
          expect(response).to render_template('templates/Search/Search-results-list')
        end
      end
    end
  end
end
