# frozen_string_literal: true

RSpec.describe CollectionsController do
  describe 'GET index' do
    before do
      get :index, locale: 'en', format: format
    end

    context 'when requesting as html' do
      let(:format) { 'html' }
      it 'does not query API' do
        expect(an_api_search_request).not_to have_been_made
      end

      it 'redirects to home' do
        expect(response).to redirect_to(home_url)
      end
    end

    context 'when requesting as an rss feed' do
      let(:format) { 'rss' }
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET show' do
    context 'with id=all' do
      before do
        get :show, params
      end
      let(:collection) { Collection.find_by_key('all') }
      let(:params) { { locale: 'en', id: collection.key } }

      it 'does not query API' do
        expect(an_api_search_request).not_to have_been_made
      end

      it 'redirects to home' do
        expect(response).to redirect_to(home_url)
      end
    end

    context 'with id=[unknown collection]' do
      let(:params) { { locale: 'en', id: 'unknown' } }

      it 'does not query API' do
        get :show, params
        expect(an_api_search_request).not_to have_been_made
      end

      it 'responds with 404' do
        get :show, params
        expect(response.status).to eq(404)
        expect(response).to render_template('pages/custom/errors/not_found')
      end
    end

    context 'with id=[known collection]' do
      let(:collection) { Collection.find_by_key('music') }
      let(:landing_page) { Page::Landing.find_by_slug('collections/music') }

      context 'without search params' do
        let(:params) { { locale: 'en', id: collection.key } }

        it 'should not query API for collection stats' do
          get :show, params
          %w(TEXT VIDEO SOUND IMAGE 3D).each do |type|
            expect(an_api_search_request.with(query: hash_including(query: "TYPE:#{type}"))).not_to have_been_made
          end
        end

        it 'should not query API for recent additions' do
          get :show, params
          expect(an_api_search_request.with(query: hash_including(query: /timestamp_created/))).not_to have_been_made
        end

        it 'renders collections landing template' do
          get :show, params
          expect(response.status).to eq(200)
          expect(response).to render_template('collections/show')
        end

        it 'assigns @landing_page' do
          get :show, params
          expect(assigns(:landing_page)).to eq(landing_page)
        end
      end

      context 'with search params' do
        %w(html json).each do |format|
          context "when format is #{format}" do
            let(:params) { { locale: 'en', id: collection.key, q: 'search', format: format } }

            it 'queries API' do
              get :show, params
              expect(an_api_search_request).to have_been_made.at_least_once
            end

            it 'renders search results template' do
              get :show, params
              expect(response.status).to eq(200)
              expect(response).to render_template('portal/index')
            end

            context 'when collection has custom API URL' do
              before do
                stub_request(:get, "#{collection.api_url}/v2/search.json").
                  with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY'])).
                  to_return(body: api_responses(:search),
                            status: 200,
                            headers: { 'Content-Type' => 'application/json' })
              end

              let(:collection) { collections(:newspapers) }

              context 'without api="default" facet in URL' do
                it 'queries custom' do
                  get :show, params
                  expect(a_request(:get, "#{collection.api_url}/v2/search.json").
                    with(query: hash_including(wskey: ENV['EUROPEANA_API_KEY']))).
                    to have_been_made.at_least_once
                end
              end

              context 'with api="default" facet in URL' do
                let(:params) { { locale: 'en', id: collection.key, q: 'search', format: format, f: { api: ['default'] } } }
                it 'queries default' do
                  get :show, params
                  expect(an_api_search_request).to have_been_made.at_least_once
                end
              end
            end
          end
        end
      end
    end
  end
end
