# frozen_string_literal: true

RSpec.describe 'explore/sources.html.mustache', :common_view_components, :stable_version_view do
  let(:providers) do
    [
      { text: 'A Provider', count: 1000,
        data_providers: [
          { text: 'A Data Provider', count: 100 },
          { text: 'Another Data Provider', count: 200 }
        ] },
      { text: 'Another Provider', count: 2000 },
      { text: 'A Different Provider', count: 500 }
    ]
  end

  it 'should have page title' do
    render
    expect(rendered).to have_selector('title', visible: false, text: /sources/i)
  end

  it 'should have meta description' do
    render
    expect(rendered).to have_selector('meta[name="description"]', visible: false)
  end

  it 'should display a list of providers' do
    assign(:providers, providers)
    render
    providers.each do |provider|
      link_text = provider[:text] + ' (' + number_with_delimiter(provider[:count] + ')')
      expect(rendered).to have_selector('ul li a', text: link_text)
    end
  end

  it 'should display nested lists of data providers' do
    assign(:providers, providers)
    render
    providers.select { |p| p[:data_providers].present? }. each do |provider|
      provider[:data_providers].each do |dp|
        link_text = dp[:text] + ' (' + number_with_delimiter(dp[:count] + ')')
        expect(rendered).to have_selector('ul li ul li a', text: link_text)
      end
    end
  end
end
