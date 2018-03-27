# frozen_string_literal: true

RSpec.describe PagesController do
  describe 'GET show' do
    before do
      get :show, params
    end

    context 'with existent page param' do
      context 'without custom page template' do
        let(:params) { { locale: 'en', format: 'html', page: 'about' } }

        it 'renders generic static page template' do
          expect(response.status).to eq(200)
          expect(response).to render_template('pages/show')
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
  end
end
