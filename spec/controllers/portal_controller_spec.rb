# frozen_string_literal: true

require 'support/shared_examples/europeana_api_requests'

RSpec.describe PortalController, :annotations_api do
  # workaround for https://github.com/jnicklas/capybara/issues/1396
  include RSpec::Matchers.clone

  describe 'GET index' do
    context 'when the format is html' do
      context 'without q param' do
        it 'redirects to root' do
          get :index, locale: 'en'
          expect(response).to redirect_to(home_url(locale: 'en'))
        end
      end

      context 'with q param' do
        before do
          get :index, params
        end

        context 'when q param empty' do
          let(:params) { { locale: 'en', q: '' } }

          it 'searches the API' do
            expect(an_api_search_request.
              with(query: hash_including(query: '*:*'))).to have_been_made.at_least_once
          end

          it 'renders the search results Mustache template' do
            expect(response.status).to eq(200)
            expect(response).to render_template('portal/index')
          end
        end

        context 'when q param non-empty' do
          let(:params) { { locale: 'en', q: 'paris' } }

          it 'searches the API' do
            expect(an_api_search_request.
              with(query: hash_including(query: 'paris'))).to have_been_made.at_least_once
          end

          it 'renders the search results Mustache template' do
            expect(response.status).to eq(200)
            expect(response).to render_template('portal/index')
          end

          it 'assigns the default landing page to @landing_page' do
            expect(assigns(:landing_page)).to be_a(Page::Landing)
          end
        end

        context 'with mlt param' do
          let(:params) { { locale: 'en', mlt: '/abc/123' } }
          let(:record_id) { params[:mlt] }
          it_behaves_like 'a record API request'
          it_behaves_like 'a more like this API request'
          it_behaves_like 'no hierarchy API request'
        end
      end

      context 'with qe param' do
        let(:params) { { locale: 'en', qe: { 'agent/base/60166' => 'Miles Davis' } } }

        it 'searches the API for entities' do
          get :index, params

          expect(an_api_search_request.
            with(query: hash_including(qf: 'who:"http://data.europeana.eu/agent/base/60166"'))).
            to have_been_made
        end
      end
    end

    context 'when the format is json' do
      before do
        get :index, params
      end

      context 'with q param' do
        let(:params) { { locale: 'en', q: 'paris', format: 'json' } }

        it 'total is present in results' do
          expect(response.status).to eq(200)
          json = nil
          expect { json = JSON.parse(response.body).with_indifferent_access }.not_to raise_exception
          expect(json).to match(
            search_results: be_kind_of(Array),
            total: be_kind_of(Hash)
          )
          expect(json[:total]).to match(
            value: be_kind_of(Integer),
            formatted: be_kind_of(String)
          )
        end
      end
    end
  end

  describe 'GET show' do
    let(:params) { { locale: 'en', id: 'abc/123' } }
    let(:record_id) { '/' + params[:id] }

    context 'when record is not found' do
      it 'returns 404' do
        allow(controller).to receive(:fetch).and_raise(Europeana::API::Errors::ResourceNotFoundError, 'Not Found')
        get :show, params
        expect(response.status).to eq(404)
      end
    end

    describe 'API requests' do
      before do
        get :show, params
      end
      it_behaves_like 'a record API request'
      it_behaves_like 'no more like this API request'
      it_behaves_like 'no hierarchy API request'
      it_behaves_like 'an annotations API request'

      context 'when annotations=later is present' do
        let(:params) { { locale: 'en', id: 'abc/123', annotations: 'later' } }
        it_behaves_like 'no annotations API request'
      end
    end

    it 'assigns the response to @response' do
      get :show, params
      expect(assigns(:response)).to be_a(Europeana::Blacklight::Response)
    end

    it 'assigns the document to @document' do
      get :show, params
      expect(assigns(:document)).to be_a(Europeana::Blacklight::Document)
      expect(assigns(:document)).to eq(assigns(:response).documents.first)
    end

    context 'with edm:dataProvider' do
      before do
        get :show, params
      end
      let(:params) { { locale: 'en', id: 'with/edm:dataProvider' } }
      it 'assigns the data provider to @data_provider' do
        expect(assigns(:data_provider)).to eq(data_providers(:anonymous))
      end
    end

    it 'does not request the MIME type from the proxy service' do
      get :show, params
      expect(a_media_proxy_request_for(record_id)).not_to have_been_made
    end

    it 'does not break if there is no edm:isShownBy'
    it 'does not make a request to the service if record has no edm:isshownby'
    it 'checks that the edm:isShownBy value is sane, i.e. http:// or https://'
    it 'caches the mime-type response'

    it 'requests annotations from the API' do
      get :show, params
      expect(an_annotations_api_search_request_for(record_id)).to have_been_made
    end

    context 'when format is HTML' do
      let(:params) { { locale: 'en', id: 'abc/123', format: 'html' } }

      it 'renders the object display page' do
        get :show, params
        expect(response).to render_template('portal/show')
      end

      context 'without param debug' do
        it 'does not assign @debug' do
          get :show, params
          expect(assigns(:debug)).to be_nil
        end
      end

      context 'with param debug=json' do
        let(:params) { { locale: 'en', id: 'abc/123', format: 'html', debug: 'json' } }
        it 'assigns pretty JSON document to @debug' do
          get :show, params
          expect(assigns(:debug)).to eq(JSON.pretty_generate(assigns(:document).as_json))
        end
      end

      describe 'URL conversions' do
        context 'when item has TEL newspaper' do
          context 'with query param' do
            let(:params) { { locale: 'en', id: 'abc/123', format: 'html', q: 'paris' } }
            let(:api_response) { JSON.parse(api_responses(:record_with_tel_web_resource, id: params[:id])) }
            let(:bl_response) { Europeana::Blacklight::Response.new(api_response, {}) }
            let(:document) { bl_response.documents.first }

            it 'has a conversion for the TEL URL' do
              stub_request(:get, 'http://oembed.europeana.eu/?format=json&url=http://www.theeuropeanlibrary.org/tel4/newspapers/issue/fullscreen/abc/123?query=paris')

              allow(controller).to receive(:fetch).and_return([bl_response, document])
              get :show, params

              expect(an_api_record_request_for('/abc/123')).not_to have_been_made
              expect(response.status).to eq(200)

              expect(assigns[:url_conversions]).to have_key('http://www.theeuropeanlibrary.org/tel4/newspapers/issue/fullscreen/abc/123')
            end
          end
        end
      end
    end

    context 'when format is JSON' do
      it 'requests JSON-LD from the API'
      it 'renders the API JSON-LD response'
    end
  end

  describe 'GET similar' do
    context 'when format is JSON' do
      before do
        get :similar, params
      end
      let(:params) { { locale: 'en', id: 'abc/123', format: 'json', mlt_query: mlt_query } }
      let(:record_id) { '/' + params[:id] }
      context 'when a mlt_query is provided' do
        let(:mlt_query) { '(what: ("Object Type\: print")^0.8 OR who: ("somebody")^0.5 NOT europeana_id:"/abc/123"' }

        it_behaves_like 'no record API request'
        it_behaves_like 'a more like this API request'
        it_behaves_like 'no hierarchy API request'
        it 'responds with JSON' do
          expect(response.content_type).to eq('application/json')
        end
        it 'has 200 status code' do
          expect(response.status).to eq(200)
        end
        it 'renders JSON ERB template' do
          expect(response).to render_template('portal/similar')
        end
        context 'with page param' do
          let(:params) { { locale: 'en', id: 'abc/123', format: 'json', mlt_query: mlt_query, page: 2 } }
          it 'paginates' do
            expect(an_api_search_request.with(query: hash_including(start: '5'))).
              to have_been_made
          end
          it 'defaults per_page to 4' do
            expect(an_api_search_request.with(query: hash_including(start: '5', rows: '4'))).
              to have_been_made
          end
        end
        it 'queries for the supplied mlt_query' do
          expect(an_api_search_request.with(query: hash_including(query: /what:/))).
            to have_been_made
          expect(an_api_search_request.with(query: hash_including(query: /who:/))).
            to have_been_made
        end
      end
      context 'when no mlt_query is provided, or the mlt_query is empty' do
        let(:mlt_query) { nil }
        it_behaves_like 'a record API request'
        it_behaves_like 'a more like this API request'
        it_behaves_like 'no hierarchy API request'
        it 'responds with JSON' do
          expect(response.content_type).to eq('application/json')
        end
        it 'has 200 status code' do
          expect(response.status).to eq(200)
        end
      end
    end

    context 'when format is HTML' do
      let(:params) { { locale: 'en', id: 'abc/123', format: 'html' } }
      it 'renders an error page' do
        get :similar, params
        expect(response.status).to eq(404)
        expect(response).to render_template('pages/custom/errors/not_found')
      end
    end
  end

  describe 'GET media' do
    context 'when format is JSON' do
      before do
        get :media, params
      end
      let(:params) { { locale: 'en', id: 'abc/123', format: 'json' } }
      let(:record_id) { '/' + params[:id] }
      it_behaves_like 'a record API request'
      it_behaves_like 'no hierarchy API request'
      it 'responds with JSON' do
        expect(response.content_type).to eq('application/json')
      end
      it 'has 200 status code' do
        expect(response.status).to eq(200)
      end
      it 'renders JSON ERB template' do
        expect(response).to render_template('portal/media')
      end
      context 'with page param' do
        let(:params) { { locale: 'en', id: 'abc/123', format: 'json', page: 2 } }
        it 'paginates'
        it 'defaults per_page to 4'
      end
    end

    context 'when format is HTML' do
      let(:params) { { locale: 'en', id: 'abc/123', format: 'html' } }
      it 'renders an error page' do
        get :media, params
        expect(response.status).to eq(404)
        expect(response).to render_template('pages/custom/errors/not_found')
      end
    end
  end
end
