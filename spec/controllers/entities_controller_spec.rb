# frozen_string_literal: true

RSpec.describe EntitiesController do
  let(:entities_api_key) { 'apikey' }
  let(:headers) { { 'Content-Type' => 'application/ld+json' } }

  before do
    Rails.application.config.x.europeana[:entities].api_key = entities_api_key
  end

  describe 'concerns' do
    subject { described_class }
    it { is_expected.to include(Europeana::EntitiesAPIConsumer) }
  end

  describe 'GET #suggest' do
    before do
      stub_request(:get, Europeana::API.url + '/entities/suggest').
        with(query: hash_including(scope: 'europeana')).
        to_return(status: 200, body: '{}', headers: headers)
    end

    context 'without format' do
      subject { -> { get :suggest, locale: 'en' } }
      it { is_expected.to enforce_default_format('json') }
    end

    context 'with format=json' do
      it 'returns http success' do
        get :suggest, locale: 'en', format: 'json'
        expect(response).to have_http_status(:success)
      end

      it 'queries the entity API' do
        get :suggest, locale: 'en', text: 'van', format: 'json'

        expect(
          a_request(:get, Europeana::API.url + '/entities/suggest').
          with(query: hash_including(text: 'van', scope: 'europeana'))
        ).to have_been_made.once
      end

      context 'when language param is present' do
        it 'is sent to the entity API' do
          get :suggest, locale: 'en', text: 'van', language: 'en,de', format: 'json'

          expect(
            a_request(:get, Europeana::API.url + '/entities/suggest').
            with(query: hash_including(text: 'van', scope: 'europeana', language: 'en,de'))
          ).to have_been_made.once
        end
      end
    end
  end

  describe 'GET #show' do
    let(:name) { 'David Hume' }
    let(:slug_name) { 'david-hume' }
    let(:id) { '1234' }
    let(:type) { 'people' }
    let(:description) { 'description' }

    before do
      stub_request(:get, Europeana::API.url + "/entities/agent/base/#{id}").
        with(query: hash_including(wskey: entities_api_key)).
        to_return(status: 200, body: api_responses(:entities_fetch_agent, name: name, description: description), headers:
              headers)
    end

    context 'without format' do
      subject { -> { get :show, locale: 'en', type: type, id: id } }
      it { is_expected.to enforce_default_format('html') }
    end

    context 'with format' do
      context 'without slug in URL' do
        context 'when format=html' do
          it 'redirects to URL with slug' do
            get :show, locale: 'en', type: type, id: id, format: 'html'

            expect(response).to redirect_to("/en/explore/people/#{id}-#{slug_name}.html")
          end
        end

        context 'when format=json' do
          it 'does not redirect to URL with slug' do
            get :show, locale: 'en', type: type, id: id, format: 'json'

            expect(response).not_to redirect_to("/en/explore/people/#{id}-#{slug_name}.json")
          end
        end
      end

      context 'with wrong slug in URL' do
        context 'when format=html' do
          it 'redirects to URL with correct slug' do
            get :show, locale: 'en', type: type, id: id, slug: 'david', format: 'html'

            expect(response).to redirect_to("/en/explore/people/#{id}-#{slug_name}.html")
          end
        end

        context 'when format=json' do
          it 'does not redirect to URL with correct slug' do
            get :show, locale: 'en', type: type, id: id, slug: 'david', format: 'json'

            expect(response).not_to redirect_to("/en/explore/people/#{id}-#{slug_name}.json")
          end
        end
      end

      context 'with slug in URL' do
        let(:params) { { locale: 'en', type: type, id: id, slug: slug_name, format: 'html' } }

        it 'returns http success' do
          get :show, params

          expect(response).to have_http_status(:success)
        end

        it 'queries the entity API' do
          get :show, params

          expect(
            a_request(:get, Europeana::API.url + "/entities/agent/base/#{id}").
            with(query: hash_including(wskey: entities_api_key))
          ).to have_been_made.once
        end

        context 'when format=html' do
          it 'renders entities/show' do
            get :show, params
            expect(response).to render_template('entities/show')
          end
        end

        context 'when format=json' do
          let(:params) { { locale: 'en', type: type, id: id, slug: slug_name, format: 'json' } }

          context 'without profile=promo param' do
            it 'renders entity as JSON' do
              get :show, params
              expect(response.body).to eq(assigns(:entity).to_json)
            end
          end

          context 'with profile=promo param' do
            it 'renders entities/promo' do
              get :show, params.merge(profile: 'promo')
              expect(response).to render_template('entities/promo')
            end
          end
        end
      end
    end
  end

  describe '#body_cache_key' do
    before do
      subject.params[:type] = 'people'
      subject.params[:id] = '123456'
    end

    it 'should return the body cache key' do
      expect(subject.send(:body_cache_key)).to eq('entities/people/123456')
    end
  end

  describe '#entity_caching_enabled' do
    before do
      Rails.application.config.x.disable.view_caching = false
    end

    context 'when entity caching is enabled' do
      before do
        Rails.application.config.x.enable.entity_page_caching = true
      end

      it 'should set entity_caching_enabled to true' do
        expect(subject.send(:entity_caching_enabled?)).to eq(true)
      end
    end

    context 'when entity caching is NOT enabled' do
      before do
        Rails.application.config.x.enable.entity_page_caching = false
      end

      it 'should set entity_caching_enabled to false' do
        expect(subject.send(:entity_caching_enabled?)).to eq(false)
      end
    end
  end
end
