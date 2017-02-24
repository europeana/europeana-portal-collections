# frozen_string_literal: true
RSpec.describe Feed do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_uniqueness_of(:url) }
  it { is_expected.to have_and_belong_to_many(:pages) }

  it 'should set the slug from the name' do
    feed = Feed.create(name: 'Art Tumblr')
    expect(feed.slug).to eq('art-tumblr')
  end

  describe '#to_param' do
    it 'should return the slug' do
      feed = Feed.create(name: 'Art Tumblr', slug: 'art-tumblr')
      expect(feed.to_param).to eq('art-tumblr')
    end
  end
end
