require 'rails_helper'

RSpec.feature 'Home page', :type => :feature do
  describe 'home page' do
    it 'welcomes the user' do
      visit '/'
      expect(page).to have_content('Europeana')
    end
  end
end
