RSpec.describe 'browse/people.html.mustache', :page_with_top_nav do
  it 'should have page title' do
    render
    page_title = t('site.browse.people.title')
    expect(rendered).to have_selector('title', visible: false, text: /\A#{page_title}/)
  end

  it 'should have meta description' do
    render
    expect(rendered).to have_selector('meta[name="description"]', visible: false)
  end

  it 'should have intro para' do
    render
    description = t('site.browse.people.description')
    expect(rendered).to have_selector('section.static-header p', text: description)
  end

  it 'should display person browse entries' do
    assign(:people, BrowseEntry.person.published)
    render
    expect(rendered).to have_selector('ul.browse-entry-list li')
    BrowseEntry.person.published.each do |person|
      url = search_path(Rack::Utils.parse_nested_query(person.query))
      expect(rendered).to have_selector("ul.browse-entry-list li a[href=\"#{url}\"] span.title",
                                        text: person.title)
    end
  end
end
