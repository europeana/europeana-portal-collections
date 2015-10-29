RSpec.describe Ability do
  it 'uses CanCan' do
    expect(described_class).to include(CanCan::Ability)
  end

  let(:draft_banner) { FactoryGirl.create(:banner) }
  let(:published_banner) { FactoryGirl.create(:banner).tap(&:publish!) }
  let(:draft_collection) { FactoryGirl.create(:collection) }
  let(:published_collection) { FactoryGirl.create(:collection).tap(&:publish!) }
  let(:draft_landing_page) { FactoryGirl.create(:landing_page) }
  let(:published_landing_page) { FactoryGirl.create(:landing_page).tap(&:publish!) }

  context 'without user role (guest)' do
    subject { FactoryGirl.create(:user, :guest) }

    it { is_expected.not_to be_able_to(:access, :rails_admin) }

    it { is_expected.not_to be_able_to(:dashboard, nil) }

    it { is_expected.not_to be_able_to(:manage, Banner.new) }
    it { is_expected.not_to be_able_to(:manage, BrowseEntry.new) }
    it { is_expected.not_to be_able_to(:manage, Collection.new) }
    it { is_expected.not_to be_able_to(:manage, HeroImage.new) }
    it { is_expected.not_to be_able_to(:manage, Page::Landing.new) }
    it { is_expected.not_to be_able_to(:manage, Link.new) }
    it { is_expected.not_to be_able_to(:manage, MediaObject.new) }
    it { is_expected.not_to be_able_to(:manage, User.new) }

    it { is_expected.not_to be_able_to(:show, draft_banner) }
    it { is_expected.to be_able_to(:show, published_banner) }
    it { is_expected.not_to be_able_to(:show, draft_collection) }
    it { is_expected.to be_able_to(:show, published_collection) }
    it { is_expected.not_to be_able_to(:show, draft_landing_page) }
    it { is_expected.to be_able_to(:show, published_landing_page) }
  end

  context 'when user role is "user"' do
    subject { FactoryGirl.create(:user) }

    it { is_expected.not_to be_able_to(:access, :rails_admin) }

    it { is_expected.not_to be_able_to(:dashboard, nil) }

    it { is_expected.not_to be_able_to(:manage, Banner.new) }
    it { is_expected.not_to be_able_to(:manage, BrowseEntry.new) }
    it { is_expected.not_to be_able_to(:manage, Collection.new) }
    it { is_expected.not_to be_able_to(:manage, HeroImage.new) }
    it { is_expected.not_to be_able_to(:manage, Page::Landing.new) }
    it { is_expected.not_to be_able_to(:manage, Link.new) }
    it { is_expected.not_to be_able_to(:manage, MediaObject.new) }
    it { is_expected.not_to be_able_to(:manage, User.new) }

    it { is_expected.not_to be_able_to(:show, draft_banner) }
    it { is_expected.to be_able_to(:show, published_banner) }
    it { is_expected.not_to be_able_to(:show, draft_collection) }
    it { is_expected.to be_able_to(:show, published_collection) }
    it { is_expected.not_to be_able_to(:show, draft_landing_page) }
    it { is_expected.to be_able_to(:show, published_landing_page) }
  end

  context 'when user role is "admin"' do
    subject { FactoryGirl.create(:user, :admin) }

    it { is_expected.to be_able_to(:access, :rails_admin) }
    it { is_expected.to be_able_to(:dashboard, nil) }

    it { is_expected.to be_able_to(:manage, Banner.new) }
    it { is_expected.to be_able_to(:manage, BrowseEntry.new) }
    it { is_expected.to be_able_to(:manage, Collection.new) }
    it { is_expected.to be_able_to(:manage, HeroImage.new) }
    it { is_expected.to be_able_to(:manage, Page::Landing.new) }
    it { is_expected.to be_able_to(:manage, Link.new) }
    it { is_expected.to be_able_to(:manage, MediaObject.new) }
    it { is_expected.to be_able_to(:manage, User.new) }

    it { is_expected.to be_able_to(:show, draft_banner) }
    it { is_expected.to be_able_to(:show, published_banner) }
    it { is_expected.to be_able_to(:show, draft_collection) }
    it { is_expected.to be_able_to(:show, published_collection) }
    it { is_expected.to be_able_to(:show, draft_landing_page) }
    it { is_expected.to be_able_to(:show, published_landing_page) }
  end
end
