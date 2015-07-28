require 'rails_helper'

RSpec.describe 'routes for the home controller', :type => :routing do
  it 'routes GET / to home#index' do
    expect(get(ENV['RAILS_RELATIVE_URL_ROOT'] + '/')).to route_to('home#index')
  end
end
