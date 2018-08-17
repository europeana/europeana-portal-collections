# frozen_string_literal: true

RSpec.describe PagesController do
  describe 'GET show' do
    subject { -> { get :show, params } }

    before do
      subject.call
    end

    context 'with existent page param' do
      context 'without custom page template' do
        context 'without format' do
          let(:params) { { locale: 'en', page: 'about' } }
          it { is_expected.to enforce_default_format('html') }
        end

        context 'with format=html' do
          let(:params) { { locale: 'en', format: 'html', page: 'about' } }

          it 'renders generic static page template' do
            expect(response.status).to eq(200)
            expect(response).to render_template('pages/show')
          end
        end
      end

      context 'with custom page template and code' do
        let(:params) { { locale: 'en', format: 'html', page: 'errors/not_found' } }

        it 'renders custom page template' do
          expect(response.status).to eq(404)
          expect(response).to render_template('pages/custom/errors/not_found')
        end
      end
    end

    context 'with non-existent page param' do
      let(:params) { { locale: 'en', format: 'html', page: 'unknown/page' } }

      it 'renders error page' do
        expect(response.status).to eq(404)
        expect(response).to render_template('pages/custom/errors/not_found')
      end
    end

    it 'should prevent access by unauthorized users' # e.g. only admins can see drafts

    context 'when type is Page::Browse::RecordSets' do
      let(:page) { pages(:newspapers_a_to_z_browse) }
      let(:params) { { locale: 'en', format: 'html', page: page.slug } }

      it 'renders browse page template' do
        expect(response.status).to eq(200)
        expect(response).to render_template('pages/browse/record_sets')
      end

      it 'queries API for documents' do
        expect(an_api_search_request).to have_been_made.at_least_once
      end

      it 'stores documents in @items' do
        expect(assigns[:items]).to be_a(Hash)
        assigns[:items].each_key do |key|
          expect(Europeana::Record.id?(key)).to be true
        end
      end
    end
  end
end
