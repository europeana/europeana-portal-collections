RSpec.describe 'explore/people.html.mustache', :common_view_components, :stable_version_view do
  before do
    assign(:people, BrowseEntry.person.published)
  end

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
    render
    expect(rendered).to have_selector('ul.browse-entry-list li')
    BrowseEntry.person.published.each do |person|
      url = search_path(Rack::Utils.parse_nested_query(person.query))
      expect(rendered).to have_selector("ul.browse-entry-list li a[href=\"#{url}\"] span.title",
                                        text: person.title)
    end
  end
end
