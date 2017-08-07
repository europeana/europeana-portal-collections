require 'rails_helper'

RSpec.feature 'Page titles' do

  before do
    visit '/en'
  end

  describe 'home page' do
    it 'has title Europeana Collections' do
      expect(page).to have_title('Europeana Collections')
    end
  end
end
