require 'support/shared_examples/europeana_api_requests'

RSpec.describe PortalController do
  # workaround for https://github.com/jnicklas/capybara/issues/1396
  include RSpec::Matchers.clone

  describe 'GET index' do
    context 'without q param' do
      it 'redirects to root' do
        get :index
        expect(response).to redirect_to(root_url)
      end
    end

    context 'with q param' do
      before do
        get :index, params
      end

      context 'when q param empty' do
        let(:params) { { q: '' } }

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
        let(:params) { { q: 'paris' } }

        it 'searches the API' do
          expect(an_api_search_request.
            with(query: hash_including(query: 'paris'))).to have_been_made.at_least_once
        end

        it 'renders the search results Mustache template' do
          expect(response.status).to eq(200)
          expect(response).to render_template('portal/index')
        end
      end

      context 'with mlt param' do
        let(:params) { { mlt: '/abc/123' } }
        let(:record_id) { params[:mlt] }
        it_behaves_like 'a record API request'
        it_behaves_like 'a more like this API request'
        it_behaves_like 'no hierarchy API request'
      end
    end
  end

  describe 'GET show' do
    before do
      get :show, params
    end

    let(:params) { { id: 'abc/123' } }
    let(:record_id) { '/' + params[:id] }

    it_behaves_like 'a record API request'
    it_behaves_like 'a more like this API request'
    it_behaves_like 'a hierarchy API request'

    it 'assigns the response to @response' do
      expect(assigns(:response)).to be_a(Europeana::Blacklight::Response)
    end

    it 'assigns the document to @document' do
      expect(assigns(:document)).to be_a(Europeana::Blacklight::Document)
      expect(assigns(:document)).to eq(assigns(:response).documents.first)
    end

    it 'assigns similar items to @similar' do
      expect(assigns(:similar)).to be_a(Array)
      expect(assigns(:similar)).to all(be_a(Europeana::Blacklight::Document))
    end

    it 'does not request the MIME type from the proxy service' do
      expect(a_media_proxy_request_for(record_id)).not_to have_been_made
    end

    it 'does not break if there is no edm:isShownBy'
    it 'does not make a request to the service if record has no edm:isshownby'
    it 'checks that the edm:isShownBy value is sane, i.e. http:// or https://'
    it 'caches the mime-type response'

    context 'when format is HTML' do
      let(:params) { { id: 'abc/123', format: 'html' } }

      it 'renders the object display page' do
        expect(response).to render_template('portal/show')
      end

      context 'without param debug' do
        it 'does not assign @debug' do
          expect(assigns(:debug)).to be_nil
        end
      end

      context 'with param debug=json' do
        let(:params) { { id: 'abc/123', format: 'html', debug: 'json' } }
        it 'assigns pretty JSON document to @debug' do
          expect(assigns(:debug)).to eq(JSON.pretty_generate(assigns(:document).as_json.merge(hierarchy: assigns(:hierarchy).as_json)))
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
      let(:params) { { id: 'abc/123', format: 'json' } }
      let(:record_id) { '/' + params[:id] }
      it_behaves_like 'a record API request'
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
        let(:params) { { id: 'abc/123', format: 'json', page: 2 } }
        it 'paginates' do
          expect(an_api_search_request.with(query: hash_including(start: '5'))).
            to have_been_made
        end
        it 'defaults per_page to 4' do
          expect(an_api_search_request.with(query: hash_including(start: '5', rows: '4'))).
            to have_been_made
        end
      end
      context 'without field limiting param' do
        it 'gets MLT items for all fields' do
          expect(an_api_search_request.with(query: hash_including(query: /title:/))).
            to have_been_made
          expect(an_api_search_request.with(query: hash_including(query: /who:/))).
            to have_been_made
        end
      end
      context 'with field limiting param' do
        let(:params) { { id: 'abc/123', format: 'json', mltf: 'title' } }
        it 'limits MLT items to that field' do
          expect(an_api_search_request.with(query: hash_including(query: /title:/))).
            to have_been_made
          expect(an_api_search_request.with(query: hash_including(query: /who:/))).
            not_to have_been_made
        end
      end
    end

    context 'when format is HTML' do
      let(:params) { { id: 'abc/123', format: 'html' } }
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
      let(:params) { { id: 'abc/123', format: 'json' } }
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
        let(:params) { { id: 'abc/123', format: 'json', page: 2 } }
        it 'paginates'
        it 'defaults per_page to 4'
      end
    end

    context 'when format is HTML' do
      let(:params) { { id: 'abc/123', format: 'html' } }
      it 'renders an error page' do
        get :media, params
        expect(response.status).to eq(404)
        expect(response).to render_template('pages/custom/errors/not_found')
      end
    end
  end
end
