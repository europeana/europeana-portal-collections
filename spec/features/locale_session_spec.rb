RSpec.feature 'Locale stored in session' do
  [false, true].each do |js|
    context (js ? 'with JS' : 'without JS'), js: js do
      describe 'session' do
        it 'stores the locale' do
          visit '/fr'
          visit '/about'
          expect(current_path).to eq('/fr/about')
        end
      end
    end
  end
end
