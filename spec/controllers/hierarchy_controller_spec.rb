RSpec.describe HierarchyController do
  %w(self parent children preceding_siblings following_siblings ancestor_self_siblings).each do |action|
    context 'when format is JSON' do
      let(:params) { { locale: 'en', id: 'abc/123', format: 'json' } }

      describe "GET #{action}" do
        it 'queries API' do
          get action, params
          expect(an_api_hierarchy_request_for('/' + params[:id])).to have_been_made
        end

        it 'returns API JSON response' do
          get action, params
          expect(response.content_type).to eq('application/json')
        end
      end
    end

    context 'when format is HTML' do
      let(:params) { { locale: 'en', id: 'abc/123', format: 'html' } }

      describe "GET #{action}" do
        it 'does not query API' do
          get action, params
          expect(an_api_hierarchy_request_for('/' + params[:id])).not_to have_been_made
        end

        it 'returns 404 status' do
          get action, params
          expect(response.status).to eq(404)
        end
      end
    end
  end
end
