require 'support/shared_examples/page_with_top_nav'

RSpec.describe 'browse/agents.html.mustache' do
  it_should_behave_like 'page with top nav'

  it 'should have page title' do
    render
    page_title = t('site.browse.agents.title')
    expect(rendered).to have_selector('title', visible: false, text: /\A#{page_title}/)
  end

  it 'should have meta description' do
    render
    expect(rendered).to have_selector("meta[name=\"description\"]", visible: false)
  end

  it 'should have intro para' do
    render
    description = t('site.browse.agents.description')
    expect(rendered).to have_selector('section.static-header p', text: description)
  end

  it 'should display agent browse entries' do
    assign(:agents, BrowseEntry.agent.published)
    render
    expect(rendered).to have_selector("ul.browse-entry-list li")
    BrowseEntry.agent.published.each do |agent|
      url = search_path(q: agent.query)
      expect(rendered).to have_selector("ul.browse-entry-list li a[href=\"#{url}\"] span.title",
                                        text: agent.title)
    end
  end
end
