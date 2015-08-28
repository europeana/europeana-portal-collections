RSpec.describe LandingPage do
  it { is_expected.to belong_to(:channel) }
  it { is_expected.to belong_to(:hero_image) }
  it { is_expected.to belong_to(:credits) }
  it { is_expected.to belong_to(:social_media) }
  it { is_expected.to accept_nested_attributes_for(:hero_image) }
  it { is_expected.to accept_nested_attributes_for(:credits) }
  it { is_expected.to accept_nested_attributes_for(:social_media) }

  describe 'modules' do
    subject { described_class }
    it { is_expected.to include(PaperTrail::Model::InstanceMethods) }
  end
end
