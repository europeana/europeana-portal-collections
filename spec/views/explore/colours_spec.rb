RSpec.describe 'explore/colours.html.mustache', :common_view_components, :stable_version_view do
  let(:colours) do
    [
      Europeana::Blacklight::Response::Facets::FacetItem.new(value: '#DC143C', hits: 16376),
      Europeana::Blacklight::Response::Facets::FacetItem.new(value: '#F08080', hits: 7555),
      Europeana::Blacklight::Response::Facets::FacetItem.new(value: '#00CED1', hits: 499)
    ]
  end

  before(:each) do
    assign(:colours, colours)
  end

  it 'should have page title' do
    render
    page_title = t('site.browse.colours.title')
    expect(rendered).to have_selector('title', visible: false, text: /\A#{page_title}/)
  end

  it 'should have meta description' do
    render
    expect(rendered).to have_selector('meta[name="description"]', visible: false)
  end

  it 'should have intro para' do
    render
    description = t('site.browse.colours.description')
    expect(rendered).to have_selector('section.static-header p', text: description)
  end

  it 'should display a list of colours' do
    render
    colours.each do |colour|
      expect(rendered).to have_selector("ul li a[style=\"background-color:#{colour.value}\"] span",
                                        text: "(#{colour.hits})")
    end
  end
end
