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
    allow(view).to receive(:collection).and_return(collection)
    allow(view).to receive(:has_search_parameters?).and_return(false)
  end

  let(:collection) { Collection.find_by_key('music') }
  let(:landing_page) { Page::Landing.find_by_slug('collections/music') }

  subject { rendered }

  it 'should have meta description' do
    render
    meta_content = truncate(ActionView::Base.full_sanitizer.sanitize(landing_page.body), length: 350, separator: ' ')
    expect(subject).to have_selector(%(meta[name="description"][content="#{meta_content}"]), visible: false)
  end

  it 'should have meta HandheldFriendly' do
    render
    expect(subject).to have_selector('meta[name="HandheldFriendly"]', visible: false)
  end

  it 'should have a search field' do
    render
    expect(subject).to have_field('q')
  end

  it 'should have a browse menu' do
    render
    expect(subject).to have_selector('#browse-menu')
    expect(subject).to have_link('All')
    expect(subject).to have_link('Images')
    expect(subject).not_to have_link('3D')
  end

  it 'should have a title' do
    render
    expect(subject).to have_title('Music - ' + t('site.name', default: 'Europeana Collections'))
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
      expect(subject).to have_selector('.search-hero[style*=".full."]')
    end
  end

  context 'when page has browse entries' do
    before do
      image_path = File.expand_path('../../support/media/image.jpg', __dir__)
      file = File.open(image_path)
      media_object = MediaObject.create!(file: file)
      3.times do
        browse = BrowseEntry.new(subject_type: 'topic', media_object: media_object)
        browse.save!
        browse.publish!
        landing_page.browse_entries.push(browse)
      end
      landing_page.save!
    end

    it 'should show them at "small" size' do
      render
      expect(subject).to have_selector('.browse-entry img[src*=".small."]')
    end
  end

  context 'when the page is using the browse layout' do
    let(:collection) { Collection.find_by_key('fashion') }
    let(:landing_page) { Page::Landing.find_by_slug('collections/fashion') }

    it 'should set the og:image to the image of the promo with a position of zero' do
      render
      expected_og_url = landing_page.promotions.find_by(position: 0).file.url
      expect(subject).to have_selector("meta[property=\"og:image\"][content=\"#{expected_og_url}\"]", visible: false)
    end
  end
end
