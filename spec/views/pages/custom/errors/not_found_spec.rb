RSpec.describe 'pages/custom/errors/not_found.html.mustache', :blacklight_config, :common_view_components do
  before(:each) do
    assign(:page, page)
    assign(:params, { page: page.slug })
    controller.request.path_parameters.merge!(controller: 'pages', action: 'show')
  end

  let(:page) { pages(:not_found) }

  it 'should have page title' do
    render
    expect(rendered).to have_selector('title', visible: false, text: /\A#{page.title}/)
  end

  it 'should have intro para' do
    render
    expect(rendered).to have_selector('section.page-header p', text: page.body)
  end

  it 'should display search form' do
    render
    expect(rendered).to have_selector('form.search-multiterm input.search-input[type="text"]')
  end
end
