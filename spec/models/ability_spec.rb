RSpec.describe Ability do
  it 'uses CanCan' do
    expect(described_class).to include(CanCan::Ability)
  end

  context 'without user role (guest)' do
    subject { FactoryGirl.create(:user, :guest) }

    it { is_expected.not_to be_able_to(:access, :rails_admin) }
    it { is_expected.not_to be_able_to(:dashboard, nil) }
    it { is_expected.not_to be_able_to(:manage, Channel.new) }
    it { is_expected.not_to be_able_to(:manage, HeroImage.new) }
    it { is_expected.not_to be_able_to(:manage, LandingPage.new) }
    it { is_expected.not_to be_able_to(:manage, Link.new) }
    it { is_expected.not_to be_able_to(:manage, MediaObject.new) }
    it { is_expected.not_to be_able_to(:manage, User.new) }
  end

  context 'when user role is "user"' do
    subject { FactoryGirl.create(:user) }

    it { is_expected.not_to be_able_to(:access, :rails_admin) }
    it { is_expected.not_to be_able_to(:dashboard, nil) }
    it { is_expected.not_to be_able_to(:manage, Channel.new) }
    it { is_expected.not_to be_able_to(:manage, HeroImage.new) }
    it { is_expected.not_to be_able_to(:manage, LandingPage.new) }
    it { is_expected.not_to be_able_to(:manage, Link.new) }
    it { is_expected.not_to be_able_to(:manage, MediaObject.new) }
    it { is_expected.not_to be_able_to(:manage, User.new) }
  end

  context 'when user role is "admin"' do
    subject { FactoryGirl.create(:user, :admin) }

    it { is_expected.to be_able_to(:access, :rails_admin) }
    it { is_expected.to be_able_to(:dashboard, nil) }
    it { is_expected.to be_able_to(:manage, Channel.new) }
    it { is_expected.to be_able_to(:manage, HeroImage.new) }
    it { is_expected.to be_able_to(:manage, LandingPage.new) }
    it { is_expected.to be_able_to(:manage, Link.new) }
    it { is_expected.to be_able_to(:manage, MediaObject.new) }
    it { is_expected.to be_able_to(:manage, User.new) }
  end
end
