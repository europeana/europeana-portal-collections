RSpec.describe Ability do
  it 'uses CanCan' do
    expect(described_class).to include(CanCan::Ability)
  end

  let(:draft_banner) { banners(:draft_banner) }
  let(:published_banner) { banners(:default_banner) }
  let(:draft_collection) { collections(:draft) }
  let(:published_collection) { collections(:music) }
  let(:draft_gallery) { galleries(:draft) }
  let(:published_gallery) { galleries(:fashion_dresses) }
  let(:draft_landing_page) { pages(:draft_landing_page) }
  let(:published_landing_page) { pages(:music_collection) }

  context 'without user role (guest)' do
    subject { users(:guest) }

    it { is_expected.not_to be_able_to(:access, :rails_admin) }

    it { is_expected.not_to be_able_to(:dashboard, nil) }

    it { is_expected.not_to be_able_to(:manage, Banner.new) }
    it { is_expected.not_to be_able_to(:manage, BrowseEntry.new) }
    it { is_expected.not_to be_able_to(:manage, Collection.new) }
    it { is_expected.not_to be_able_to(:manage, DataProvider.new) }
    it { is_expected.not_to be_able_to(:manage, Gallery.new) }
    it { is_expected.not_to be_able_to(:manage, HeroImage.new) }
    it { is_expected.not_to be_able_to(:manage, Page.new) }
    it { is_expected.not_to be_able_to(:manage, Page::Error.new) }
    it { is_expected.not_to be_able_to(:manage, Page::Landing.new) }
    it { is_expected.not_to be_able_to(:manage, Link.new) }
    it { is_expected.not_to be_able_to(:manage, MediaObject.new) }
    it { is_expected.not_to be_able_to(:manage, User.new) }

    it { is_expected.not_to be_able_to(:show, draft_banner) }
    it { is_expected.to be_able_to(:show, published_banner) }
    it { is_expected.not_to be_able_to(:show, draft_collection) }
    it { is_expected.to be_able_to(:show, published_collection) }
    it { is_expected.not_to be_able_to(:show, draft_gallery) }
    it { is_expected.to be_able_to(:show, published_gallery) }
    it { is_expected.not_to be_able_to(:show, draft_landing_page) }
    it { is_expected.to be_able_to(:show, published_landing_page) }
  end

  context 'when user role is "user"' do
    subject { users(:user) }

    it { is_expected.not_to be_able_to(:access, :rails_admin) }

    it { is_expected.not_to be_able_to(:dashboard, nil) }

    it { is_expected.not_to be_able_to(:manage, Banner.new) }
    it { is_expected.not_to be_able_to(:manage, BrowseEntry.new) }
    it { is_expected.not_to be_able_to(:manage, Collection.new) }
    it { is_expected.not_to be_able_to(:manage, DataProvider.new) }
    it { is_expected.not_to be_able_to(:manage, Gallery.new) }
    it { is_expected.not_to be_able_to(:manage, HeroImage.new) }
    it { is_expected.not_to be_able_to(:manage, Page.new) }
    it { is_expected.not_to be_able_to(:manage, Page::Error.new) }
    it { is_expected.not_to be_able_to(:manage, Page::Landing.new) }
    it { is_expected.not_to be_able_to(:manage, Link.new) }
    it { is_expected.not_to be_able_to(:manage, MediaObject.new) }
    it { is_expected.not_to be_able_to(:manage, User.new) }

    it { is_expected.not_to be_able_to(:show, draft_banner) }
    it { is_expected.to be_able_to(:show, published_banner) }
    it { is_expected.not_to be_able_to(:show, draft_collection) }
    it { is_expected.to be_able_to(:show, published_collection) }
    it { is_expected.not_to be_able_to(:show, draft_gallery) }
    it { is_expected.to be_able_to(:show, published_gallery) }
    it { is_expected.not_to be_able_to(:show, draft_landing_page) }
    it { is_expected.to be_able_to(:show, published_landing_page) }
  end

  context 'when user role is "admin"' do
    subject { users(:admin) }

    it { is_expected.to be_able_to(:access, :rails_admin) }
    it { is_expected.to be_able_to(:dashboard, nil) }

    it { is_expected.to be_able_to(:manage, Banner.new) }
    it { is_expected.to be_able_to(:manage, BrowseEntry.new) }
    it { is_expected.to be_able_to(:manage, Collection.new) }
    it { is_expected.to be_able_to(:manage, DataProvider.new) }
    it { is_expected.to be_able_to(:manage, Gallery.new) }
    it { is_expected.to be_able_to(:manage, HeroImage.new) }
    it { is_expected.to be_able_to(:manage, Page.new) }
    it { is_expected.to be_able_to(:manage, Page::Error.new) }
    it { is_expected.to be_able_to(:manage, Page::Landing.new) }
    it { is_expected.to be_able_to(:manage, Link.new) }
    it { is_expected.to be_able_to(:manage, MediaObject.new) }
    it { is_expected.to be_able_to(:manage, User.new) }

    it { is_expected.to be_able_to(:show, draft_banner) }
    it { is_expected.to be_able_to(:show, published_banner) }
    it { is_expected.to be_able_to(:show, draft_collection) }
    it { is_expected.to be_able_to(:show, published_collection) }
    it { is_expected.to be_able_to(:show, draft_gallery) }
    it { is_expected.to be_able_to(:show, published_gallery) }
    it { is_expected.to be_able_to(:show, draft_landing_page) }
    it { is_expected.to be_able_to(:show, published_landing_page) }
  end
end
