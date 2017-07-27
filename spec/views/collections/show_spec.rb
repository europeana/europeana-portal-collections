# frozen_string_literal: true

RSpec.describe 'collections/show.html.mustache', :common_view_components, :blacklight_config, :stable_version_view do
  include ActionView::Helpers::TextHelper

  before(:each) do
    Rails.cache.write('record/counts/collections/music/type/image', 10)
    assign(:collection, collection)
    assign(:landing_page, landing_page)
    assign(:params, id: collection.id)
    allow(controller).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:has_search_parameters?).and_return(false)
    render
  end

  let(:collection) { Collection.find_by_key('music') }
  let(:landing_page) { Page::Landing.find_by_slug('collections/music') }

  subject { rendered }

  it 'should have meta description' do
    meta_content = truncate(ActionView::Base.full_sanitizer.sanitize(landing_page.body), length: 350, separator: ' ')
    expect(subject).to have_selector("meta[name=\"description\"][content=\"#{meta_content}\"]", visible: false)
  end

  it 'should have meta HandheldFriendly' do
    expect(subject).to have_selector('meta[name="HandheldFriendly"]', visible: false)
  end

  it 'should have a search field' do
    expect(subject).to have_field('q')
  end

  it 'should have a browse menu' do
    expect(subject).to have_selector('#browse-menu')
    expect(subject).to have_link('All')
    expect(subject).to have_link('Images')
    expect(subject).not_to have_link('3D')
  end

  it 'should have a title "Collection name - Europeana Collections"' do
    expect(subject).to have_title('Music - ' + t('site.name', default: 'Europeana Collections'))
  end

  context 'when the page is using the browse layout' do
    let(:collection) { Collection.find_by_key('fashion') }
    let(:landing_page) { Page::Landing.find_by_slug('collections/fashion') }

    it 'should set the og image to the image of the promo with a position of Zero' do
      expected_og_url = landing_page.promotions.find_by(position: 0).file.url
      expect(subject).to have_selector("meta[property=\"og:image\"][content=\"#{expected_og_url}\"]", visible: false)
    end
  end
end
