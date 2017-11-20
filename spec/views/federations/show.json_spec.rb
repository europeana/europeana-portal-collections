RSpec.describe 'federations/show.json.jbuilder' do
  let(:json) { JSON.parse(rendered).with_indifferent_access }

  # TODO: spec it
  context 'with @federated_results' do
    pending
  end

  context 'without @federated_results' do
    it 'has error message for tab title' do
      render
      expect(json[:tab_subtitle]).to eq(I18n.t('global.error.unavailable'))
    end

    it 'has blank search results array' do
      render
      expect(json[:search_results]).to eq([])
    end
  end
end
