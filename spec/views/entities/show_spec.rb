# frozen_string_literal: true

RSpec.describe 'entities/show.html.mustache' do
  it 'should have meta description', skip: true do
    description = 'hello'
    render
    expect(rendered).to have_selector('meta[name="description"][content="' + description + '"]', visible: false)
  end

  it 'should have meta HandheldFriendly', skip: true do
    render
    expect(rendered).to have_selector('meta[name="HandheldFriendly"]', visible: false)
  end
end
