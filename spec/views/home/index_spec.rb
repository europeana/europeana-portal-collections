# frozen_string_literal: true

RSpec.describe 'home/index.html.mustache', :common_view_components, :stable_version_view do
  include CollectionsHelper
  include RecordCountsHelper

  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.index.title_field = 'title_display'
    end
  end

  let(:landing_page) { pages(:home) }

  let(:collection) { collections(:all) }

  before(:each) do
    allow(controller).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:has_search_parameters?).and_return(false)
    assign(:landing_page, landing_page)
    assign(:collection, collection)
  end

  it 'should have meta description' do
    meta_content = collection_strapline(collection)&.strip
    render
    expect(rendered).to have_selector("meta[name=\"description\"][content=\"#{meta_content}\"]", visible: false)
  end

  it 'should have meta HandheldFriendly' do
    render
    expect(rendered).to have_selector('meta[name="HandheldFriendly"]', visible: false)
  end

  it 'should have a title "Europeana Collections"' do
    render
    expect(rendered).to have_title(t('site.name', default: 'Europeana Collections'))
  end

  context 'when page has a hero image' do
    before do
      image_path = File.expand_path('../../support/media/image.jpg', __dir__)
      file = File.open(image_path)
      landing_page.build_hero_image
      landing_page.hero_image.build_media_object(file: file)
      landing_page.hero_image.save!
    end

    it 'should show it at "full" size' do
      render
      expect(rendered).to have_selector('.search-hero[style*=".full."]')
    end
  end

  context 'when page has promotions' do
    before do
      image_path = File.expand_path('../../support/media/image.jpg', __dir__)
      file = File.open(image_path)
      landing_page.promotions.build(url: 'http://www.example.org/')
      landing_page.promotions.last.build_media_object(file: file)
      landing_page.promotions.last.save!
    end

    it 'should show it at "xl" size' do
      render
      expect(rendered).to have_selector('.promo-block-image[style*=".xl."]')
    end
  end
end
