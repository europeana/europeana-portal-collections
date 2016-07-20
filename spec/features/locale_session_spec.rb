RSpec.feature 'Locale stored in session' do
  [false, true].each do |js|
    context (js ? 'with JS' : 'without JS'), js: js do
      describe 'session' do
        it 'stores the locale' do
          visit '/fr'
          sleep 2 if js
          visit '/about.html'
          sleep 2 if js
          expect(current_path).to eq('/fr/about.html')
        end
      end
    end
  end
end
