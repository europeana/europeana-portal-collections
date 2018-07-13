# frozen_string_literal: true

RSpec.describe 'pages/browse/record_sets.html.mustache', :common_view_components do
  before(:each) do
    assign(:page, page)
    allow(view).to receive(:page) { page }
    assign(:items, items)
    allow(view).to receive(:items) { items }
  end

  let(:page) { pages(:newspapers_a_to_z_browse) }
  let(:items) do
    api_response = JSON.parse(api_responses(:search, ids: page.europeana_ids))
    api_response['items'].each_with_object({}) { |item, memo| memo[item['id']] = item }
  end

  it 'should have page title' do
    render
    expect(rendered).to have_selector('title', visible: false, text: /\A#{page.title}/)
  end

  it 'should link to a search for each set' do
    render

    page.sets.each do |set|
      href = '/search?q=' + set.query_term
      text = format(page.settings_link_text, set_title: set.title)
      expect(rendered).to have_selector(%(a[href$="#{href}"]), text: text)
    end
  end
end
