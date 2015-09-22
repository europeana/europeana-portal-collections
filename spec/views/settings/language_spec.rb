RSpec.describe 'settings/language.html.mustache' do
  before(:each) do
    RSpec.configure do |config|
      config.mock_with :rspec do |mocks|
        mocks.verify_partial_doubles = false
      end
    end

    allow(view).to receive(:content).and_return(
      {
        language_default: {
          title: 'Default Language',
          items: [
            { text: 'English' }, { text: 'French' }
          ]
        }
      }
    )

    Stache::ViewContext.current = view
  end

  it 'should have page title' do
    render
    expect(rendered).to have_css('title', visible: false, text: /Language settings/i)
  end

  it 'should have default language field' do
    render
    expect(rendered).to have_select('Default Language', with_options: ['English', 'French'])
  end
end
