RSpec.describe SettingsController do
  it 'should use the styleguide' do
    expect(described_class).to include(Europeana::Styleguide)
  end

  describe 'GET language' do
    it 'renders the language settings Mustache template' do
      get :language
      expect(response.status).to eq(200)
      expect(response).to render_template('settings/language')
    end
  end
end
