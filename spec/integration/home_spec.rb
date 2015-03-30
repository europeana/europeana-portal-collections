require 'spec_helper'

describe 'home page' do
  it 'welcomes the user'  do
    visit '/'
    expect(page).to have_content('Europeana')
  end
end


describe 'search page' do
  
  it 'expects results', :js => true  do
    current_window.maximize
    visit '/'
    expect(page).to have_css('input[name=q]')
    fill_in('q', with: 'Paris')
    find('.searchbar button.search-submit').click
    #sleep 1
    expect(page).to have_css('.results-list ol li')
    #sleep 2
  end
  
  it 'expects no results', :js => true  do
    current_window.maximize
    visit '/'
    expect(page).to have_css('input[name=q]')
    fill_in('q', with: 'XXX')
    find('.searchbar button.search-submit').click
    #sleep 1
    expect(page).to_not have_css('.results-list ol li')
    sleep 2
  end

end


