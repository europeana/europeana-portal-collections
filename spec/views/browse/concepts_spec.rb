require 'support/shared_examples/page_with_top_nav'

RSpec.describe 'browse/concepts.html.mustache' do
  it_should_behave_like 'page with top nav'

  it 'should have page title' do
    render
    page_title = t('site.browse.concepts.title')
    expect(rendered).to have_selector('title', visible: false, text: /\A#{page_title}/)
  end

  it 'should have meta description' do
    render
    expect(rendered).to have_selector("meta[name=\"description\"]", visible: false)
  end

  it 'should have intro para' do
    render
    description = t('site.browse.concepts.description')
    expect(rendered).to have_selector('section.static-header p', text: description)
  end

  it 'should display concept browse entries' do
    assign(:concepts, BrowseEntry.concept.published)
    render
    expect(rendered).to have_selector("ul.browse-entry-list li")
    BrowseEntry.concept.published.each do |concept|
      url = search_path(q: concept.query)
      expect(rendered).to have_selector("ul.browse-entry-list li a[href=\"#{url}\"] span.title",
                                        text: concept.title)
    end
  end
end
