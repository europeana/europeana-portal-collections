RSpec.describe LandingPage do
  it { is_expected.to belong_to(:channel) }
  it { is_expected.to belong_to(:hero_image) }
  it { is_expected.to belong_to(:credits) }
  it { is_expected.to have_many(:credit_links).through(:credits) }
  it { is_expected.to belong_to(:social_media) }
  it { is_expected.to have_many(:social_media_links).through(:social_media) }

  it { is_expected.to accept_nested_attributes_for(:hero_image) }
  it { is_expected.to accept_nested_attributes_for(:credits) }
  it { is_expected.to accept_nested_attributes_for(:credit_links) }
  it { is_expected.to accept_nested_attributes_for(:social_media) }
  it { is_expected.to accept_nested_attributes_for(:social_media_links) }

  it { is_expected.to delegate_method(:file).to(:hero_image).with_prefix(true) }
  it { is_expected.to delegate_method(:links).to(:credits).with_prefix(:credit) }
  it { is_expected.to delegate_method(:links).to(:social_media).with_prefix(true) }

  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(PaperTrail::Model::InstanceMethods) }
  end
end
