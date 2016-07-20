RSpec.describe 'browse/topics.html.mustache', :common_view_components do
  before do
    assign(:topics, BrowseEntry.topic.published)
  end

  it 'should have page title' do
    render
    page_title = t('site.browse.topics.title')
    expect(rendered).to have_selector('title', visible: false, text: /\A#{page_title}/)
  end

  it 'should have meta description' do
    render
    expect(rendered).to have_selector('meta[name="description"]', visible: false)
  end

  it 'should have intro para' do
    render
    description = t('site.browse.topics.description')
    expect(rendered).to have_selector('section.static-header p', text: description)
  end

  it 'should display topic browse entries' do
    render
    expect(rendered).to have_selector('ul.browse-entry-list li')
    BrowseEntry.topic.published.each do |topic|
      url = search_path(Rack::Utils.parse_nested_query(topic.query))
      expect(rendered).to have_selector("ul.browse-entry-list li a[href=\"#{url}\"] span.title",
                                        text: topic.title)
    end
  end
end
