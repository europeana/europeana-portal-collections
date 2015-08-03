require 'rails_helper'

RSpec.feature 'Home page' do
  [false, true].each do |js|
    context (js ? 'with JS' : 'without JS'), js: js do
      describe 'home page' do
        it 'welcomes the user' do
          visit '/'
          expect(page).to have_content('Europeana')
        end
      end
    end
  end
end
